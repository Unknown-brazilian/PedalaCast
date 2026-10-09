package br.com.arthur.pedalacast.telemetry

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.BatteryManager
import android.telephony.TelephonyManager

/**
 * Liga uma [TelemetrySource] a um [TelemetryProcessor], atualiza o status do celular
 * e entrega amostras ao logger e aos ouvintes. Um único relógio: elapsedRealtime.
 */
class TelemetryEngine(private val context: Context) : TelemetrySource.Sink {
    private var source: TelemetrySource? = null
    var processor = TelemetryProcessor(hasBarometer = false)
        private set
    @Volatile var logger: TelemetryLogger? = null
    var onSample: ((TelemetrySample) -> Unit)? = null
    @Volatile var lastFixTMs: Long = 0
        private set

    fun start(src: TelemetrySource, hasBarometer: Boolean) {
        stop()
        processor = TelemetryProcessor(hasBarometer)
        source = src
        src.start(this)
    }

    fun stop() {
        source?.stop()
        source = null
    }

    val running get() = source != null

    override fun onFix(fix: GpsFix) {
        processor.phone = readPhoneStatus()
        val s = processor.onFix(fix)
        lastFixTMs = fix.tMs
        logger?.log(s)
        onSample?.invoke(s)
    }

    override fun onPressureHpa(hpa: Float) = processor.onPressureHpa(hpa)

    fun readPhoneStatus(): PhoneStatus {
        val b: Intent? = context.registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        var pct = -1; var charging = false; var temp: Double? = null
        if (b != null) {
            val level = b.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
            val scale = b.getIntExtra(BatteryManager.EXTRA_SCALE, 100)
            if (level >= 0 && scale > 0) pct = level * 100 / scale
            val st = b.getIntExtra(BatteryManager.EXTRA_STATUS, -1)
            charging = st == BatteryManager.BATTERY_STATUS_CHARGING || st == BatteryManager.BATTERY_STATUS_FULL
            val t = b.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, Int.MIN_VALUE)
            if (t != Int.MIN_VALUE) temp = t / 10.0
        }
        // Sinal e rede: ausência de permissão/dado vira "indisponível" (null), nunca erro.
        val level = runCatching {
            (context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager).signalStrength?.level
        }.getOrNull()
        val net = runCatching {
            val cm = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
            val caps = cm.getNetworkCapabilities(cm.activeNetwork)
            when {
                caps == null -> null
                caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) -> "Wi-Fi"
                caps.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) -> "Móvel"
                else -> "Outra"
            }
        }.getOrNull()
        return PhoneStatus(pct, charging, level, net, temp)
    }
}
