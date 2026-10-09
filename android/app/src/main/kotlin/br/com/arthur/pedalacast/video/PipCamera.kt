package br.com.arthur.pedalacast.video

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.ImageFormat
import android.graphics.Paint
import android.graphics.Path
import android.graphics.Rect
import android.graphics.RectF
import android.graphics.YuvImage
import android.hardware.camera2.CameraCaptureSession
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraDevice
import android.hardware.camera2.CameraManager
import android.media.Image
import android.media.ImageReader
import android.os.Build
import android.os.Handler
import android.os.HandlerThread
import android.os.SystemClock
import java.io.ByteArrayOutputStream

/**
 * Picture-in-picture: abre a câmera frontal ao mesmo tempo que a traseira (só em aparelhos que
 * declaram uma combinação concorrente frontal+traseira) e entrega quadros prontos (girados, com cantos
 * arredondados) para o compositor. Os quadros vão para um Bitmap pequeno, atualizado a ~15 fps,
 * para não reenviar o overlay inteiro à GPU a cada quadro.
 */
class PipCamera(private val ctx: Context) {
    private val cm = ctx.getSystemService(Context.CAMERA_SERVICE) as CameraManager
    private var thread: HandlerThread? = null
    private var handler: Handler? = null
    private var device: CameraDevice? = null
    private var session: CameraCaptureSession? = null
    private var reader: ImageReader? = null
    @Volatile private var running = false
    private var lastMs = 0L

    /** Tamanho alvo do Bitmap do PIP (pixels do vídeo) e rotação, atualizados pelo núcleo. */
    @Volatile var targetW = 240
    @Volatile var targetH = 320
    @Volatile var onFrame: ((Bitmap) -> Unit)? = null
    @Volatile var onError: ((String) -> Unit)? = null

    var frontId: String? = null
        private set
    var rotation = 0   // graus horários para deixar a imagem em pé
        private set
    /** Proporção (largura/altura) da imagem já em pé. */
    var uprightAspect = 3f / 4f
        private set

    private val bitmaps = arrayOfNulls<Bitmap>(2)
    private var bi = 0

    companion object {
        /**
         * Retorna o ID da frontal que pode rodar junto com a traseira [backId], ou null.
         * Exige API 30+ e uma combinação concorrente declarada pelo fabricante.
         */
        fun frontIdFor(ctx: Context, backId: String?): String? {
            if (Build.VERSION.SDK_INT < 30) return null
            val cm = ctx.getSystemService(Context.CAMERA_SERVICE) as CameraManager
            fun facing(id: String) = runCatching {
                cm.getCameraCharacteristics(id).get(CameraCharacteristics.LENS_FACING)
            }.getOrNull()
            for (set in cm.concurrentCameraIds) {
                if (backId != null && backId !in set) continue
                if (backId == null && set.none { facing(it) == CameraCharacteristics.LENS_FACING_BACK }) continue
                val front = set.firstOrNull { facing(it) == CameraCharacteristics.LENS_FACING_FRONT }
                if (front != null) return front
            }
            return null
        }
    }

