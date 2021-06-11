package ca.coffeeshopstudio.gaminginterfaceclient

import android.content.Intent
import android.os.Bundle
import ca.coffeeshopstudio.gaminginterfaceclient.views.DonateActivity
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity: FlutterActivity() {

  companion object {
    private const val channelName = "ca.coffeeshopstudio.gic"
    const val channelView = "$channelName/views"

    const val actionDonate = "donate"
  }

  private lateinit var _result: MethodChannel.Result

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)

    buildActivityChannel()
  }

  private fun buildActivityChannel() {
    MethodChannel(flutterView, channelView).setMethodCallHandler { call, result ->
      _result = result
      when (call.method) {
        actionDonate -> {
          val intent = Intent(this, DonateActivity::class.java)
          startActivity(intent)
          result.success(true)
        }
        else -> {
          result.notImplemented()
        }
      }
    }
  }
}
