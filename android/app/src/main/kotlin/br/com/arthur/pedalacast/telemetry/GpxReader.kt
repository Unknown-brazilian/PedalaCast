package br.com.arthur.pedalacast.telemetry

import java.io.InputStream
import javax.xml.parsers.DocumentBuilderFactory

data class GpxPoint(val lat: Double, val lon: Double, val ele: Double?, val epochMs: Long?)

object GpxReader {
    const val MAX_POINTS = 200_000

    fun read(input: InputStream): List<GpxPoint> {
        val dbf = DocumentBuilderFactory.newInstance().apply {
            // sem entidades externas (XXE)
            setFeature("http://apache.org/xml/features/disallow-doctype-decl", true)
        }
        val doc = dbf.newDocumentBuilder().parse(input)
        val nodes = doc.getElementsByTagName("trkpt")
        require(nodes.length <= MAX_POINTS) { "GPX com pontos demais" }
        val out = ArrayList<GpxPoint>(nodes.length)
        for (i in 0 until nodes.length) {
            val n = nodes.item(i) as org.w3c.dom.Element
            val lat = n.getAttribute("lat").toDouble()
            val lon = n.getAttribute("lon").toDouble()
            require(lat in -90.0..90.0 && lon in -180.0..180.0) { "coordenada inválida" }
            val ele = n.getElementsByTagName("ele").item(0)?.textContent?.trim()?.toDoubleOrNull()
            val t = n.getElementsByTagName("time").item(0)?.textContent?.trim()?.let(::parseIso)
            out.add(GpxPoint(lat, lon, ele, t))
        }
        return out
    }

    private fun parseIso(s: String): Long? = runCatching {
        java.time.Instant.parse(s).toEpochMilli()
    }.getOrNull()
}
