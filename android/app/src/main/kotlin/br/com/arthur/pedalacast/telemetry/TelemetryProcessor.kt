package br.com.arthur.pedalacast.telemetry

/** Entrada bruta de GPS, independente de Android (facilita testes e simulação). */
data class GpsFix(
    val tMs: Long,
    val epochMs: Long,
    val lat: Double,
    val lon: Double,
    val altM: Double?,
    val speedMps: Double?,
    val accuracyM: Double?,
)

data class PhoneStatus(
    val batteryPct: Int = -1,
    val charging: Boolean = false,
    val signalLevel: Int? = null,
    val networkType: String? = null,
    val tempC: Double? = null,
)

data class ExternalSensors(val hrBpm: Int? = null, val cadenceRpm: Int? = null, val powerW: Int? = null)

/**
 * Núcleo de cálculo: recebe fixes de GPS, pressão e status do celular e produz amostras.
 * Todas as amostras usam o mesmo relógio monotônico (tMs).
 */
class TelemetryProcessor(private val hasBarometer: Boolean) {
    private val speed = SpeedSmoother()
    private val ascent = AscentCounter()
    private val grade = GradeEstimator()
    private val fuser = AltitudeFuser()
    private val dist = DistanceAccumulator()

    private val trackLock = Any()
    private val track = ArrayList<TrackPoint>()

    var phone = PhoneStatus()
    var sensors = ExternalSensors()

    @Volatile var last: TelemetrySample? = null
        private set

    fun onPressureHpa(hpa: Float) {
        // altitude barométrica padrão; só as variações importam
        val alt = 44330.0 * (1.0 - Math.pow(hpa / 1013.25, 1.0 / 5.255))
        fuser.onBaro(alt)
    }

    fun onFix(f: GpsFix): TelemetrySample {
        val altitude = f.altM?.let { fuser.onGps(it, hasBarometer) } ?: fuser.value
        val d = dist.add(f.lat, f.lon, f.tMs, f.accuracyM)
        val asc = altitude?.let { ascent.add(it) } ?: ascent.ascentM
        val g = altitude?.let { grade.add(d, it) }
        val v = speed.add(f.speedMps, f.accuracyM)
        if (altitude != null) addTrackPoint(f.lat, f.lon, altitude, d)
        val s = TelemetrySample(
            tMs = f.tMs, epochMs = f.epochMs, lat = f.lat, lon = f.lon,
            speedMps = v, altitudeM = altitude, gradePct = g,
            distanceM = d, ascentM = asc,
            hrBpm = sensors.hrBpm, cadenceRpm = sensors.cadenceRpm, powerW = sensors.powerW,
            batteryPct = phone.batteryPct, charging = phone.charging,
            signalLevel = phone.signalLevel, networkType = phone.networkType, tempC = phone.tempC,
        )
        last = s
        return s
    }

    private fun addTrackPoint(lat: Double, lon: Double, alt: Double, d: Double) {
        synchronized(trackLock) {
            val l = track.lastOrNull()
            if (l == null || d - l.distM >= 5.0) track.add(TrackPoint(lat, lon, alt, d))
        }
    }

    fun trackSnapshot(): List<TrackPoint> = synchronized(trackLock) { ArrayList(track) }
}
