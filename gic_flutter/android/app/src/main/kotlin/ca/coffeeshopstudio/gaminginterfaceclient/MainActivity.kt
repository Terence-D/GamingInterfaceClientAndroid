package ca.coffeeshopstudio.gaminginterfaceclient

import android.content.Intent
import androidx.annotation.NonNull
import ca.coffeeshopstudio.gaminginterfaceclient.views.DonateActivity
import io.flutter.plugin.common.MethodChannel;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;

class MainActivity: FlutterActivity() {

  companion object {
    private const val channelName = "ca.coffeeshopstudio.gic"
    const val channelView = "$channelName/views"

    const val actionDonate = "donate"
  }

  private lateinit var _result: MethodChannel.Result

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelView).setMethodCallHandler { call, result ->
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
