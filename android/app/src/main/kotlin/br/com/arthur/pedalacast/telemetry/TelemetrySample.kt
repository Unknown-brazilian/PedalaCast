package br.com.arthur.pedalacast.telemetry

/** Uma amostra de telemetria. Campos anuláveis quando o dado pode faltar. */
data class TelemetrySample(
    val tMs: Long,            // relógio monotônico (elapsedRealtimeNanos / 1e6)
    val epochMs: Long,
    val lat: Double?,
    val lon: Double?,
    val speedMps: Double?,
    val altitudeM: Double?,   // já combinada (barômetro + GPS)
    val gradePct: Double?,
    val distanceM: Double,
    val ascentM: Double,
    val hrBpm: Int? = null,
    val cadenceRpm: Int? = null,
    val powerW: Int? = null,
    val batteryPct: Int = -1,
    val charging: Boolean = false,
    val signalLevel: Int? = null,   // 0..4
    val networkType: String? = null,
    val tempC: Double? = null,      // temperatura da bateria
) {
    fun toMap(): Map<String, Any?> = mapOf(
        "tMs" to tMs, "epochMs" to epochMs, "lat" to lat, "lon" to lon,
        "speedMps" to speedMps, "altitudeM" to altitudeM, "gradePct" to gradePct,
        "distanceM" to distanceM, "ascentM" to ascentM, "hrBpm" to hrBpm,
        "cadenceRpm" to cadenceRpm, "powerW" to powerW, "batteryPct" to batteryPct,
        "charging" to charging, "signalLevel" to signalLevel,
        "networkType" to networkType, "tempC" to tempC,
    )
}

/** Ponto do trajeto percorrido, decimado (usado no mini-mapa e no perfil). */
data class TrackPoint(val lat: Double, val lon: Double, val altM: Double, val distM: Double)