    @SuppressLint("MissingPermission")
    fun start(frontId: String, portraitVideo: Boolean) {
        stop()
        this.frontId = frontId
        val ch = cm.getCameraCharacteristics(frontId)
        val sensor = ch.get(CameraCharacteristics.SENSOR_ORIENTATION) ?: 270
        // Mesma suposição do vídeo principal: rotation=0 => celular na horizontal (display 90°); vertical => 0°.
        val display = if (portraitVideo) 0 else 90
        rotation = (sensor + display) % 360          // frontal: sensor + display
        val map = ch.get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP)
        val size = map?.getOutputSizes(ImageFormat.YUV_420_888)
            ?.filter { it.width <= 800 && it.width * 3 == it.height * 4 }   // 4:3 pequeno
            ?.maxByOrNull { it.width } ?: map?.getOutputSizes(ImageFormat.YUV_420_888)?.minByOrNull { it.width * it.height }
            ?: throw IllegalStateException("frontal sem YUV")
        uprightAspect = if (rotation % 180 == 0) size.width.toFloat() / size.height else size.height.toFloat() / size.width
        val t = HandlerThread("pip").also { it.start() }
        thread = t
        val h = Handler(t.looper)
        handler = h
        running = true
        val r = ImageReader.newInstance(size.width, size.height, ImageFormat.YUV_420_888, 3)
        reader = r
        r.setOnImageAvailableListener({ rd ->
            val img = rd.acquireLatestImage() ?: return@setOnImageAvailableListener
            try {
                val now = SystemClock.elapsedRealtime()
                if (running && now - lastMs >= 66) { lastMs = now; handleFrame(img) }
            } catch (e: Exception) {
                onError?.invoke(e.message ?: "erro no PIP")
            } finally { img.close() }
        }, h)
        cm.openCamera(frontId, object : CameraDevice.StateCallback() {
            override fun onOpened(camera: CameraDevice) {
                device = camera
                runCatching {
                    @Suppress("DEPRECATION")
                    camera.createCaptureSession(listOf(r.surface), object : CameraCaptureSession.StateCallback() {
                        override fun onConfigured(s: CameraCaptureSession) {
                            session = s
                            val req = camera.createCaptureRequest(CameraDevice.TEMPLATE_PREVIEW).apply { addTarget(r.surface) }
                            runCatching { s.setRepeatingRequest(req.build(), null, h) }
                                .onFailure { onError?.invoke(it.message ?: "PIP: falha ao iniciar") }
                        }
                        override fun onConfigureFailed(s: CameraCaptureSession) { onError?.invoke("PIP: configuração recusada") }
                    }, h)
                }.onFailure { onError?.invoke(it.message ?: "PIP: sessão") }
            }
            override fun onDisconnected(camera: CameraDevice) { camera.close(); onError?.invoke("PIP: câmera desconectada") }
            override fun onError(camera: CameraDevice, error: Int) { camera.close(); onError?.invoke("PIP: erro $error (o aparelho pode não suportar duas câmeras)") }
        }, h)
    }

    fun stop() {
        running = false
        runCatching { session?.close() }; session = null
        runCatching { device?.close() }; device = null
        runCatching { reader?.close() }; reader = null
        thread?.quitSafely(); thread = null; handler = null
    }

    private fun handleFrame(img: Image) {
        val w = img.width; val h = img.height
        val nv21 = toNv21(img)
        val baos = ByteArrayOutputStream()
        YuvImage(nv21, ImageFormat.NV21, w, h, null).compressToJpeg(Rect(0, 0, w, h), 80, baos)
        val src = BitmapFactory.decodeByteArray(baos.toByteArray(), 0, baos.size()) ?: return
        val bw = targetW.coerceAtLeast(16); val bh = targetH.coerceAtLeast(16)
        var bm = bitmaps[bi]
        if (bm == null || bm.width != bw || bm.height != bh) { bm = Bitmap.createBitmap(bw, bh, Bitmap.Config.ARGB_8888); bitmaps[bi] = bm }
        bi = 1 - bi
        bm.eraseColor(0)
        val c = Canvas(bm)
        val radius = minOf(bw, bh) * 0.12f
        c.save()
        c.clipPath(Path().apply { addRoundRect(RectF(0f, 0f, bw.toFloat(), bh.toFloat()), radius, radius, Path.Direction.CW) })
        val sw = if (rotation % 180 == 0) w else h
        val sh = if (rotation % 180 == 0) h else w
        val scale = maxOf(bw.toFloat() / sw, bh.toFloat() / sh)         // preenche (corta o excesso)
        c.translate(bw / 2f, bh / 2f)
        c.rotate(rotation.toFloat())
        c.scale(scale, scale)
        c.translate(-w / 2f, -h / 2f)
        c.drawBitmap(src, 0f, 0f, null)
        c.restore()
        val p = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.STROKE; strokeWidth = minOf(bw, bh) * 0.025f; color = 0xCCFFFFFF.toInt() }
        c.drawRoundRect(RectF(p.strokeWidth / 2, p.strokeWidth / 2, bw - p.strokeWidth / 2, bh - p.strokeWidth / 2), radius, radius, p)
        src.recycle()
        onFrame?.invoke(bm)
    }

    /** YUV_420_888 -> NV21 respeitando strides. */
    private fun toNv21(img: Image): ByteArray {
        val w = img.width; val h = img.height
        val out = ByteArray(w * h * 3 / 2)
        val y = img.planes[0]; val u = img.planes[1]; val v = img.planes[2]
        var pos = 0
        for (row in 0 until h) {
            y.buffer.position(row * y.rowStride)
            y.buffer.get(out, pos, w); pos += w
        }
        val cw = w / 2; val ch = h / 2
        for (row in 0 until ch) {
            for (col in 0 until cw) {
                val vi = row * v.rowStride + col * v.pixelStride
                val ui = row * u.rowStride + col * u.pixelStride
                out[pos++] = v.buffer.get(vi)
                out[pos++] = u.buffer.get(ui)
            }
        }
        return out
    }
}
