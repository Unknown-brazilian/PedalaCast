package br.com.arthur.pedalacast.telemetry

import android.util.Xml
import java.io.InputStream
import org.xmlpull.v1.XmlPullParser

data class GpxPoint(val lat: Double, val lon: Double, val ele: Double?, val epochMs: Long?)

object GpxReader {
    const val MAX_POINTS = 200_000

    /**
     * Lê os `trkpt` de um GPX com o XmlPullParser do Android, que não resolve entidades
     * externas (sem XXE). Limita o número de pontos e valida as coordenadas.
     */
    fun read(input: InputStream): List<GpxPoint> {
        val p = Xml.newPullParser()
        p.setFeature(XmlPullParser.FEATURE_PROCESS_NAMESPACES, false)
        p.setInput(input, null)
        val out = ArrayList<GpxPoint>()
        var lat = 0.0; var lon = 0.0
        var ele: Double? = null; var time: Long? = null
        var inPoint = false
        var tag = ""
        var ev = p.eventType
        while (ev != XmlPullParser.END_DOCUMENT) {
            when (ev) {
                XmlPullParser.START_TAG -> {
                    tag = p.name
                    if (tag == "trkpt") {
                        lat = p.getAttributeValue(null, "lat").toDouble()
                        lon = p.getAttributeValue(null, "lon").toDouble()
                        require(lat in -90.0..90.0 && lon in -180.0..180.0) { "coordenada inválida" }
                        ele = null; time = null; inPoint = true
                    }
                }
                XmlPullParser.TEXT -> if (inPoint) {
                    val t = p.text.trim()
                    if (tag == "ele") ele = t.toDoubleOrNull()
                    else if (tag == "time") time = runCatching { java.time.Instant.parse(t).toEpochMilli() }.getOrNull()
                }
                XmlPullParser.END_TAG -> {
                    if (p.name == "trkpt" && inPoint) {
                        out.add(GpxPoint(lat, lon, ele, time))
                        require(out.size <= MAX_POINTS) { "GPX com pontos demais" }
                        inPoint = false
                    }
                    tag = ""
                }
            }
            ev = p.next()
        }
        return out
    }
}
