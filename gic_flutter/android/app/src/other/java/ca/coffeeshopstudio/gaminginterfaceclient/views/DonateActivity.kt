package ca.coffeeshopstudio.gaminginterfaceclient.views

import android.content.Context
import android.os.Bundle
import android.view.View
import android.widget.Button
import androidx.appcompat.app.AppCompatActivity;
import ca.coffeeshopstudio.gaminginterfaceclient.R

import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Build
import android.preference.PreferenceManager
import android.text.Html
import android.util.Log
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.widget.Toolbar


class DonateActivity : AppCompatActivity() {
  val prefNightMode = "NIGHT_MODE"

  fun darkMode () : Boolean {
    val defaultPrefs = PreferenceManager.getDefaultSharedPreferences(applicationContext)
    return defaultPrefs.getBoolean(prefNightMode, true)
  }

  override fun onCreate(savedInstanceState: Bundle?) {
    if (darkMode())
      setTheme(R.style.ActivityTheme_Primary_Base_Dark);

    super.onCreate(savedInstanceState)
  }


}
