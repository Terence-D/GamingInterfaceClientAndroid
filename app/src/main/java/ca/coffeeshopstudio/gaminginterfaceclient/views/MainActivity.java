package ca.coffeeshopstudio.gaminginterfaceclient.views;

import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Bundle;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.util.SparseArray;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import java.util.List;

import ca.coffeeshopstudio.gaminginterfaceclient.R;
import ca.coffeeshopstudio.gaminginterfaceclient.models.screen.IScreen;
import ca.coffeeshopstudio.gaminginterfaceclient.models.screen.IScreenRepository;
import ca.coffeeshopstudio.gaminginterfaceclient.models.screen.ScreenRepository;
import ca.coffeeshopstudio.gaminginterfaceclient.network.CommandService;
import ca.coffeeshopstudio.gaminginterfaceclient.network.RestClientInstance;
import ca.coffeeshopstudio.gaminginterfaceclient.utils.CryptoHelper;
import ca.coffeeshopstudio.gaminginterfaceclient.views.screenmanager.ScreenManagerActivity;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

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
public class MainActivity extends AppCompatActivity implements AdapterView.OnItemSelectedListener {
    private SparseArray<String> screenList;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        buildControls();

        loadSettings();
    }

    private void buildControls() {
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
        findViewById(R.id.btnScreenManager).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                MainActivity.this.startActivity(new Intent(MainActivity.this, ScreenManagerActivity.class));
            }
        });
        findViewById(R.id.btnAbout).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                MainActivity.this.startActivity(new Intent(MainActivity.this, AboutActivity.class));
            }
        });
        findViewById(R.id.btnHelp).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                String url = "https://github.com/Terence-D/GamingInterfaceClientAndroid/wiki";
                Intent i = new Intent(Intent.ACTION_VIEW);
                i.setData(Uri.parse(url));
                startActivity(i);
            }
        });

        final ScreenRepository screenRepository = new ScreenRepository(getApplicationContext());
        screenRepository.loadScreens(new IScreenRepository.LoadCallback() {
            @Override
            public void onLoaded(List<IScreen> screens) {
                screenRepository.getScreenList(new IScreenRepository.LoadScreenListCallback() {
                    @Override
                    public void onLoaded(SparseArray<String> screenList) {
                        buildScreenSpinner(screenList);
                    }
                });
            }
        });
    }

    private void buildScreenSpinner(SparseArray<String> screenList) {
        this.screenList = screenList;

        Spinner spinner = findViewById(R.id.spnScreens);

        String[] spinnerArray = new String[screenList.size()];
        for (int i = 0; i < screenList.size(); i++) {
            spinnerArray[i] = screenList.valueAt(i);
        }

        ArrayAdapter<CharSequence> dataAdapter = new ArrayAdapter<CharSequence>(this, android.R.layout.simple_spinner_dropdown_item, spinnerArray);
        dataAdapter.setDropDownViewResource(android.R.layout.simple_dropdown_item_1line);
        spinner.setAdapter(dataAdapter);
        spinner.setOnItemSelectedListener(this);
    }

    private void editApp() {
        Intent myIntent = new Intent(MainActivity.this, EditActivity.class);

        MainActivity.this.startActivity(myIntent);
    }

    public static boolean isInteger(String str) {
        if (str == null) {
            return false;
        }
        if (str.isEmpty()) {
            return false;
        }
        int i = 0;
        int length = str.length();

        if (str.charAt(0) == '-') {
            if (length == 1) {
                return false;
            }
            i = 1;
        }
        for (; i < length; i++) {
            char c = str.charAt(i);
            if (c < '0' || c > '9') {
                return false;
            }
        }
        return true;
    }

    private void checkServerVersion(String address, String port, final Intent myIntent) {
        String url = "http://" + address + ":" + port + "/";

        CommandService routeMap = RestClientInstance.getRetrofitInstance(url).create(CommandService.class);
        Call<String> version = routeMap.getVersion();
        version.enqueue(new Callback<String>() {
            @Override
            public void onResponse(Call<String> call, Response<String> response) {
                if (response.isSuccessful()) {
                    if (response.body().equals("1.3.0.0")) {
                        MainActivity.this.startActivity(myIntent);
                        return;
                    }
                    displayUpgradeWarning();
                } else {
                    Toast.makeText(getApplicationContext(), response.message(), Toast.LENGTH_LONG).show();
                }
            }

            @Override
            public void onFailure(Call<String> call, Throwable t) {
                Toast.makeText(getApplicationContext(), "Something went wrong...Please try later! " + t.getLocalizedMessage(), Toast.LENGTH_LONG).show();
            }
        });
    }

    private void displayUpgradeWarning() {
        AlertDialog alertDialog = new AlertDialog.Builder(this).create();
        alertDialog.setTitle(R.string.activity_main_server_upgrade_title);
        alertDialog.setMessage(getString(R.string.activity_main_server_upgrade_text));
        alertDialog.setButton(AlertDialog.BUTTON_NEUTRAL, getString(android.R.string.ok),
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                    }
                });
        alertDialog.show();
    }

    private void startApp() {
        TextView txtPassword = findViewById(R.id.txtPassword);
        TextView txtPort = findViewById(R.id.txtPort);
        TextView txtAddress = findViewById(R.id.txtAddress);
        String password = txtPassword.getText().toString();
        String port = txtPort.getText().toString();
        String address = txtAddress.getText().toString();

        if (password.length() < 6) {
            Toast.makeText(this, R.string.password_invalid, Toast.LENGTH_SHORT).show();
            return;
        }
        if (!isInteger(port)) {
            Toast.makeText(this, R.string.port_invalid, Toast.LENGTH_SHORT).show();
            return;
        }

        if (address.length() < 7) {
            Toast.makeText(this, R.string.address_invalid, Toast.LENGTH_LONG).show();
            return;
        }

        try {
            password = CryptoHelper.encrypt(txtPassword.getText().toString());
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (password == null) {
            Toast.makeText(this, R.string.password_invalid, Toast.LENGTH_SHORT).show();
            return;
        }

        port = port.replaceFirst("\\s++$", "");
        address = address.replaceFirst("\\s++$", "");

        Intent myIntent = new Intent(MainActivity.this, GameActivity.class);
        myIntent.putExtra("address", address);
        myIntent.putExtra("port", port);
        myIntent.putExtra("password", password);

        saveSettings(password, port, address);

        checkServerVersion(address, port, myIntent);
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
        try {
            password = CryptoHelper.decrypt(password);
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (password == null) {
            Log.d("GIC", "start: Password Decryption Failure");
        }

        String address = prefs.getString("address", "");
        String port = prefs.getString("port", "8091");
        txtPassword.setText(password);
        txtPort.setText(port);
        txtAddress.setText(address);
    }

    @Override
    public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {

    }

    @Override
    public void onNothingSelected(AdapterView<?> adapterView) {
    }
}
