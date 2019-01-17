package ca.coffeeshopstudio.gaminginterfaceclient;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.widget.TextView;

/**
 Copyright [2019] [Terence Doerksen]

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        findViewById(R.id.btnStart).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                startApp();
            }
        });
        findViewById(R.id.btnEdit).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                editApp();
            }
        });

        loadSettings();
    }

    private void editApp() {
        Intent myIntent = new Intent(MainActivity.this, EditActivity.class);

        MainActivity.this.startActivity(myIntent);
    }

    private void startApp() {
        TextView txtPassword = findViewById(R.id.txtPassword);
        TextView txtPort = findViewById(R.id.txtPort);
        TextView txtAddress = findViewById(R.id.txtAddress);

        String password = txtPassword.getText().toString();
        String port = txtPort.getText().toString();
        String address = txtAddress.getText().toString();
        port = port.replaceFirst("\\s++$", "");
        address = address.replaceFirst("\\s++$", "");

        Intent myIntent = new Intent(MainActivity.this, GameActivity.class);
        myIntent.putExtra("address", address);
        myIntent.putExtra("port", port);
        myIntent.putExtra("password", password);

        saveSettings(password, port, address);
        MainActivity.this.startActivity(myIntent);
    }

    private void saveSettings(String password, String port, String address) {
        SharedPreferences prefs = getApplicationContext().getSharedPreferences("gics", MODE_PRIVATE);
        SharedPreferences.Editor prefsEditor = prefs.edit();

        prefsEditor.putString("address", address);
        prefsEditor.putString("port", port);
        prefsEditor.putString("password", password);

        prefsEditor.apply();
    }

    private void loadSettings() {
        TextView txtPassword = findViewById(R.id.txtPassword);
        TextView txtPort = findViewById(R.id.txtPort);
        TextView txtAddress = findViewById(R.id.txtAddress);

        SharedPreferences prefs = getApplicationContext().getSharedPreferences("gics", MODE_PRIVATE);
        String password = prefs.getString("password", "");
        String address = prefs.getString("address", "");
        String port = prefs.getString("port", "");
        txtPassword.setText(password);
        txtPort.setText(port);
        txtAddress.setText(address);
    }
}
