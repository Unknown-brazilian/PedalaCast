package br.com.arthur.pedalacast.overlay

import org.json.JSONArray
import org.json.JSONObject

enum class SizePreset(val factor: Float) {
    small(1.0f), medium(1.45f), large(2.0f);

    companion object {
        fun parse(s: String?) = entries.firstOrNull { it.name == s } ?: small
    }
}

data class BlockSpec(
    val id: String,
    val type: String,
    val enabled: Boolean,
    val anchor: String,
    val sizePreset: SizePreset,
    /** Posição própria (canto superior esquerdo, fração do quadro 0..1). null = automática. */
    val x: Float? = null,
    val y: Float? = null,
    /** Multiplicador de tamanho deste bloco (1 = tamanho do preset). */
    val scale: Float? = null,
)

/** Layout do overlay. O Flutter edita e salva o JSON; o Kotlin só lê e desenha. */
data class OverlayLayout(
    val blocks: List<BlockSpec>,
    val minimapFullTrack: Boolean = false,
    val hideMinimap: Boolean = false,
    val privacyRadiusM: Double = 300.0,
) {
    fun block(type: String) = blocks.firstOrNull { it.type == type && it.enabled }

    companion object {
        val TYPES = listOf(
            "speed_gauge", "distance_climb", "minimap", "elevation_profile", "grade_badge",
            "hr", "cadence", "power", "phone_status", "live_badge", "pip",
        )

        fun default() = OverlayLayout(
            TYPES.map {
                BlockSpec(
                    id = it, type = it, anchor = "auto", sizePreset = SizePreset.small,
                    enabled = it != "phone_status" && it != "pip",
                )
            }
        )

        fun parse(json: String?): OverlayLayout {
            if (json.isNullOrBlank()) return default()
            return runCatching {
                val o = JSONObject(json)
                val arr: JSONArray = o.getJSONArray("blocks")
                val blocks = (0 until arr.length()).map {
                    val b = arr.getJSONObject(it)
                    BlockSpec(
                        id = b.optString("id", b.getString("type")),
                        type = b.getString("type"),
                        enabled = b.optBoolean("enabled", true),
                        anchor = b.optString("anchor", "auto"),
                        sizePreset = SizePreset.parse(b.optString("sizePreset", "small")),
                        x = if (b.has("x") && b.has("y")) b.getDouble("x").toFloat() else null,
                        y = if (b.has("x") && b.has("y")) b.getDouble("y").toFloat() else null,
                        scale = if (b.has("scale")) b.getDouble("scale").toFloat().coerceIn(0.4f, 3f) else null,
                    )
                }
                OverlayLayout(
                    blocks,
                    minimapFullTrack = o.optBoolean("minimapFullTrack", false),
                    hideMinimap = o.optBoolean("hideMinimap", false),
                    privacyRadiusM = o.optDouble("privacyRadiusM", 300.0),
                )
            }.getOrElse { default() }
        }
    }
}
