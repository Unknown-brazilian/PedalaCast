package br.com.arthur.pedalacast.video

import android.content.Context
import android.graphics.Bitmap
import android.net.Uri
import android.os.BatteryManager
import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import android.os.SystemClock
import android.view.Surface
import br.com.arthur.pedalacast.overlay.BrandPalette
import br.com.arthur.pedalacast.overlay.OverlayLayout
import br.com.arthur.pedalacast.overlay.OverlayRenderer
import br.com.arthur.pedalacast.overlay.OverlayState
import br.com.arthur.pedalacast.telemetry.PhoneTelemetrySource
import br.com.arthur.pedalacast.telemetry.PrivacyZone
import br.com.arthur.pedalacast.telemetry.SimulationSource
import br.com.arthur.pedalacast.telemetry.TelemetryEngine
import br.com.arthur.pedalacast.telemetry.TelemetryLogger
import br.com.arthur.pedalacast.telemetry.TelemetrySample
import com.pedro.common.ConnectChecker
import com.pedro.encoder.input.sources.audio.AudioSource
import com.pedro.encoder.input.sources.audio.MicrophoneSource
import com.pedro.encoder.input.sources.audio.NoAudioSource
import com.pedro.encoder.input.sources.video.Camera2Source
import com.pedro.encoder.input.gl.render.filters.`object`.ImageFilterRender
import com.pedro.library.base.recording.RecordController
import com.pedro.library.generic.GenericStream
import com.pedro.library.util.BitrateAdapter
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

data class VideoConfig(
    val width: Int = 1920, val height: Int = 1080, val fps: Int = 30,
    val bitrate: Int = 12_000_000, val portrait: Boolean = false, val micEnabled: Boolean = true,
    val autoPause: Boolean = false, val privacyRadiusM: Double = 300.0,
) {
    /** Tamanho final do quadro (já com a rotação aplicada). */
    val frameW get() = if (portrait) height else width
    val frameH get() = if (portrait) width else height
}

/**
 * Pipeline único: câmera → compositor OpenGL (com overlay) → encoder H.264 → MP4.
 * Vive no processo (singleton) para sobreviver à Activity; o RecordingService o mantém vivo.
 * Na Fase 2 o mesmo encoder alimenta o RTMPS.
 */
object PedalaCore {
    private const val MIN_LIVE_BITRATE = 1_000_000

    enum class State { IDLE, PREVIEW, RECORDING, PAUSED }

    private lateinit var app: Context
    private val main = Handler(Looper.getMainLooper())
    private lateinit var palette: BrandPalette
    private lateinit var renderer: OverlayRenderer

    private var stream: GenericStream? = null
    private var config = VideoConfig()
    private var filter: ImageFilterRender? = null
    private var bitmaps: Array<Bitmap>? = null
    private var bmIdx = 0

    val engine by lazy { TelemetryEngine(app) }
    @Volatile var layout: OverlayLayout = OverlayLayout.default()
    private var layoutVersion = 0
    @Volatile var simulation = false
    @Volatile var liveLabel = "AO VIVO"
    @Volatile var recLabel = "REC"

    fun setLocale(tag: String?, live: String?, rec: String?, hr: String?) {
        tag?.let { renderer.locale = java.util.Locale.forLanguageTag(it) }
        live?.let { liveLabel = it }
        rec?.let { recLabel = it }
        hr?.let { renderer.hrLabel = it }
        layoutVersion++
    }

    @Volatile var state = State.IDLE
        private set
    private var recordStartMs = 0L
    private var pausedAccumMs = 0L
    private var pauseStartMs = 0L
    private var currentVideo: Storage.Pending? = null
    private var currentBase = ""
    private var gpxUri: Uri? = null
    private var jsonUri: Uri? = null

    private var overlayThread: HandlerThread? = null
    private var overlayHandler: Handler? = null
    private var lastSig = ""
    private var autoPaused = false
    private var slowSince = 0L

    var onStatus: ((Map<String, Any?>) -> Unit)? = null
    var onSample: ((TelemetrySample) -> Unit)? = null
    var lastError: String? = null
        private set

    // ---------------- live (RTMPS) ----------------

    enum class LiveState { OFF, CONNECTING, CONNECTED, RECONNECTING }

    @Volatile var liveState = LiveState.OFF
        private set
    private var liveEndpoint: String? = null      // contém a chave: nunca registrar em log
    private var liveStartMs = 0L
    private var liveAttempts = 0
    private var liveStartedRecording = false
    @Volatile private var realBitrateBps = 0L
    private var maxLiveBitrate = 0
    private val adapter = BitrateAdapter { b ->
        val v = b.coerceIn(MIN_LIVE_BITRATE, maxLiveBitrate.coerceAtLeast(MIN_LIVE_BITRATE))
        runCatching { stream?.setVideoBitrateOnFly(v) }
    }

