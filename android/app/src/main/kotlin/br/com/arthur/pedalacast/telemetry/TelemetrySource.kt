package br.com.arthur.pedalacast.telemetry

/** Fonte de dados para o motor: GPS real, simulação, (Fase 3) BLE, (Fase 4) arquivo. */
interface TelemetrySource {
    fun start(sink: Sink)
    fun stop()

    interface Sink {
        fun onFix(fix: GpsFix)
        fun onPressureHpa(hpa: Float)
    }
}
