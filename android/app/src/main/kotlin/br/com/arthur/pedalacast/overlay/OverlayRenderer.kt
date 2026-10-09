package br.com.arthur.pedalacast.overlay

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import android.graphics.Typeface
import br.com.arthur.pedalacast.telemetry.Geo
import br.com.arthur.pedalacast.telemetry.PrivacyZone
import br.com.arthur.pedalacast.telemetry.TelemetrySample
import br.com.arthur.pedalacast.telemetry.TrackPoint
import java.util.Locale
import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.max
import kotlin.math.min

data class LatLon(val lat: Double, val lon: Double)

/** Tudo que o renderizador precisa para desenhar um quadro de overlay. */
data class OverlayState(
    val sample: TelemetrySample?,
    val track: List<TrackPoint> = emptyList(),
    val planned: List<LatLon>? = null,
    val badge: String? = "REC",       // "REC", "AO VIVO" ou null
    val elapsedMs: Long = 0,
    val privacy: PrivacyZone? = null,
    val clockText: String = "",
)

/**
 * Desenha o overlay em um Canvas sobre um Bitmap com o tamanho do vídeo.
 * Tamanhos proporcionais à altura (referência: 720 px). Bloco sem dado não é desenhado
 * e não deixa buraco no layout. Visual definido só aqui (Kotlin).
 */