    private val liveChecker = object : ConnectChecker {
        override fun onConnectionStarted(url: String) {}
        override fun onConnectionSuccess() { liveAttempts = 0; liveState = LiveState.CONNECTED; main.post { emitStatus() } }
        override fun onConnectionFailed(reason: String) {
            if (liveState == LiveState.OFF) return
            liveState = LiveState.RECONNECTING
            liveAttempts++
            val delay = (1000L shl liveAttempts.coerceAtMost(5)).coerceAtMost(30_000L)   // 2,4,8,16,30 s
            main.post {
                // A gravação local não depende da rede e segue normalmente.
                val ok = runCatching { stream?.getStreamClient()?.reTry(delay, reason) ?: false }.getOrDefault(false)
                if (!ok) liveState = LiveState.RECONNECTING
                emitStatus()
            }
        }
        override fun onDisconnect() { if (liveState != LiveState.OFF) liveState = LiveState.RECONNECTING }
        override fun onAuthError() { lastError = "Falha de autenticação no YouTube (confira a chave)"; }
        override fun onAuthSuccess() {}
        override fun onNewBitrate(bitrate: Long) {
            realBitrateBps = bitrate
            val client = stream?.getStreamClient() ?: return
            adapter.adaptBitrate(bitrate, client.hasCongestion())
        }
    }

    /** [endpoint] = URL de ingestão + "/" + chave. [recordLocal]: grava MP4 com o mesmo encoder. */
    fun startLive(endpoint: String, maxBitrate: Int, recordLocal: Boolean): Result<Unit> = runCatching {
        val s = stream ?: error("Preview não iniciado")
        check(liveState == LiveState.OFF) { "Já está transmitindo" }
        require(endpoint.startsWith("rtmps://") || endpoint.startsWith("rtmp://")) { "URL inválida" }
        liveStartedRecording = false
        if (recordLocal && state == State.PREVIEW) {
            startRecording().getOrThrow()
            liveStartedRecording = true
        }
        maxLiveBitrate = maxBitrate
        adapter.setMaxBitrate(maxBitrate)
        liveEndpoint = endpoint
        liveAttempts = 0
        liveStartMs = SystemClock.elapsedRealtime()
        liveState = LiveState.CONNECTING
        s.getStreamClient().setReTries(1000)
        s.startStream(endpoint)
        emitStatus()
    }.onFailure { lastError = it.message; liveState = LiveState.OFF }

    fun stopLive() {
        if (liveState == LiveState.OFF) return
        liveState = LiveState.OFF
        liveEndpoint = null
        runCatching { stream?.stopStream() }
        if (liveStartedRecording) { stopRecording(); liveStartedRecording = false }
        realBitrateBps = 0
        emitStatus()
    }

    fun init(context: Context) {
        if (::app.isInitialized) return
        app = context.applicationContext
        palette = BrandPalette.load(app)
        renderer = OverlayRenderer(palette)
        engine.onSample = { s -> onSample?.invoke(s); autoPauseCheck(s) }
    }

    fun setLayout(json: String?) {
        layout = OverlayLayout.parse(json)
        layoutVersion++
    }

    // ---------------- telemetria ----------------

    fun startTelemetry() {
        if (engine.running) return
        val phone = PhoneTelemetrySource(app)
        if (simulation) engine.start(SimulationSource(app), hasBarometer = false)
        else engine.start(phone, phone.hasBarometer)
    }

    fun restartTelemetry() { engine.stop(); startTelemetry() }

    fun hasBarometer(): Boolean = PhoneTelemetrySource(app).hasBarometer

    // ---------------- preview ----------------

    fun startPreview(surface: Surface, cfg: VideoConfig): Result<Unit> = runCatching {
        if (state != State.IDLE) return@runCatching
        config = cfg
        val audio: AudioSource = if (cfg.micEnabled) MicrophoneSource() else NoAudioSource()
        val s = GenericStream(app, liveChecker, Camera2Source(app), audio)
        if (!s.prepareVideo(cfg.width, cfg.height, cfg.bitrate, cfg.fps, 2, if (cfg.portrait) 90 else 0)) error("Câmera/encoder não suportam ${cfg.width}x${cfg.height}")
        if (!s.prepareAudio(44100, true, 128_000)) error("Falha ao preparar o áudio")
        val f = ImageFilterRender().apply { setScale(100f, 100f); setPosition(0f, 0f) }
        s.getGlInterface().addFilter(f)
        filter = f
        bitmaps = Array(2) { Bitmap.createBitmap(cfg.frameW, cfg.frameH, Bitmap.Config.ARGB_8888) }
        s.startPreview(surface, cfg.frameW, cfg.frameH)
        stream = s
        state = State.PREVIEW
        startTelemetry()
        startOverlayLoop()
        emitStatus()
    }.onFailure { lastError = it.message; releaseStream() }

