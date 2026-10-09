package br.com.arthur.pedalacast.channels

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.view.Surface
import android.view.WindowManager
import androidx.core.content.ContextCompat
import br.com.arthur.pedalacast.video.PedalaCore
import br.com.arthur.pedalacast.video.RecordingService
import br.com.arthur.pedalacast.video.Storage
import br.com.arthur.pedalacast.video.VideoConfig
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.TextureRegistry

/** Ponte Flutter ⇄ Kotlin. Controle por MethodChannel, telemetria e status por EventChannel. */
class Channels(private val activity: Activity, engine: FlutterEngine) {
    private val main = Handler(Looper.getMainLooper())
    private val textures: TextureRegistry = engine.renderer
    private var entry: TextureRegistry.SurfaceTextureEntry? = null
    private var surface: Surface? = null
    private var telemetrySink: EventChannel.EventSink? = null
    private var statusSink: EventChannel.EventSink? = null
    private var statusTicker: Runnable? = null

    init {
        PedalaCore.init(activity)
        val messenger = engine.dartExecutor.binaryMessenger
        MethodChannel(messenger, "pedalacast/control").setMethodCallHandler(::onCall)
        EventChannel(messenger, "pedalacast/telemetry").setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(a: Any?, s: EventChannel.EventSink) {
                telemetrySink = s
                PedalaCore.onSample = { sample -> main.post { telemetrySink?.success(sample.toMap()) } }
            }
            override fun onCancel(a: Any?) { telemetrySink = null; PedalaCore.onSample = null }
        })
        EventChannel(messenger, "pedalacast/status").setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(a: Any?, s: EventChannel.EventSink) {
                statusSink = s
                PedalaCore.onStatus = { m -> main.post { statusSink?.success(m) } }
                val r = object : Runnable {
                    override fun run() { PedalaCore.emitStatus(); main.postDelayed(this, 1000L) }
                }
                statusTicker = r; main.post(r)
            }
            override fun onCancel(a: Any?) {
                statusSink = null; PedalaCore.onStatus = null
                statusTicker?.let(main::removeCallbacks)
            }
        })
    }

    @Suppress("UNCHECKED_CAST")
    private fun onCall(call: io.flutter.plugin.common.MethodCall, result: MethodChannel.Result) {
        val a = (call.arguments as? Map<String, Any?>) ?: emptyMap()
        when (call.method) {
            "startPreview" -> {
                val cfg = VideoConfig(
                    width = (a["width"] as? Int) ?: 1920, height = (a["height"] as? Int) ?: 1080,
                    fps = (a["fps"] as? Int) ?: 30, bitrate = (a["bitrate"] as? Int) ?: 12_000_000,
                    micEnabled = (a["mic"] as? Boolean) ?: true, autoPause = (a["autoPause"] as? Boolean) ?: false,
                )
                PedalaCore.simulation = (a["simulation"] as? Boolean) ?: false
                PedalaCore.setLayout(a["layout"] as? String)
                releaseTexture()
                val e = textures.createSurfaceTexture()
                e.surfaceTexture().setDefaultBufferSize(cfg.width, cfg.height)
                val s = Surface(e.surfaceTexture())
                entry = e; surface = s
                PedalaCore.startPreview(s, cfg)
                    .onSuccess { result.success(e.id()) }
                    .onFailure { releaseTexture(); result.error("preview", it.message, null) }
            }
            "stopPreview" -> { PedalaCore.stopPreview(); releaseTexture(); result.success(null) }
            "startRecording" -> {
                ContextCompat.startForegroundService(activity, Intent(activity, RecordingService::class.java))
                PedalaCore.startRecording()
                    .onSuccess { result.success(null) }
                    .onFailure {
                        activity.stopService(Intent(activity, RecordingService::class.java))
                        result.error("record", it.message, null)
                    }
            }
            "stopRecording" -> {
                val uri = PedalaCore.stopRecording()
                activity.stopService(Intent(activity, RecordingService::class.java))
                result.success(uri)
            }
            "pauseRecording" -> { PedalaCore.pauseRecording(); result.success(null) }
            "resumeRecording" -> { PedalaCore.resumeRecording(); result.success(null) }
            "setLayout" -> { PedalaCore.setLayout(a["layout"] as? String); result.success(null) }
            "setSimulation" -> {
                PedalaCore.simulation = (a["enabled"] as? Boolean) ?: false
                if (PedalaCore.engine.running) PedalaCore.restartTelemetry()
                result.success(null)
            }
            "setKeepScreenOn" -> {
                val on = (a["enabled"] as? Boolean) ?: false
                if (on) activity.window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                else activity.window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                result.success(null)
            }
            "renderDebugPng" -> Thread {
                runCatching { PedalaCore.renderDebugPng(a["layout"] as? String) }
                    .onSuccess { main.post { result.success(it) } }
                    .onFailure { main.post { result.error("debug", it.message, null) } }
            }.start()
            "needsBackgroundHelp" -> {
                val m = android.os.Build.MANUFACTURER.lowercase()
                val aggressive = m in listOf("xiaomi", "redmi", "poco", "oppo", "realme", "oneplus", "vivo", "huawei", "honor")
                val pm = activity.getSystemService(android.os.PowerManager::class.java)
                val unrestricted = pm.isIgnoringBatteryOptimizations(activity.packageName)
                result.success(aggressive && !unrestricted)
            }
            "openBatterySettings" -> {
                val i = Intent(android.provider.Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
                runCatching { activity.startActivity(i) }.onFailure {
                    activity.startActivity(Intent(android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:" + activity.packageName)))
                }
                result.success(null)
            }
            "openAutostartSettings" -> {
                val xiaomi = Intent().setClassName("com.miui.securitycenter", "com.miui.permcenter.autostart.AutoStartManagementActivity")
                runCatching { activity.startActivity(xiaomi) }.onFailure {
                    activity.startActivity(Intent(android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:" + activity.packageName)))
                }
                result.success(null)
            }
            "hasBarometer" -> result.success(PedalaCore.hasBarometer())
            "listRecordings" -> result.success(Storage.list(activity))
            "openRecording" -> {
                val i = Intent(Intent.ACTION_VIEW).setDataAndType(Uri.parse(a["uri"] as String), "video/mp4")
                    .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                runCatching { activity.startActivity(i) }
                result.success(null)
            }
            "shareRecording" -> {
                val i = Intent(Intent.ACTION_SEND).setType("video/mp4")
                    .putExtra(Intent.EXTRA_STREAM, Uri.parse(a["uri"] as String))
                    .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                activity.startActivity(Intent.createChooser(i, null))
                result.success(null)
            }
            "deleteRecording" -> {
                Storage.deleteQuietly(activity, Uri.parse(a["uri"] as String))
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun releaseTexture() {
        surface?.release(); entry?.release()
        surface = null; entry = null
    }

    fun dispose() {
        // Se estiver gravando, o serviço mantém o pipeline vivo; senão libera a câmera.
        if (PedalaCore.state == PedalaCore.State.PREVIEW) PedalaCore.stopPreview()
        releaseTexture()
    }
}
