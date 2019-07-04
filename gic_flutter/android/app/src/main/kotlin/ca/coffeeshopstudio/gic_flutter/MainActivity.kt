package ca.coffeeshopstudio.gic_flutter

import android.content.Intent
import android.os.Bundle
import android.util.Log
import ca.coffeeshopstudio.gic_flutter.views.AboutActivity
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {

  companion object {
    const val CHANNEL = "ca.coffeeshopstudio.gic.views.about"
  }

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)
    MethodChannel(flutterView, CHANNEL).setMethodCallHandler { call, result ->
      if (call.method == "startNewActivity") {
        Log.d("tag", call.method)
        val intent = Intent(this, AboutActivity::class.java)
        startActivity(intent)
        result.success(true)
      } else {
        result.notImplemented()
      }
    }
  }
}
