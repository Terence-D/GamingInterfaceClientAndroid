package ca.coffeeshopstudio.gaminginterfaceclient.views.main;

import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.lifecycle.ViewModelProviders;
import ca.coffeeshopstudio.gaminginterfaceclient.App;
import ca.coffeeshopstudio.gaminginterfaceclient.R;
import ca.coffeeshopstudio.gaminginterfaceclient.views.AboutActivity;
import ca.coffeeshopstudio.gaminginterfaceclient.views.GameActivity;
import ca.coffeeshopstudio.gaminginterfaceclient.views.launch.SplashIntroActivity;
import ca.coffeeshopstudio.gaminginterfaceclient.views.screenmanager.ScreenManagerActivity;
import uk.co.samuelwall.materialtaptargetprompt.MaterialTapTargetPrompt;

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
public class MainActivity extends AppCompatActivity implements IContract.IView,
        AdapterView.OnItemSelectedListener {
    public static final String INTENT_SCREEN_INDEX = "screen_index";
    public static final int REQUEST_CODE_INTRO = 65;

    private Spinner spinner;
    private ProgressDialog dialog;
    private IContract.IPresentation presentation;
    private IContract.MainViewModel viewModel;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        if (((App) getApplication()).isNightModeEnabled())
            setTheme(R.style.ActivityTheme_Primary_Base_Dark);

        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        viewModel = ViewModelProviders.of(this).get(IContract.MainViewModel.class);

        setPresentation(new MainPresentation(this));

        presentation.checkFirstRun();
        toolbar.setTitle(R.string.app_name);

        buildControls();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == REQUEST_CODE_INTRO) {
            if (resultCode == RESULT_OK) {
                presentation.introResult(false);
            } else {
                presentation.introResult(true);
            }
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        switch (id) {
            case R.id.menu_about:
                MainActivity.this.startActivity(new Intent(MainActivity.this, AboutActivity.class));
                return true;
            case R.id.menu_help:
                String url = "https://github.com/Terence-D/GamingInterfaceClientAndroid/wiki";
                Intent i = new Intent(Intent.ACTION_VIEW);
                i.setData(Uri.parse(url));
                startActivity(i);
                return true;
            case R.id.menu_toggle_theme:
                presentation.toggleTheme();
                recreate();
                break;
            case R.id.menu_show_intro:
                Intent intent = new Intent(this, SplashIntroActivity.class);
                startActivityForResult(intent, REQUEST_CODE_INTRO);
                break;
        }

        return super.onOptionsItemSelected(item);
    }

    private void buildControls() {
        findViewById(R.id.btnStart).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                saveSettings();
            }
        });
        findViewById(R.id.btnScreenManager).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                MainActivity.this.startActivity(new Intent(MainActivity.this, ScreenManagerActivity.class));
            }
        });
    }

    @Override
    protected void onResume() {
        super.onResume();
        presentation.loadSettings();
    }

    @Override
    public void displayUpgradeWarning() {
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

    private void saveSettings() {
        TextView txtPassword = findViewById(R.id.txtPassword);
        TextView txtPort = findViewById(R.id.txtPort);
        TextView txtAddress = findViewById(R.id.txtAddress);
        String password = txtPassword.getText().toString();
        String port = txtPort.getText().toString();
        String address = txtAddress.getText().toString();

        presentation.saveSettings(password, port, address);
    }

    public void startApp() {
        presentation.checkServerVersion(viewModel.getAddress(), viewModel.getPort());
    }

    @Override
    public void updateView() {
        TextView txtPassword = findViewById(R.id.txtPassword);
        TextView txtPort = findViewById(R.id.txtPort);
        TextView txtAddress = findViewById(R.id.txtAddress);

        txtPassword.setText(viewModel.getPassword());
        txtPort.setText(viewModel.getPort());
        txtAddress.setText(viewModel.getAddress());
        spinner = findViewById(R.id.spnScreens);
        ArrayAdapter<CharSequence> dataAdapter = new ArrayAdapter<CharSequence>(this, android.R.layout.simple_spinner_dropdown_item, viewModel.getScreenArray());
        dataAdapter.setDropDownViewResource(android.R.layout.simple_dropdown_item_1line);
        spinner.setAdapter(dataAdapter);
        spinner.setSelection(viewModel.getStartingScreenIndex());
        spinner.setOnItemSelectedListener(this);

        showHelpMenuIcon();
    }

    @Override
    public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {
        presentation.selectScreen(viewModel.getScreenList().keyAt(viewModel.getScreenList().indexOfKey(i)));
    }

    @Override
    public void onNothingSelected(AdapterView<?> adapterView) {
    }

    @Override
    public void setPresentation(IContract.IPresentation listener) {
        presentation = listener;
    }

    @Override
    public void setProgressIndicator(boolean show) {
        if (show)
            showLoadingIndicator();
        else
            hideLoadingIndicator();
    }

    protected void showLoadingIndicator() {
        buildLoadWindow();
        dialog.show();
    }

    protected void hideLoadingIndicator() {
        buildLoadWindow();
        dialog.dismiss();
    }

    private void buildLoadWindow() {
        if (dialog == null) {
            //prepare our dialog
            dialog = new ProgressDialog(this);
            dialog.setMessage(getString(R.string.loading));
            dialog.setIndeterminate(true);
        }
    }

    @Override
    public void showMessage(String message) {
        Toast.makeText(this, message, Toast.LENGTH_LONG).show();
    }

    @Override
    public void showMessage(int messageId) {
        Toast.makeText(this, messageId, Toast.LENGTH_LONG).show();
    }

    @Override
    public Context getContext() {
        return this;
    }

    @Override
    public IContract.MainViewModel getViewModel() {
        return viewModel;
    }

    @Override
    public void loadIntro() {
        Intent intent = new Intent(this, SplashIntroActivity.class);
        startActivityForResult(intent, REQUEST_CODE_INTRO);
    }

    @Override
    public void startGameApp() {
        int screenIndex = viewModel.getScreenList().keyAt(spinner.getSelectedItemPosition());

        Intent myIntent = new Intent(MainActivity.this, GameActivity.class);
        myIntent.putExtra("address", viewModel.getAddress());
        myIntent.putExtra("port", viewModel.getPort());
        myIntent.putExtra("password", viewModel.getPassword());
        myIntent.putExtra(MainActivity.INTENT_SCREEN_INDEX, screenIndex);

        MainActivity.this.startActivity(myIntent);
    }

    @Override
    public void showHelpMenuIcon() {
        Log.d("TAG", "showHelpMenuIcon: ");
        new MaterialTapTargetPrompt.Builder(this)
                .setTarget(R.id.menu_help)
                .setIcon(R.drawable.ic_help_outline_white_24dp)
                .setPrimaryText(R.string.help_menu_icon_title)
                .setSecondaryText(R.string.help_menu_icon_desc)
                .setPromptStateChangeListener(new MaterialTapTargetPrompt.PromptStateChangeListener() {
                    @Override
                    public void onPromptStateChanged(MaterialTapTargetPrompt prompt, int state) {
                        if (state == MaterialTapTargetPrompt.STATE_FOCAL_PRESSED) {
                            //if we wanted to chain helps together, this is where we'd do it
                        }
                    }
                })
                .show();
    }
}
