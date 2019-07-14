package ca.coffeeshopstudio.gaminginterfaceclient

import android.content.Intent
import android.os.Bundle
import android.util.Log
import ca.coffeeshopstudio.gaminginterfaceclient.utils.CryptoHelper
import ca.coffeeshopstudio.gaminginterfaceclient.views.AboutActivity
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import androidx.annotation.NonNull
import ca.coffeeshopstudio.gaminginterfaceclient.views.launch.SplashIntroActivity


class MainActivity: FlutterActivity() {

  companion object {
    private const val channelName = "ca.coffeeshopstudio.gic"
    const val channelUtil = "$channelName/utils"
    const val channelView = "$channelName/views"

    const val actionAbout = "about";
    const val actionIntro = "intro";

    const val actionDecrypt = "decrypt";
  }

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)

    buildActivityChannel()
    buildUtilChannel()
  }

  private fun buildActivityChannel() {
    MethodChannel(flutterView, channelView).setMethodCallHandler { call, result ->
      Log.d("tag", call.method)
      when (call.method) {
        actionIntro -> {
          val intent = Intent(this, SplashIntroActivity::class.java)
          startActivity(intent)
          result.success(true)
        }
        actionAbout -> {
          val intent = Intent(this, AboutActivity::class.java)
          startActivity(intent)
          result.success(true)
        }
        else -> {
          result.notImplemented()
        }
      }
    }
  }

  private fun buildUtilChannel() {
    MethodChannel(flutterView, channelUtil).setMethodCallHandler { call, result ->
      if (call.method == actionDecrypt) {
        val password = CryptoHelper.decrypt(call.argument("code"))
        result.success(password)
      }
    }
  }
}
