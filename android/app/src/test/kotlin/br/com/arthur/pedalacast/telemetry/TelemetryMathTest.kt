package br.com.arthur.pedalacast.telemetry

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class TelemetryMathTest {
    @Test fun haversine_oneDegreeLatitude() {
        assertEquals(111_195.0, Geo.haversine(0.0, 0.0, 1.0, 0.0), 100.0)
    }

    @Test fun speed_movingAverageAndBadAccuracy() {
        val s = SpeedSmoother(window = 3)
        s.add(3.0, 5.0); s.add(6.0, 5.0)
        assertEquals(6.0, s.add(9.0, 5.0)!!, 1e-9)
        assertNull(s.add(9.0, 80.0))
        assertNull(s.add(null, null))
    }

    @Test fun ascent_hysteresisIgnoresNoise() {
        val a = AscentCounter(2.5)
        listOf(100.0, 101.0, 100.5, 101.5, 100.0).forEach { a.add(it) }
        assertEquals(0.0, a.ascentM, 1e-9)
        a.add(103.0); a.add(106.0)
        assertEquals(6.0, a.ascentM, 1e-9)
        a.add(100.0); a.add(103.0) // descida não soma; nova subida soma
        assertEquals(9.0, a.ascentM, 1e-9)
    }

    @Test fun grade_slidingWindow() {
        val g = GradeEstimator()
        assertNull(g.add(0.0, 100.0))
        assertNull(g.add(30.0, 101.0))
        assertEquals(5.0, g.add(60.0, 103.0)!!, 1e-9)
        // janela desliza: depois de 200 m a 5%, continua 5%
        var last: Double? = null
        var d = 60.0; var alt = 103.0
        repeat(20) { d += 10; alt += 0.5; last = g.add(d, alt) }
        assertEquals(5.0, last!!, 1e-6)
    }

    @Test fun distance_ignoresJumpsAndNoise() {
        val d = DistanceAccumulator()
        d.add(0.0, 0.0, 0, 5.0)
        d.add(0.00001, 0.0, 1000, 5.0)      // ~1,1 m: ruído
        assertEquals(0.0, d.distanceM, 1e-9)
        d.add(0.0001, 0.0, 2000, 5.0)       // ~11 m em 2 s
        assertEquals(11.1, d.distanceM, 0.2)
        val before = d.distanceM
        d.add(0.5, 0.0, 3000, 5.0)          // salto absurdo
        assertEquals(before, d.distanceM, 1e-9)
        d.add(0.0002, 0.0, 4000, 100.0)     // precisão ruim
        assertEquals(before, d.distanceM, 1e-9)
    }

    @Test fun altitude_baroFollowsVariationsGpsAnchors() {
        val f = AltitudeFuser()
        f.onBaro(50.0)
        assertEquals(200.0, f.onGps(200.0, true), 1e-9)
        f.onBaro(53.0)
        assertEquals(203.0, f.value!!, 1e-9)
        val v = f.onGps(200.0, true)
        assertTrue(v < 203.0 && v > 202.0)
    }

    @Test fun privacyZone() {
        val z = PrivacyZone(0.0, 0.0, 300.0)
        assertTrue(z.contains(0.001, 0.0))   // ~111 m
        assertFalse(z.contains(0.01, 0.0))   // ~1,1 km
        assertNotNull(z)
    }
}
