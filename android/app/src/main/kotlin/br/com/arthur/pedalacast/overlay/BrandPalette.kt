package br.com.arthur.pedalacast.overlay

import android.content.Context
import android.graphics.Color
import org.json.JSONObject

/** Cores lidas de assets/brand/brand_colors.json (fonte única, sem duplicar valores). */
data class BrandPalette(
    val background: Int,
    val accent: Int,
    val live: Int,
    val text: Int,
    val warning: Int,
) {
    companion object {
        // Cores de faixa de inclinação além da paleta base (ver spec seção 6).
        val GRADE_STEEP = Color.parseColor("#D9480F")

        fun load(context: Context): BrandPalette {
            val raw = context.assets.open("flutter_assets/assets/brand/brand_colors.json")
                .bufferedReader().use { it.readText() }
            return from(JSONObject(raw))
        }

        fun from(j: JSONObject) = BrandPalette(
            background = Color.parseColor(j.getString("background")),
            accent = Color.parseColor(j.getString("accent")),
            live = Color.parseColor(j.getString("live")),
            text = Color.parseColor(j.getString("text")),
            warning = Color.parseColor(j.getString("warning")),
        )
    }
}
