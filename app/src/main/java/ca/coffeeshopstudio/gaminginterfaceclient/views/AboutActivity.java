package ca.coffeeshopstudio.gaminginterfaceclient.views;

import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.res.Resources;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.widget.TextView;

import ca.coffeeshopstudio.gaminginterfaceclient.R;

/**
 * Copyright [2019] [Terence Doerksen]
 * <p>
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * <p>
 * http://www.apache.org/licenses/LICENSE-2.0
 * <p>
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
public class AboutActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_about);

        FloatingActionButton fab = findViewById(R.id.fab);
        if (fab != null) {
            fab.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    Intent Email = new Intent(Intent.ACTION_SEND);
                    Email.setType("text/email");
                    Email.putExtra(Intent.EXTRA_EMAIL,
                            new String[]{"support@coffeeshopstudio.ca"});  //developer 's email
                    Email.putExtra(Intent.EXTRA_SUBJECT,
                            "Budget Miser"); // Email 's Subject
                    startActivity(Intent.createChooser(Email, "Send Feedback:"));
                }
            });
        }

        PackageInfo nfo;
        String versionName = "0.00";
        int versionCode = 0;
        try {
            nfo = getPackageManager().getPackageInfo(getPackageName(), 0);
            versionCode = nfo.versionCode;
            versionName = nfo.versionName;
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }

        TextView version = findViewById(R.id.txtVersion);
        if (version != null) {
            Resources res = getResources();
            String text = String.format(res.getString(R.string.version), versionName, versionCode);
            version.setText(text);
        }
    }
}
