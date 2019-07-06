package ca.coffeeshopstudio.gaminginterfaceclient

import android.content.Intent
import android.os.Bundle
import android.util.Log
import ca.coffeeshopstudio.gaminginterfaceclient.utils.CryptoHelper
import ca.coffeeshopstudio.gaminginterfaceclient.views.AboutActivity
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {

  companion object {
    private const val channelName = "ca.coffeeshopstudio.gic"
    const val viewAbout = "$channelName/views/about"
    const val utilCrypto = "$channelName/util/crypto"
  }

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)

    buildActivityChannel()
    buildUtilChannel()
  }

  private fun buildActivityChannel() {
    MethodChannel(flutterView, viewAbout).setMethodCallHandler { call, result ->
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

  private fun buildUtilChannel() {
    MethodChannel(flutterView, utilCrypto).setMethodCallHandler { call, result ->
      if (call.method == "decrypt") {
        val password = CryptoHelper.decrypt(call.argument("code"))
        result.success(password)
      }
    }
  }
}
