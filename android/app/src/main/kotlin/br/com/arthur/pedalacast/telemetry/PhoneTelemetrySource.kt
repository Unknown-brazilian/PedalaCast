package br.com.arthur.pedalacast.telemetry

import android.annotation.SuppressLint
import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Looper
import android.os.SystemClock

/** GPS (1 Hz) e barômetro do próprio celular. */
class PhoneTelemetrySource(private val context: Context) : TelemetrySource {
    private val lm = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
    private val sm = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    private val pressure: Sensor? = sm.getDefaultSensor(Sensor.TYPE_PRESSURE)
    val hasBarometer get() = pressure != null

    private var sink: TelemetrySource.Sink? = null

    private val locListener = object : LocationListener {
        override fun onLocationChanged(l: Location) {
            val tMs = l.elapsedRealtimeNanos / 1_000_000
            sink?.onFix(
                GpsFix(
                    tMs = tMs, epochMs = l.time, lat = l.latitude, lon = l.longitude,
                    altM = if (l.hasAltitude()) l.altitude else null,
                    speedMps = if (l.hasSpeed()) l.speed.toDouble() else null,
                    accuracyM = if (l.hasAccuracy()) l.accuracy.toDouble() else null,
                )
            )
        }
        @Deprecated("Deprecated in Java") override fun onStatusChanged(p: String?, s: Int, e: android.os.Bundle?) {}
        override fun onProviderEnabled(provider: String) {}
        override fun onProviderDisabled(provider: String) {}
    }

    private val sensorListener = object : SensorEventListener {
        override fun onSensorChanged(e: SensorEvent) { sink?.onPressureHpa(e.values[0]) }
        override fun onAccuracyChanged(s: Sensor?, a: Int) {}
    }

    @SuppressLint("MissingPermission")
    override fun start(sink: TelemetrySource.Sink) {
        this.sink = sink
        if (lm.allProviders.contains(LocationManager.GPS_PROVIDER)) {
            lm.requestLocationUpdates(LocationManager.GPS_PROVIDER, 1000L, 0f, locListener, Looper.getMainLooper())
        }
        pressure?.let { sm.registerListener(sensorListener, it, SensorManager.SENSOR_DELAY_NORMAL) }
    }

    override fun stop() {
        runCatching { lm.removeUpdates(locListener) }
        sm.unregisterListener(sensorListener)
        sink = null
    }

    @Suppress("unused") fun now() = SystemClock.elapsedRealtime()
}
