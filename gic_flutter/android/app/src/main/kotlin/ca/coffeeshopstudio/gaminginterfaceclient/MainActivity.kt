package ca.coffeeshopstudio.gaminginterfaceclient

import android.content.Context
import android.content.Context.MODE_PRIVATE
import android.content.Intent
import android.os.Bundle
import android.util.Log
import ca.coffeeshopstudio.gaminginterfaceclient.utils.CryptoHelper
import ca.coffeeshopstudio.gaminginterfaceclient.views.AboutActivity
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import ca.coffeeshopstudio.gaminginterfaceclient.views.launch.SplashIntroActivity
import ca.coffeeshopstudio.gaminginterfaceclient.models.screen.ScreenRepository
import android.util.SparseArray
import androidx.core.util.forEach
import ca.coffeeshopstudio.gaminginterfaceclient.models.screen.IScreenRepository


class MainActivity: FlutterActivity() {

  companion object {
    private const val channelName = "ca.coffeeshopstudio.gic"
    const val channelUtil = "$channelName/utils"
    const val channelView = "$channelName/views"

    const val actionAbout = "about"
    const val actionIntro = "intro"

    const val actionDecrypt = "decrypt"
    const val actionGetScreens = "screens/get"
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

  private val PREFS_CHOSEN_ID = "chosen_id"
  private fun buildUtilChannel() {
    MethodChannel(flutterView, channelUtil).setMethodCallHandler { call, result ->
      Log.d("tag", call.method)
      when (call.method) {
        actionDecrypt -> {
          val password = CryptoHelper.decrypt(call.argument("code"))
          result.success(password)
        }
        actionGetScreens -> {
          val screenRepository = ScreenRepository(applicationContext)
          val screenList = screenRepository.screenListGetterSync(applicationContext)

          val returnValue = HashMap<Int, String>()
          screenList.forEach { key, value -> returnValue.put(key, value) }
          result.success(returnValue)
        }
        else -> {
          result.notImplemented()
        }
      }
    }
  }
}