    fun stopPreview() {
        if (state == State.RECORDING || state == State.PAUSED || liveState != LiveState.OFF) return
        releaseStream()
        engine.stop()
        state = State.IDLE
        emitStatus()
    }

    private fun releaseStream() {
        stopOverlayLoop()
        runCatching { stream?.stopPreview() }
        runCatching { stream?.release() }
        stream = null; filter = null; bitmaps = null
    }

    // ---------------- gravação ----------------

    fun startRecording(): Result<Unit> = runCatching {
        val s = stream ?: error("Preview não iniciado")
        check(state == State.PREVIEW) { "Já está gravando" }
        if (Storage.freeBytes() < 500L * 1024 * 1024) error("Pouco espaço livre (menos de 500 MB)")
        val base = "pedalacast_" + SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US).format(Date())
        currentBase = base
        val video = Storage.createVideo(app, base)
        currentVideo = video
        val (gu, gout) = Storage.createDoc(app, "$base.gpx", "application/gpx+xml")
        val (ju, jout) = Storage.createDoc(app, "$base.json", "application/json")
        gpxUri = gu; jsonUri = ju
        engine.logger = TelemetryLogger(gout, jout, base)
        pausedAccumMs = 0; autoPaused = false
        s.setRecordController(FdRecordController(video.pfd.fileDescriptor))
        s.startRecord("", RecordController.RecordTracks.ALL, object : RecordController.Listener {
            override fun onStatusChange(status: RecordController.Status) {}
            override fun onError(e: Exception?) { lastError = e?.message; main.post { stopRecording() } }
        })
        recordStartMs = SystemClock.elapsedRealtime()
        state = State.RECORDING
        emitStatus()
    }.onFailure { lastError = it.message }

    fun pauseRecording() {
        if (state != State.RECORDING) return
        stream?.pauseRecord(); pauseStartMs = SystemClock.elapsedRealtime(); state = State.PAUSED; emitStatus()
    }

    fun resumeRecording() {
        if (state != State.PAUSED) return
        stream?.resumeRecord(); pausedAccumMs += SystemClock.elapsedRealtime() - pauseStartMs
        state = State.RECORDING; emitStatus()
    }

    /** Retorna o URI do vídeo salvo. */
    fun stopRecording(): String? {
        if (state != State.RECORDING && state != State.PAUSED) return null
        val s = stream
        runCatching { s?.stopRecord() }
        engine.logger?.close(); engine.logger = null
        val video = currentVideo
        runCatching { video?.pfd?.close() }
        video?.let { Storage.finishVideo(app, it.uri) }
        currentVideo = null
        state = State.PREVIEW
        emitStatus()
        return video?.uri?.toString()
    }

    fun elapsedMs(): Long = if (liveState != LiveState.OFF && state == State.PREVIEW) {
        SystemClock.elapsedRealtime() - liveStartMs
    } else when (state) {
        State.RECORDING -> SystemClock.elapsedRealtime() - recordStartMs - pausedAccumMs
        State.PAUSED -> pauseStartMs - recordStartMs - pausedAccumMs
        else -> 0
    }

    private fun autoPauseCheck(s: TelemetrySample) {
        if (!config.autoPause) return
        val v = s.speedMps ?: return
        val now = SystemClock.elapsedRealtime()
        if (state == State.RECORDING && v < 1.0) {
            if (slowSince == 0L) slowSince = now
            if (now - slowSince > 10_000) { autoPaused = true; pauseRecording() }
        } else if (v >= 1.0) {
            slowSince = 0
            if (state == State.PAUSED && autoPaused) { autoPaused = false; resumeRecording() }
        }
    }

    // ---------------- overlay ----------------

    private fun startOverlayLoop() {
        val t = HandlerThread("overlay").also { it.start() }
        overlayThread = t
        val h = Handler(t.looper)
        overlayHandler = h
        h.post(object : Runnable {
            override fun run() {
                renderOverlay()
                h.postDelayed(this, 200L)
            }
        })
    }

    private fun stopOverlayLoop() {
        overlayHandler?.removeCallbacksAndMessages(null)
        overlayThread?.quitSafely()
        overlayThread = null; overlayHandler = null
    }

    private fun renderOverlay() {
        val f = filter ?: return
        val bms = bitmaps ?: return
        val sample = engine.processor.last
        val elapsed = elapsedMs()
        val sig = "${sample?.tMs}|${elapsed / 1000}|$layoutVersion|$state|$liveState|${clockText()}"
        if (sig == lastSig) return          // só envia nova textura à GPU quando algo mudou
        lastSig = sig
        val track = engine.processor.trackSnapshot()
        val first = track.firstOrNull()
        val pz = if (first != null && layout.privacyRadiusM > 0) PrivacyZone(first.lat, first.lon, layout.privacyRadiusM) else null
        val badge = when {
            liveState != LiveState.OFF -> liveLabel
            state == State.RECORDING || state == State.PAUSED -> recLabel
            else -> null
        }
        val bm = bms[bmIdx]
        bmIdx = 1 - bmIdx
        renderer.render(bm, layout, OverlayState(sample, track, planned, badge, elapsed, pz, clockText()))
        f.setImage(bm)
    }

    @Volatile var planned: List<br.com.arthur.pedalacast.overlay.LatLon>? = null

    private fun clockText() = SimpleDateFormat("HH:mm", renderer.locale).format(Date())

    /** Salva um PNG do overlay sobre uma imagem estática com dados fixos (tela de debug). */
    fun renderDebugPng(layoutJson: String?, w: Int = 1280, h: Int = 720): String {
        val bg = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
        val c = android.graphics.Canvas(bg)
        val p = android.graphics.Paint()
        p.shader = android.graphics.LinearGradient(0f, 0f, 0f, h.toFloat(), 0xFF5B7FA6.toInt(), 0xFF2E3B2A.toInt(), android.graphics.Shader.TileMode.CLAMP)
        c.drawRect(0f, 0f, w.toFloat(), h.toFloat(), p)
        val ov = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
        val lay = OverlayLayout.parse(layoutJson)
        val track = (0..400).map {
            val d = it * 5.0
            br.com.arthur.pedalacast.telemetry.TrackPoint(
                -22.9 + it * 0.00003, -47.06 + 0.002 * Math.sin(it / 40.0) + it * 0.00004,
                600 + 40 * Math.sin(it / 80.0) + it * 0.05, d,
            )
        }
        val sample = TelemetrySample(
            tMs = 0, epochMs = System.currentTimeMillis(), lat = track.last().lat, lon = track.last().lon,
            speedMps = 7.2, altitudeM = track.last().altM, gradePct = 6.5, distanceM = 2000.0, ascentM = 182.0,
            hrBpm = 148, cadenceRpm = 86, powerW = 210, batteryPct = 72, signalLevel = 3, networkType = "Móvel",
        )
        renderer.render(ov, lay, OverlayState(sample, track, null, recLabel, 754_000, null, "08:42"))
        c.drawBitmap(ov, 0f, 0f, null)
        val (uri, out) = Storage.createImage(app, "overlay_debug_" + System.currentTimeMillis() + ".png")
        out.use { bg.compress(Bitmap.CompressFormat.PNG, 100, it) }
        return uri.toString()
    }

    // ---------------- status ----------------

    fun emitStatus() {
        val b = app.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        val ph = engine.processor.phone
        onStatus?.invoke(
            mapOf(
                "state" to state.name.lowercase(),
                "elapsedMs" to elapsedMs(),
                "gpsOk" to (engine.running && SystemClock.elapsedRealtime() - engine.lastFixTMs < 5000),
                "hasBarometer" to (stream != null && !simulation && hasBarometer()),
                "freeBytes" to Storage.freeBytes(),
                "tempC" to ph.tempC,
                "batteryPct" to b.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY),
                "simulation" to simulation,
                "live" to (liveState != LiveState.OFF),
                "liveState" to liveState.name.lowercase(),
                "bitrateKbps" to realBitrateBps / 1000,
                "droppedFrames" to (stream?.getStreamClient()?.getDroppedVideoFrames() ?: 0L),
                "network" to ph.networkType,
                "error" to lastError,
            )
        )
    }

    /** Verificações periódicas durante a gravação: espaço baixo. */
    fun tick() {
        if ((state == State.RECORDING || state == State.PAUSED) && Storage.freeBytes() < 100L * 1024 * 1024) {
            lastError = "Espaço acabando: gravação encerrada com segurança"
            stopRecording()   // a live continua; só a cópia local para
        }
        emitStatus()
    }
}
