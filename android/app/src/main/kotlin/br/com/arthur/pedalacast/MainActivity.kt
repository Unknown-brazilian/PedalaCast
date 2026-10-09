package br.com.arthur.pedalacast

import br.com.arthur.pedalacast.channels.Channels
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var channels: Channels? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channels = Channels(this, flutterEngine)
    }

    override fun onDestroy() {
        channels?.dispose()
        super.onDestroy()
    }
}
