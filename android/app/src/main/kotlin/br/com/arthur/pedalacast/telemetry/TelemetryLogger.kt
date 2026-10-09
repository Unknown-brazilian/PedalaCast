package br.com.arthur.pedalacast.telemetry

import java.io.OutputStream
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone

/**
 * Escrita incremental de GPX e JSON (JSON Lines dentro de um array fechável).
 * Faz flush a cada amostra para não perder dados se o app morrer.
 * O JSON é gravado como um objeto por linha; se o app morrer, o arquivo ainda é legível
 * (só falta o "]" final, que [close] escreve).
 */
class TelemetryLogger(private val gpx: OutputStream, private val json: OutputStream, name: String) {
    private val iso = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.US).apply {
        timeZone = TimeZone.getTimeZone("UTC")
    }
    private var firstJson = true
    private var closed = false

    init {
        gpx.write(
            ("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
                "<gpx version=\"1.1\" creator=\"PedalaCast\" xmlns=\"http://www.topografix.com/GPX/1/1\">\n" +
                "<trk><name>${esc(name)}</name><trkseg>\n").toByteArray()
        )
        json.write("[\n".toByteArray())
        gpx.flush(); json.flush()
    }

    @Synchronized
    fun log(s: TelemetrySample) {
        if (closed) return
        if (s.lat != null && s.lon != null) {
            val sb = StringBuilder()
            sb.append("<trkpt lat=\"${s.lat}\" lon=\"${s.lon}\">")
            s.altitudeM?.let { sb.append("<ele>${"%.1f".format(Locale.US, it)}</ele>") }
            sb.append("<time>${iso.format(Date(s.epochMs))}</time>")
            sb.append("</trkpt>\n")
            gpx.write(sb.toString().toByteArray())
            gpx.flush()
        }
        json.write(((if (firstJson) "" else ",\n") + toJson(s)).toByteArray())
        json.flush()
        firstJson = false
    }

    @Synchronized
    fun close() {
        if (closed) return
        closed = true
        runCatching {
            gpx.write("</trkseg></trk></gpx>\n".toByteArray()); gpx.flush(); gpx.close()
        }
        runCatching {
            json.write("\n]\n".toByteArray()); json.flush(); json.close()
        }
    }

    companion object {
        private fun esc(s: String) = s.replace("&", "&amp;").replace("<", "&lt;")

        fun toJson(s: TelemetrySample): String {
            val m = s.toMap()
            return m.entries.joinToString(",", "{", "}") { (k, v) ->
                "\"$k\":" + when (v) {
                    null -> "null"
                    is String -> "\"" + v.replace("\\", "\\\\").replace("\"", "\\\"") + "\""
                    is Double -> if (v.isNaN() || v.isInfinite()) "null" else v.toString()
                    else -> v.toString()
                }
            }
        }
    }
}
