package ca.coffeeshopstudio.gaminginterfaceclient

import android.content.Intent
import android.os.Bundle
import android.preference.PreferenceManager
import android.util.Log
import androidx.core.util.forEach
import ca.coffeeshopstudio.gaminginterfaceclient.models.screen.ScreenRepository
import ca.coffeeshopstudio.gaminginterfaceclient.utils.CryptoHelper
import ca.coffeeshopstudio.gaminginterfaceclient.views.AboutActivity
import ca.coffeeshopstudio.gaminginterfaceclient.views.GameActivity
import ca.coffeeshopstudio.gaminginterfaceclient.views.launch.SplashIntroActivity
import ca.coffeeshopstudio.gaminginterfaceclient.views.screenmanager.ScreenManagerActivity
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity: FlutterActivity() {

  companion object {
    private const val channelName = "ca.coffeeshopstudio.gic"
    const val channelUtil = "$channelName/utils"
    const val channelView = "$channelName/views"

    const val actionAbout = "about"
    const val actionIntro = "intro"
    const val actionStart = "start"
    const val actionManager = "manager"

    const val actionDecrypt = "decrypt"
    const val actionEncrypt = "encrypt"
    const val actionGetScreens = "screens/get"
    const val actionGetSettings = "settings/get"
    const val actionUpdateDarkMode = "darkmode/set";
  }

  private lateinit var _result: MethodChannel.Result

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)

    buildActivityChannel()
    buildUtilChannel()
  }

  private fun buildActivityChannel() {
    MethodChannel(flutterView, channelView).setMethodCallHandler { call, result ->
      _result = result
      Log.d("tag", call.method)
      when (call.method) {
        actionIntro -> {
          val intent = Intent(this, SplashIntroActivity::class.java)
          startActivityForResult(intent, 1234)
        }
        actionAbout -> {
          val intent = Intent(this, AboutActivity::class.java)
          startActivity(intent)
          result.success(true)
        }
        actionStart-> {
          val password = CryptoHelper.encrypt (call.argument("password"))
          val address: String? = call.argument("address")
          val port: String? = call.argument("port")
          val intent = Intent(this, GameActivity::class.java)
          intent.putExtra("password", password)
          intent.putExtra("address", address)
          intent.putExtra("port", port)
          startActivity(intent)
          result.success(true)
        }
        actionManager -> {
          val intent = Intent(this, ScreenManagerActivity::class.java)
          startActivity(intent)
          result.success(true)
        }
        else -> {
          result.notImplemented()
        }
      }
    }
  }

  override fun onActivityResult(requestCode: Int, result: Int, intent: Intent?) {
    if(requestCode != 1234)
      return super.onActivityResult(requestCode, result, intent)
    val screenRepository = ScreenRepository(applicationContext)
    screenRepository.checkForScreens()
    _result.success(true)
  }

  private fun buildUtilChannel() {
    MethodChannel(flutterView, channelUtil).setMethodCallHandler { call, result ->
      Log.d("tag", call.method)
      when (call.method) {
        actionDecrypt -> {
          val password = CryptoHelper.decrypt(call.argument("code"))
          result.success(password)
        }
        actionEncrypt -> {
          Log.d("tag", "encrypt")
          val encrypted = CryptoHelper.encrypt(call.argument("password"))
          result.success(encrypted)
        }
        actionGetScreens -> {
          val screenRepository = ScreenRepository(applicationContext)
          val screenList = screenRepository.screenListGetterSync(applicationContext)

          val returnValue = HashMap<Int, String>()
          screenList.forEach { key, value -> returnValue.put(key, value) }
          result.success(returnValue)
        }
        actionGetSettings -> {
          val keys = loadLegacyPreferences();
          result.success(keys)
        }
        actionUpdateDarkMode -> {
          val defaultPrefs = PreferenceManager.getDefaultSharedPreferences(applicationContext)
          val editor = defaultPrefs.edit()
          val darkMode: Boolean? = call.argument("darkMode")
          if (darkMode == true)
            editor.putBoolean(prefNightMode, true)
          else
            editor.putBoolean(prefNightMode, false)
          editor.apply()
        }
        else -> {
          Log.d("tag", call.method)
          result.notImplemented()
        }
      }
    }
  }

  val PREFS_HELP_FIRST_TIME = "seenHelp";
  val PREF_KEY_FIRST_START = "prefSplash"
  val PREFS_CHOSEN_ID = "chosen_id"
  val prefAddress = "address"
  val prefPort = "port"
  val prefPassword = "password"
  val prefNightMode = "NIGHT_MODE"
  fun loadLegacyPreferences(): HashMap<String, Any?> {
    val keys = HashMap<String, Any?>()

    val defaultPrefs = PreferenceManager.getDefaultSharedPreferences(applicationContext)
    val gicsPrefs = applicationContext.getSharedPreferences("gics", MODE_PRIVATE)
    val screenPrefs = applicationContext.getSharedPreferences(ScreenRepository.PREFS_NAME, MODE_PRIVATE)

    if (defaultPrefs.contains(PREF_KEY_FIRST_START)) {
      val firstStart = defaultPrefs.getBoolean(PREF_KEY_FIRST_START, true)
      keys[PREF_KEY_FIRST_START] = firstStart
    } else {}
    if (defaultPrefs.contains(prefNightMode)) {
      val night = defaultPrefs.getBoolean(prefNightMode, true)
      keys[prefNightMode] = night
    } else {}

    if (gicsPrefs.contains(prefAddress)) {
      val address = gicsPrefs.getString(prefAddress, "")
      keys[prefAddress] = address
    } else {}
    if (gicsPrefs.contains(prefPort)) {
      val port = gicsPrefs.getString(prefPort, "8091")
      keys[prefPort] = port
    } else {}
    if (gicsPrefs.contains(prefPassword)) {
      val password = gicsPrefs.getString(prefPassword, "")
      keys[prefPassword] = password
    } else {}
    if (gicsPrefs.contains(PREFS_HELP_FIRST_TIME)) {
      val helpFirst = gicsPrefs.getBoolean(PREFS_HELP_FIRST_TIME, false)
      keys[PREFS_HELP_FIRST_TIME] = helpFirst
    } else {}

    if (screenPrefs.contains(PREFS_CHOSEN_ID)) {
      val chosenId = screenPrefs.getInt(PREFS_CHOSEN_ID, 0)
      keys[PREFS_CHOSEN_ID] = chosenId
    } else {}

    return keys
  }
}
