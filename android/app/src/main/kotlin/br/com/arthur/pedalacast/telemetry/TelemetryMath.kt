package br.com.arthur.pedalacast.telemetry

import kotlin.math.asin
import kotlin.math.cos
import kotlin.math.max
import kotlin.math.min
import kotlin.math.sin
import kotlin.math.sqrt

object Geo {
    private const val R = 6_371_000.0

    fun haversine(lat1: Double, lon1: Double, lat2: Double, lon2: Double): Double {
        val dLat = Math.toRadians(lat2 - lat1)
        val dLon = Math.toRadians(lon2 - lon1)
        val a = sin(dLat / 2).let { it * it } +
            cos(Math.toRadians(lat1)) * cos(Math.toRadians(lat2)) * sin(dLon / 2).let { it * it }
        return 2 * R * asin(min(1.0, sqrt(a)))
    }
}

/** Média móvel da velocidade (3–5 amostras). Precisão ruim => null ("—"). */
class SpeedSmoother(private val window: Int = 4, private val maxAccuracyM: Double = 25.0) {
    private val buf = ArrayDeque<Double>()

    fun add(speedMps: Double?, accuracyM: Double?): Double? {
        if (speedMps == null || (accuracyM != null && accuracyM > maxAccuracyM)) {
            buf.clear()
            return null
        }
        buf.addLast(max(0.0, speedMps))
        while (buf.size > window) buf.removeFirst()
        return buf.average()
    }
}

/** Soma só das subidas, com histerese (padrão 2,5 m). */
class AscentCounter(private val hysteresisM: Double = 2.5) {
    var ascentM = 0.0
        private set
    private var ref: Double? = null

    fun add(altM: Double): Double {
        val r = ref
        if (r == null) {
            ref = altM
        } else if (altM - r >= hysteresisM) {
            ascentM += altM - r
            ref = altM
        } else if (r - altM >= hysteresisM) {
            ref = altM
        }
        return ascentM
    }
}

/** Inclinação (%) sobre uma janela deslizante do trecho já percorrido (50–100 m). */
class GradeEstimator(private val minWindowM: Double = 50.0, private val maxWindowM: Double = 100.0) {
    private data class P(val dist: Double, val alt: Double)

    private val pts = ArrayDeque<P>()

    fun add(distM: Double, altM: Double): Double? {
        pts.addLast(P(distM, altM))
        // descarta pontos fora da janela máxima, mantendo um ponto de referência além do mínimo
        while (pts.size > 2 && distM - pts[1].dist >= maxWindowM) pts.removeFirst()
        val first = pts.first()
        val span = distM - first.dist
        if (span < minWindowM) return null
        return (altM - first.alt) / span * 100.0
    }
}

/** Filtro complementar: barômetro para variações, GPS como âncora lenta. */
class AltitudeFuser(private val gpsGain: Double = 0.02) {
    private var fused: Double? = null
    private var lastBaro: Double? = null

    fun onBaro(baroAltM: Double) {
        val last = lastBaro
        lastBaro = baroAltM
        val f = fused
        if (last != null && f != null) fused = f + (baroAltM - last)
    }

    /** [hasBaro] false => usa só o GPS (suavizado). */
    fun onGps(gpsAltM: Double, hasBaro: Boolean): Double {
        val f = fused
        fused = when {
            f == null -> gpsAltM
            hasBaro -> f + gpsGain * (gpsAltM - f)
            else -> f + 0.3 * (gpsAltM - f)
        }
        return fused!!
    }

    val value: Double? get() = fused
}

/** Acumula distância ignorando saltos de GPS e paradas. */
class DistanceAccumulator(
    private val maxSpeedMps: Double = 25.0,
    private val minStepM: Double = 2.0,
    private val maxAccuracyM: Double = 30.0,
) {
    var distanceM = 0.0
        private set
    private var lastLat: Double? = null
    private var lastLon: Double? = null
    private var lastTMs: Long? = null

    fun add(lat: Double, lon: Double, tMs: Long, accuracyM: Double?): Double {
        if (accuracyM != null && accuracyM > maxAccuracyM) return distanceM
        val la = lastLat; val lo = lastLon; val lt = lastTMs
        if (la == null || lo == null || lt == null) {
            lastLat = lat; lastLon = lon; lastTMs = tMs
            return distanceM
        }
        val step = Geo.haversine(la, lo, lat, lon)
        val dt = (tMs - lt) / 1000.0
        if (dt <= 0) return distanceM
        if (step / dt > maxSpeedMps) return distanceM        // salto de GPS
        if (step < minStepM) return distanceM                // parado / ruído
        distanceM += step
        lastLat = lat; lastLon = lon; lastTMs = tMs
        return distanceM
    }
}

/** Zona de privacidade: raio em torno do ponto de partida onde o trajeto não é desenhado. */
class PrivacyZone(val centerLat: Double, val centerLon: Double, val radiusM: Double) {
    fun contains(lat: Double, lon: Double) =
        Geo.haversine(centerLat, centerLon, lat, lon) <= radiusM
}
