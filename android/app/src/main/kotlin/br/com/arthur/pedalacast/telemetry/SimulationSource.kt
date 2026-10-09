package br.com.arthur.pedalacast.telemetry

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.os.SystemClock

/** Reproduz um GPX como se fosse GPS ao vivo (1 ponto por segundo). */
class SimulationSource(private val context: Context, private val speedUp: Int = 1) : TelemetrySource {
    private val handler = Handler(Looper.getMainLooper())
    private var points: List<GpxPoint> = emptyList()
    private var i = 0
    private var running = false
    private var sink: TelemetrySource.Sink? = null

    private val tick = object : Runnable {
        override fun run() {
            if (!running) return
            val s = sink ?: return
            if (i >= points.size) i = 0                  // volta ao início em loop
            val p = points[i]
            val prev = points.getOrNull(i - 1)
            val speed = if (prev != null) Geo.haversine(prev.lat, prev.lon, p.lat, p.lon) else 0.0
            val now = SystemClock.elapsedRealtime()
            s.onFix(GpsFix(now, System.currentTimeMillis(), p.lat, p.lon, p.ele, speed, 5.0))
            i += speedUp
            handler.postDelayed(this, 1000L)
        }
    }

    override fun start(sink: TelemetrySource.Sink) {
        this.sink = sink
        points = context.assets.open("flutter_assets/assets/sim/sample.gpx").use { GpxReader.read(it) }
        i = 0
        running = true
        handler.post(tick)
    }

    override fun stop() {
        running = false
        handler.removeCallbacks(tick)
        sink = null
    }
}
