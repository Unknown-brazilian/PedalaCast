package br.com.arthur.pedalacast.video

import android.content.Context
import android.graphics.SurfaceTexture
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager
import android.hardware.camera2.CameraMetadata
import com.pedro.encoder.input.sources.video.VideoSource
import com.pedro.encoder.input.video.Camera2ApiManager

/** Fonte de vídeo que abre uma câmera específica pelo ID (frontal ou qualquer traseira). */
class CameraIdSource(context: Context, private val cameraId: String) : VideoSource() {
    private val camera = Camera2ApiManager(context)

    override fun create(width: Int, height: Int, fps: Int, rotation: Int): Boolean {
        require(width % 2 == 0 && height % 2 == 0) { "largura e altura devem ser pares" }
        return true
    }

    override fun start(surfaceTexture: SurfaceTexture) {
        this.surfaceTexture = surfaceTexture
        if (isRunning()) return
        surfaceTexture.setDefaultBufferSize(width, height)
        camera.prepareCamera(surfaceTexture, width, height, fps, cameraId)
        camera.openCameraId(cameraId)
    }

    override fun stop() { camera.closeCamera() }
    override fun release() {}
    override fun isRunning(): Boolean = camera.isRunning
}

/** Lista as câmeras utilizáveis para vídeo, com um tipo aproximado (pela distância focal equivalente). */
object CameraCatalog {
    fun list(context: Context): List<Map<String, Any>> {
        val cm = context.getSystemService(Context.CAMERA_SERVICE) as CameraManager
        val out = ArrayList<Map<String, Any>>()
        for (id in cm.cameraIdList) {
            val ch = runCatching { cm.getCameraCharacteristics(id) }.getOrNull() ?: continue
            val caps = ch.get(CameraCharacteristics.REQUEST_AVAILABLE_CAPABILITIES) ?: intArrayOf()
            if (!caps.contains(CameraMetadata.REQUEST_AVAILABLE_CAPABILITIES_BACKWARD_COMPATIBLE)) continue
            val map = ch.get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP) ?: continue
            val sizes = map.getOutputSizes(SurfaceTexture::class.java) ?: continue
            if (sizes.none { it.width >= 1280 && it.height >= 720 }) continue   // sem 720p: inútil para o app
            val front = ch.get(CameraCharacteristics.LENS_FACING) == CameraCharacteristics.LENS_FACING_FRONT
            val focal = ch.get(CameraCharacteristics.LENS_INFO_AVAILABLE_FOCAL_LENGTHS)?.firstOrNull()
            val sensorW = ch.get(CameraCharacteristics.SENSOR_INFO_PHYSICAL_SIZE)?.width
            val equiv = if (focal != null && sensorW != null && sensorW > 0) (focal * 36f / sensorW).toInt() else 0
            val kind = when {
                front -> "front"
                equiv in 1..20 -> "ultrawide"
                equiv > 45 -> "tele"
                else -> "main"
            }
            val px = ch.get(CameraCharacteristics.SENSOR_INFO_PIXEL_ARRAY_SIZE)
            val mp = if (px != null) Math.round(px.width * px.height / 1_000_000f) else 0
            out.add(mapOf("id" to id, "facing" to if (front) "front" else "back", "kind" to kind, "equivMm" to equiv, "mp" to mp))
        }
        // frontais por último; traseiras na ordem do sistema
        return out.sortedBy { if (it["facing"] == "front") 1 else 0 }
    }
}