class OverlayRenderer(private val palette: BrandPalette) {
    /** Idioma e rótulos vêm do app (Flutter), para o overlay seguir o idioma escolhido. */
    @Volatile var locale: Locale = Locale("pt", "BR")
    @Volatile var hrLabel: String = "FC"
    private val ptBr get() = locale
    private val p = Paint(Paint.ANTI_ALIAS_FLAG)
    private val bold = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)

    private fun alpha(c: Int, a: Float) = Color.argb((a * 255).toInt(), Color.red(c), Color.green(c), Color.blue(c))

    /** Bloco posicionado: retângulo em pixels e a unidade de escala usada. */
    class Placed(val rect: RectF, val u: Float)

    private fun distText(s: TelemetrySample) = String.format(ptBr, "%.1f km", s.distanceM / 1000.0)
    private fun climbText(s: TelemetrySample) = String.format(ptBr, "D+ %.0f m", s.ascentM)
    private fun gradeText(g: Double) = String.format(ptBr, "%s %.0f%%", if (g >= 0) "▲" else "▼", abs(g))
    private fun liveText(label: String, elapsedMs: Long): String {
        val sec = elapsedMs / 1000
        return "$label  " + String.format(ptBr, "%02d:%02d", sec / 60, sec % 60)
    }
    private fun phoneText(s: TelemetrySample, clock: String) =
        "$clock  " + (if (s.batteryPct >= 0) "${s.batteryPct}%" else "—")

    /**
     * Calcula onde cada bloco fica. Blocos com posição própria (x, y no layout) vão exatamente
     * lá; os demais seguem o fluxo automático. Bloco sem dado não é posicionado.
     */
    @Synchronized fun place(w: Float, h: Float, layout: OverlayLayout, st: OverlayState): Map<String, Placed> {
        val out = LinkedHashMap<String, Placed>()
        val s = st.sample
        val u0 = min(w, h) / 720f   // retrato e paisagem: referência é o lado menor
        val m = 16f * u0
        fun unit(spec: BlockSpec) = u0 * spec.sizePreset.factor * (spec.scale ?: 1f)
        fun custom(spec: BlockSpec, bw: Float, bh: Float, u: Float): Placed? {
            val x = spec.x ?: return null
            val y = spec.y ?: return null
            val l = (x * w).coerceIn(0f, max(0f, w - bw))
            val t = (y * h).coerceIn(0f, max(0f, h - bh))
            return Placed(RectF(l, t, l + bw, t + bh), u)
        }

        var leftEdge = m
        var rightEdge = w - m
        var profTop = h - m

        layout.block("speed_gauge")?.let { spec ->
            val u = unit(spec); val d = 120f * u
            val pl = custom(spec, d, d, u)
            if (pl != null) out["speed_gauge"] = pl
            else { out["speed_gauge"] = Placed(RectF(m, h - m - d, m + d, h - m), u); leftEdge = m + d + 8f * u }
        }
        layout.block("distance_climb")?.takeIf { s != null }?.let { spec ->
            val u = unit(spec)
            val bw = max(measure(distText(s!!), 24f * u), measure(climbText(s), 20f * u)) + 20f * u
            val bh = 58f * u
            val pl = custom(spec, bw, bh, u)
            if (pl != null) out["distance_climb"] = pl
            else { out["distance_climb"] = Placed(RectF(leftEdge, h - m - bh, leftEdge + bw, h - m), u); leftEdge += bw + 8f * u }
        }
        layout.block("minimap")?.takeIf { !layout.hideMinimap }?.let { spec ->
            val u = unit(spec); val d = 120f * u
            val pl = custom(spec, d, d, u)
            if (pl != null) out["minimap"] = pl
            else { out["minimap"] = Placed(RectF(w - m - d, h - m - d, w - m, h - m), u); rightEdge = w - m - d - 8f * u }
        }
        layout.block("elevation_profile")?.takeIf { st.track.size >= 2 }?.let { spec ->
            val u = unit(spec); val ph = 48f * u
            val pl = custom(spec, 360f * u, ph, u)
            if (pl != null) out["elevation_profile"] = pl
            else if (rightEdge - leftEdge > 80f * u0) {
                out["elevation_profile"] = Placed(RectF(leftEdge, h - m - ph, rightEdge, h - m), u)
                profTop = h - m - ph
            }
        }
        val grade = s?.gradePct
        layout.block("grade_badge")?.takeIf { grade != null && abs(grade) >= 3.0 }?.let { spec ->
            val u = unit(spec)
            val bw = measure(gradeText(grade!!), 20f * u) + 20f * u; val bh = 30f * u
            val pl = custom(spec, bw, bh, u)
            out["grade_badge"] = pl ?: Placed(RectF(leftEdge, profTop - 8f * u - bh, leftEdge + bw, profTop - 8f * u), u)
        }

        var x = m
        layout.block("live_badge")?.takeIf { st.badge != null }?.let { spec ->
            val u = unit(spec)
            val bw = measure(liveText(st.badge!!, st.elapsedMs), 18f * u) + 36f * u; val bh = 30f * u
            val pl = custom(spec, bw, bh, u)
            if (pl != null) out["live_badge"] = pl
            else { out["live_badge"] = Placed(RectF(x, m, x + bw, m + bh), u); x += bw + 8f * u }
        }
        for ((type, unitLabel) in listOf("hr" to hrLabel, "cadence" to "RPM", "power" to "W")) {
            val spec = layout.block(type) ?: continue
            val v = when (type) { "hr" -> s?.hrBpm; "cadence" -> s?.cadenceRpm; else -> s?.powerW } ?: continue
            val u = unit(spec)
            val bw = measure("$v $unitLabel", 18f * u) + 20f * u; val bh = 30f * u
            val pl = custom(spec, bw, bh, u)
            if (pl != null) out[type] = pl
            else { out[type] = Placed(RectF(x, m, x + bw, m + bh), u); x += bw + 6f * u }
        }
        layout.block("phone_status")?.takeIf { s != null }?.let { spec ->
            val u = unit(spec)
            val bars = if (s!!.signalLevel != null) 5 * 6f * u + 8f * u else 0f
            val bw = measure(phoneText(s, st.clockText), 18f * u) + bars + 20f * u; val bh = 30f * u
            out["phone_status"] = custom(spec, bw, bh, u) ?: Placed(RectF(w - m - bw, m, w - m, m + bh), u)
        }
        return out
    }

    @Synchronized fun render(bitmap: Bitmap, layout: OverlayLayout, st: OverlayState) {
        val c = Canvas(bitmap)
        bitmap.eraseColor(Color.TRANSPARENT)
        val s = st.sample
        val placed = place(bitmap.width.toFloat(), bitmap.height.toFloat(), layout, st)
        for ((type, pl) in placed) {
            val r = pl.rect; val u = pl.u
            when (type) {
                "speed_gauge" -> drawGauge(c, r, s?.speedMps?.times(3.6), u)
                "distance_climb" -> s?.let { drawDistanceClimb(c, r.left, r.bottom, u, it) }
                "minimap" -> drawMinimap(c, r, layout, st)
                "elevation_profile" -> drawProfile(c, r, st.track)
                "grade_badge" -> s?.gradePct?.let { drawGradeBadge(c, r.left, r.bottom, it, u) }
                "live_badge" -> st.badge?.let { drawLiveBadge(c, r.left, r.top, u, it, st.elapsedMs) }
                "hr" -> s?.hrBpm?.let { drawChip(c, r.left, r.top, u, "$it", hrLabel) }
                "cadence" -> s?.cadenceRpm?.let { drawChip(c, r.left, r.top, u, "$it", "RPM") }
                "power" -> s?.powerW?.let { drawChip(c, r.left, r.top, u, "$it", "W") }
                "phone_status" -> s?.let { drawPhoneStatus(c, r.right, r.top, u, it, st.clockText) }
            }
        }
    }

    private fun panel(c: Canvas, r: RectF, radius: Float, a: Float = 0.55f) {
        p.style = Paint.Style.FILL
        p.color = alpha(palette.background, a)
        c.drawRoundRect(r, radius, radius, p)
    }

    private fun text(c: Canvas, t: String, x: Float, y: Float, size: Float, color: Int = palette.text, align: Paint.Align = Paint.Align.LEFT) {
        p.style = Paint.Style.FILL
        p.typeface = bold
        p.textSize = size
        p.color = color
        p.textAlign = align
        c.drawText(t, x, y, p)
    }

    private fun drawGauge(c: Canvas, r: RectF, kmh: Double?, u: Float) {
        val cx = r.centerX(); val cy = r.centerY()
        p.style = Paint.Style.FILL
        p.color = alpha(palette.background, 0.55f)
        c.drawCircle(cx, cy, r.width() / 2, p)
        val stroke = 9f * u
        val arc = RectF(r.left + stroke, r.top + stroke, r.right - stroke, r.bottom - stroke)
        p.style = Paint.Style.STROKE
        p.strokeWidth = stroke
        p.strokeCap = Paint.Cap.ROUND
        p.color = alpha(palette.text, 0.30f)
        c.drawArc(arc, 135f, 270f, false, p)             // trilha: 270° com abertura embaixo
        if (kmh != null) {
            val frac = (kmh / 60.0).coerceIn(0.0, 1.0).toFloat()
            p.color = palette.accent
            if (frac > 0f) c.drawArc(arc, 135f, 270f * frac, false, p)
        }
        val num = if (kmh == null) "—" else String.format(ptBr, "%.0f", kmh)
        text(c, num, cx, cy + 14f * u, 44f * u, palette.text, Paint.Align.CENTER)
        text(c, "km/h", cx, r.bottom - 6f * u, 13f * u, alpha(palette.text, 0.8f), Paint.Align.CENTER)
    }

    /** Retorna a largura ocupada. */
    private fun drawDistanceClimb(c: Canvas, x: Float, bottom: Float, u: Float, s: TelemetrySample): Float {
        val dist = String.format(ptBr, "%.1f km", s.distanceM / 1000.0)
        val climb = String.format(ptBr, "D+ %.0f m", s.ascentM)
        val tw = max(measure(dist, 24f * u), measure(climb, 20f * u))
        val r = RectF(x, bottom - 58f * u, x + tw + 20f * u, bottom)
        panel(c, r, 10f * u)
        text(c, dist, r.left + 10f * u, r.top + 26f * u, 24f * u)
        text(c, climb, r.left + 10f * u, r.top + 49f * u, 20f * u, palette.accent)
        return r.width()
    }

    private fun measure(t: String, size: Float): Float {
        p.typeface = bold; p.textSize = size
        return p.measureText(t)
    }

    private fun drawProfile(c: Canvas, r: RectF, track: List<TrackPoint>) {
        panel(c, r, 8f, 0.35f)
        val minA = track.minOf { it.altM }
        val maxA = max(track.maxOf { it.altM }, minA + 10.0)
        val total = max(track.last().distM, 1.0)
        val pad = 4f
        val inner = RectF(r.left + pad, r.top + pad, r.right - pad, r.bottom - pad)
        fun px(t: TrackPoint) = inner.left + (t.distM / total).toFloat() * inner.width()
        fun py(t: TrackPoint) = inner.bottom - ((t.altM - minA) / (maxA - minA)).toFloat() * inner.height()
        val path = Path().apply {
            moveTo(px(track.first()), inner.bottom)
            track.forEach { lineTo(px(it), py(it)) }
            lineTo(px(track.last()), inner.bottom)
            close()
        }
        p.style = Paint.Style.FILL
        p.color = alpha(palette.accent, 0.85f)
        c.drawPath(path, p)
        val cur = track.last()
        p.color = palette.text
        c.drawCircle(px(cur), py(cur), 4f, p)
    }

    private fun drawGradeBadge(c: Canvas, x: Float, bottom: Float, grade: Double, u: Float) {
        val col = when {
            abs(grade) > 10 -> BrandPalette.GRADE_STEEP
            abs(grade) >= 6 -> palette.accent
            else -> palette.warning
        }
        val t = String.format(ptBr, "%s %.0f%%", if (grade >= 0) "▲" else "▼", abs(grade))
        val tw = measure(t, 20f * u)
        val r = RectF(x, bottom - 30f * u, x + tw + 20f * u, bottom)
        p.style = Paint.Style.FILL
        p.color = col
        c.drawRoundRect(r, 15f * u, 15f * u, p)
        text(c, t, r.left + 10f * u, r.bottom - 8f * u, 20f * u, palette.background)
    }

    private fun drawLiveBadge(c: Canvas, x: Float, y: Float, u: Float, label: String, elapsedMs: Long): Float {
        val sec = elapsedMs / 1000
        val time = String.format(ptBr, "%02d:%02d", sec / 60, sec % 60)
        val t = "$label  $time"
        val tw = measure(t, 18f * u)
        val r = RectF(x, y, x + tw + 36f * u, y + 30f * u)
        panel(c, r, 15f * u, 0.55f)
        p.style = Paint.Style.FILL
        p.color = palette.live            // vermelho só para REC / AO VIVO
        c.drawCircle(r.left + 14f * u, r.centerY(), 6f * u, p)
        text(c, t, r.left + 26f * u, r.bottom - 8f * u, 18f * u)
        return r.width()
    }

    private fun drawChip(c: Canvas, x: Float, y: Float, u: Float, value: String, unit: String): Float {
        val t = "$value $unit"
        val tw = measure(t, 18f * u)
        val r = RectF(x, y, x + tw + 20f * u, y + 30f * u)
        panel(c, r, 15f * u)
        text(c, value, r.left + 10f * u, r.bottom - 8f * u, 18f * u, palette.accent)
        text(c, unit, r.left + 10f * u + measure("$value ", 18f * u), r.bottom - 8f * u, 18f * u)
        return r.width()
    }

    private fun drawPhoneStatus(c: Canvas, right: Float, y: Float, u: Float, s: TelemetrySample, clock: String) {
        val bat = if (s.batteryPct >= 0) "${s.batteryPct}%" else "—"
        val t = "$clock  $bat"
        val tw = measure(t, 18f * u)
        val bars = if (s.signalLevel != null) 5 * 6f * u + 8f * u else 0f
        val r = RectF(right - tw - bars - 20f * u, y, right, y + 30f * u)
        panel(c, r, 15f * u)
        var bx = r.left + 10f * u
        s.signalLevel?.let { lvl ->
            for (i in 0 until 4) {
                p.style = Paint.Style.FILL
                p.color = if (i < lvl) palette.text else alpha(palette.text, 0.3f)
                val bh = (6f + i * 4f) * u
                c.drawRect(bx, r.bottom - 7f * u - bh, bx + 4f * u, r.bottom - 7f * u, p)
                bx += 6f * u
            }
            bx += 8f * u
        }
        text(c, t, bx, r.bottom - 8f * u, 18f * u)
    }

    private fun drawMinimap(c: Canvas, r: RectF, layout: OverlayLayout, st: OverlayState) {
        val cx = r.centerX(); val cy = r.centerY(); val rad = r.width() / 2
        p.style = Paint.Style.FILL
        p.color = alpha(palette.background, 0.6f)
        c.drawCircle(cx, cy, rad, p)
        val s = st.sample
        val lat = s?.lat; val lon = s?.lon
        if (lat != null && lon != null) {
            c.save()
            val clip = Path().apply { addCircle(cx, cy, rad - 2f, Path.Direction.CW) }
            c.clipPath(clip)

            val visible = st.track.filter { st.privacy?.contains(it.lat, it.lon) != true }
            val recent = if (layout.minimapFullTrack || visible.isEmpty()) visible else {
                val from = visible.last().distM - 2000.0
                visible.filter { it.distM >= from }
            }
            // extensão em metros (projeção equiretangular local)
            val kx = 111_320.0 * cos(Math.toRadians(lat))
            val ky = 110_540.0
            fun mx(lo: Double) = (lo - lon) * kx
            fun my(la: Double) = (la - lat) * ky
            var ext = 150.0
            if (layout.minimapFullTrack) {
                visible.forEach { ext = max(ext, max(abs(mx(it.lon)), abs(my(it.lat)))) }
            } else recent.forEach { ext = max(ext, max(abs(mx(it.lon)), abs(my(it.lat)))) }
            ext = min(ext * 1.15, 5000.0)
            val scale = ((rad - 8f) / ext).toFloat()
            fun sx(lo: Double) = cx + (mx(lo) * scale).toFloat()
            fun sy(la: Double) = cy - (my(la) * scale).toFloat()

            p.style = Paint.Style.STROKE
            p.strokeCap = Paint.Cap.ROUND
            p.strokeJoin = Paint.Join.ROUND
            st.planned?.takeIf { it.size >= 2 }?.let { route ->
                val path = Path()
                route.forEachIndexed { i, pt -> if (i == 0) path.moveTo(sx(pt.lon), sy(pt.lat)) else path.lineTo(sx(pt.lon), sy(pt.lat)) }
                p.strokeWidth = 3f * (r.width() / 120f)
                p.color = alpha(palette.text, 0.40f)
                c.drawPath(path, p)
            }
            if (recent.size >= 2) {
                val path = Path()
                recent.forEachIndexed { i, pt -> if (i == 0) path.moveTo(sx(pt.lon), sy(pt.lat)) else path.lineTo(sx(pt.lon), sy(pt.lat)) }
                p.strokeWidth = 4f * (r.width() / 120f)
                p.color = palette.accent
                c.drawPath(path, p)
            }
            if (st.privacy?.contains(lat, lon) != true) {
                p.style = Paint.Style.FILL
                p.color = palette.accent
                c.drawCircle(cx, cy, 6f * (r.width() / 120f), p)
                p.style = Paint.Style.STROKE
                p.strokeWidth = 2.5f * (r.width() / 120f)
                p.color = palette.text
                c.drawCircle(cx, cy, 6f * (r.width() / 120f), p)
            }
            c.restore()
        }
        p.style = Paint.Style.STROKE
        p.strokeWidth = 2f * (r.width() / 120f)
        p.color = alpha(palette.text, 0.8f)
        c.drawCircle(cx, cy, rad - 1f, p)
    }

    companion object {
        /** Distância em metros entre duas coordenadas (reexportada p/ conveniência dos testes). */
        fun meters(a: LatLon, b: LatLon) = Geo.haversine(a.lat, a.lon, b.lat, b.lon)
    }
}
