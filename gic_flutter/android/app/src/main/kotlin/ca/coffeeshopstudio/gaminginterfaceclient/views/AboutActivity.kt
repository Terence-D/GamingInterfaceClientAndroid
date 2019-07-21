package ca.coffeeshopstudio.gaminginterfaceclient.views

import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.os.Bundle
import android.preference.PreferenceManager
import android.view.View
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.Toolbar
import ca.coffeeshopstudio.gaminginterfaceclient.R
import ca.coffeeshopstudio.gaminginterfaceclient.models.screen.ScreenRepository
import com.google.android.material.floatingactionbutton.FloatingActionButton
import io.flutter.app.FlutterActivity

/**
 * Copyright [2019] [Terence Doerksen]
 *
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
class AboutActivity : AppCompatActivity() {

    val prefNightMode = "NIGHT_MODE"
    fun darkMode () : Boolean {
        val defaultPrefs = PreferenceManager.getDefaultSharedPreferences(applicationContext)
        return defaultPrefs.getBoolean(prefNightMode, true)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        if (darkMode())
            setTheme(R.style.ActivityTheme_Primary_Base_Dark);

        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_about)
        val toolbar = findViewById<Toolbar>(R.id.toolbar)
        setSupportActionBar(toolbar)
        toolbar.setTitle(R.string.app_name)

        val fab = findViewById<FloatingActionButton>(R.id.fab)
        if (fab != null) {
            fab!!.setOnClickListener(View.OnClickListener {
                val Email = Intent(Intent.ACTION_SEND)
                Email.type = "text/email"
                Email.putExtra(Intent.EXTRA_EMAIL,
                        arrayOf("support@coffeeshopstudio.ca"))  //developer 's email
                Email.putExtra(Intent.EXTRA_SUBJECT,
                        "GIC") // Email 's Subject
                startActivity(Intent.createChooser(Email, "Send Feedback:"))
            })
        }

        val nfo: PackageInfo
        var versionName = "0.00"
        var versionCode = 0
        try {
            nfo = getPackageManager().getPackageInfo(getPackageName(), 0)
            versionCode = nfo.versionCode
            versionName = nfo.versionName
        } catch (e: PackageManager.NameNotFoundException) {
            e.printStackTrace()
        }

        val version = findViewById<TextView>(R.id.txtVersion)
        if (version != null) {
            val res = getResources()
            val text = String.format(res.getString(R.string.version), versionName, versionCode)
            version!!.setText(text)
        }
    }
}
