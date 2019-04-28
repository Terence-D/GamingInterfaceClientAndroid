package ca.coffeeshopstudio.gaminginterfaceclient.views.screenmanager;

import android.Manifest;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.Html;
import android.util.SparseArray;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import ca.coffeeshopstudio.gaminginterfaceclient.App;
import ca.coffeeshopstudio.gaminginterfaceclient.R;
import ca.coffeeshopstudio.gaminginterfaceclient.models.screen.ScreenRepository;
import ca.coffeeshopstudio.gaminginterfaceclient.views.edit.EditActivity;
import ca.coffeeshopstudio.gaminginterfaceclient.views.main.MainActivity;
import pub.devrel.easypermissions.EasyPermissions;
import uk.co.samuelwall.materialtaptargetprompt.MaterialTapTargetPrompt;
import uk.co.samuelwall.materialtaptargetprompt.extras.focals.RectanglePromptFocal;

public class ScreenManagerActivity extends AppCompatActivity implements IContract.IView, AdapterView.OnItemSelectedListener, View.OnClickListener {
    // permissions request code
    private final static int REQUEST_CODE_ASK_PERMISSIONS = 501;
    private final static int REQUEST_CODE_IMPORT = 510;

    private IContract.IPresentation presentation;
    private SparseArray<String> screenList;

    private ProgressDialog dialog;
    private Spinner spinner;
    private int selectedScreenIndex = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        if (((App) getApplication()).isNightModeEnabled())
            setTheme(R.style.ActivityTheme_Primary_Base_Dark);

        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_screen_manager);
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        toolbar.setTitle(R.string.app_name);

        setPresentation(new ScreenManagerPresentation(new ScreenRepository(getApplicationContext()), this));
        presentation.load();

        buildControls();
    }

    private void buildControls() {
        findViewById(R.id.btnExport).setOnClickListener(this);
        findViewById(R.id.btnNew).setOnClickListener(this);
        findViewById(R.id.btnUpdate).setOnClickListener(this);
        findViewById(R.id.btnDelete).setOnClickListener(this);
        findViewById(R.id.btnImport).setOnClickListener(this);
        findViewById(R.id.btnEdit).setOnClickListener(this);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.manager, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        switch (id) {
            case R.id.menu_help:
                startHelp();
                return true;
        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    public void setPresentation(IContract.IPresentation listener) {
        presentation = listener;
    }

    @Override
    public void showError(int errorResource) {
        Toast.makeText(this, errorResource, Toast.LENGTH_LONG).show();
    }

    @Override
    public void showMessage(int messageId) {
        Toast.makeText(this, messageId, Toast.LENGTH_LONG).show();
    }

    @Override
    public void showMessage(String message) {
        Toast.makeText(this, message, Toast.LENGTH_LONG).show();
    }

    @Override
    public void setProgressIndicator(boolean show) {
        if (show)
            showLoadingIndicator();
        else
            hideLoadingIndicator();
    }

    @Override
    public Context getContext() {
        return this;
    }

    @Override
    public void updateSpinner(SparseArray<String> screenList) {
        this.screenList = screenList;
        spinner = findViewById(R.id.spnScreens);

        String[] spinnerArray = new String[screenList.size()];
        for (int i = 0; i < screenList.size(); i++) {
            spinnerArray[i] = screenList.valueAt(i);
        }

        ArrayAdapter<CharSequence> dataAdapter = new ArrayAdapter<CharSequence>(this, android.R.layout.simple_spinner_dropdown_item, spinnerArray);
        dataAdapter.setDropDownViewResource(android.R.layout.simple_dropdown_item_1line);
        spinner.setAdapter(dataAdapter);
        spinner.setSelection(0);
        spinner.setOnItemSelectedListener(this);
        ((TextView) findViewById(R.id.txtName)).setText(screenList.valueAt(0));
    }

    private void editApp() {
        Intent myIntent = new Intent(this, EditActivity.class);
        int screenIndex = screenList.keyAt(spinner.getSelectedItemPosition());
        myIntent.putExtra(MainActivity.INTENT_SCREEN_INDEX, screenIndex);
        this.startActivity(myIntent);
    }

    @Override
    public void setSpinnerSelection(int screenId) {
        for (int i = 0; i < screenList.size(); i++) {
            if (screenList.keyAt(i) == screenId) {
                spinner.setSelection(i);
                break;
            }
        }
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
    public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {
        selectedScreenIndex = i;
        ((TextView) findViewById(R.id.txtName)).setText(screenList.valueAt(i));
    }

    @Override
    public void onNothingSelected(AdapterView<?> adapterView) {

    }

    @Override
    public void onClick(View view) {
        switch (view.getId()) {
            case R.id.btnExport:
                export();
                break;
            case R.id.btnEdit:
                editApp();
                break;
            case R.id.btnNew:
                presentation.create();
                break;
            case R.id.btnDelete:
                delete();
                break;
            case R.id.btnUpdate:
                String screenName = ((TextView) findViewById(R.id.txtName)).getText().toString();
                presentation.update(screenList.keyAt(selectedScreenIndex), screenName);
                break;
            case R.id.btnImport:
                importScreen();
                break;
        }
    }

    private void delete() {
        DialogInterface.OnClickListener dialogClickListener = new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                switch (which) {
                    case DialogInterface.BUTTON_POSITIVE:
                        presentation.delete(screenList.keyAt(selectedScreenIndex));
                        break;
                }
            }
        };

        String confirmation = getString(R.string.activity_screens_confirm_delete, screenList.valueAt(selectedScreenIndex));
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setMessage(Html.fromHtml(confirmation)).setPositiveButton(android.R.string.yes, dialogClickListener)
                .setNegativeButton(android.R.string.no, dialogClickListener).show();
    }

    private void export() {
        String[] perms = {Manifest.permission.WRITE_EXTERNAL_STORAGE};
        if (EasyPermissions.hasPermissions(this, perms)) {
            presentation.exportCurrent(screenList.keyAt(spinner.getSelectedItemPosition()));
        } else {
            // Do not have permissions, request them now
            EasyPermissions.requestPermissions(this, getString(R.string.need_permission), REQUEST_CODE_ASK_PERMISSIONS, perms);
        }
    }

    private void importScreen() {
        String[] perms = {Manifest.permission.WRITE_EXTERNAL_STORAGE};
        if (EasyPermissions.hasPermissions(this, perms)) {
            startImport();
        } else {
            // Do not have permissions, request them now
            EasyPermissions.requestPermissions(this, getString(R.string.need_permission), REQUEST_CODE_ASK_PERMISSIONS, perms);
        }
    }

    private void startImport() {
        Intent intent = new Intent();
        intent.setAction(Intent.ACTION_OPEN_DOCUMENT);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.setType("application/zip");
        startActivityForResult(intent, REQUEST_CODE_IMPORT);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String permissions[], @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);

        // Forward results to EasyPermissions
        EasyPermissions.onRequestPermissionsResult(requestCode, permissions, grantResults, this);
        //        switch (requestCode) {
//            case REQUEST_CODE_ASK_PERMISSIONS: {
//                // If request is cancelled, the result arrays are empty.
//                if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
//                    presentation.exportCurrent(screenList.keyAt(spinner.getSelectedItemPosition()));
//                }
//                break;
//            }
//        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, @Nullable Intent resultData) {
        super.onActivityResult(requestCode, resultCode, resultData);
        if (resultCode == Activity.RESULT_OK) {
            if (requestCode == REQUEST_CODE_IMPORT) {
                if (resultData != null) {
                    Uri currentUri = resultData.getData();
                    presentation.importNew(currentUri);
//                    EditBackgroundFragment.EditDialogListener listener = (EditBackgroundFragment.EditDialogListener) getActivity();
//                    listener.onFinishEditSettingsDialog(-1, currentUri);
//                    dismiss();
                }
            }
        }
    }

    private void startHelp() {
        MaterialTapTargetPrompt.Builder addNew = new MaterialTapTargetPrompt.Builder(this);
        final MaterialTapTargetPrompt.Builder importScreen = new MaterialTapTargetPrompt.Builder(this);
        final MaterialTapTargetPrompt.Builder spinner = new MaterialTapTargetPrompt.Builder(this);
        final MaterialTapTargetPrompt.Builder nameEditor = new MaterialTapTargetPrompt.Builder(this);
        final MaterialTapTargetPrompt.Builder update = new MaterialTapTargetPrompt.Builder(this);
        final MaterialTapTargetPrompt.Builder edit = new MaterialTapTargetPrompt.Builder(this);
        final MaterialTapTargetPrompt.Builder export = new MaterialTapTargetPrompt.Builder(this);
        final MaterialTapTargetPrompt.Builder delete = new MaterialTapTargetPrompt.Builder(this);

        addNew.setTarget(R.id.btnNew)
                .setPrimaryText(R.string.help_addNew_title).setSecondaryText(R.string.help_addNew_desc)
                .setPromptStateChangeListener(new MaterialTapTargetPrompt.PromptStateChangeListener() {
                    @Override
                    public void onPromptStateChanged(@NonNull MaterialTapTargetPrompt prompt, int state) {
                        if (state == MaterialTapTargetPrompt.STATE_DISMISSED)
                        {
                            importScreen.show();
                        }
                    }
                });
        importScreen.setTarget(R.id.btnImport)
                .setPrimaryText(R.string.help_importScreen_title).setSecondaryText(R.string.help_importScreen_desc)
                .setPromptStateChangeListener(new MaterialTapTargetPrompt.PromptStateChangeListener() {
                    @Override
                    public void onPromptStateChanged(@NonNull MaterialTapTargetPrompt prompt, int state) {
                        if (state == MaterialTapTargetPrompt.STATE_DISMISSED)
                        {
                            spinner.show();
                        }
                    }
                });
        spinner.setTarget(R.id.spnScreens)
                .setPrimaryText(R.string.help_spinner_title).setSecondaryText(R.string.help_spinner_desc)
                .setPromptFocal(new RectanglePromptFocal())
                .setPromptStateChangeListener(new MaterialTapTargetPrompt.PromptStateChangeListener() {
                    @Override
                    public void onPromptStateChanged(@NonNull MaterialTapTargetPrompt prompt, int state) {
                        if (state == MaterialTapTargetPrompt.STATE_DISMISSED)
                        {
                            nameEditor.show();
                        }
                    }
                });
        nameEditor.setTarget(R.id.txtName)
                .setPrimaryText(R.string.help_nameEditor_title).setSecondaryText(R.string.help_nameEditor_desc)
                .setPromptFocal(new RectanglePromptFocal())
                .setPromptStateChangeListener(new MaterialTapTargetPrompt.PromptStateChangeListener() {
                    @Override
                    public void onPromptStateChanged(@NonNull MaterialTapTargetPrompt prompt, int state) {                        if (state == MaterialTapTargetPrompt.STATE_DISMISSED)
                    {
                        update.show();
                    }
                    }
                });
        update.setTarget(R.id.btnUpdate)
                .setPrimaryText(R.string.help_update_title).setSecondaryText(R.string.help_update_desc)
                .setPromptStateChangeListener(new MaterialTapTargetPrompt.PromptStateChangeListener() {
                    @Override
                    public void onPromptStateChanged(@NonNull MaterialTapTargetPrompt prompt, int state) {
                        if (state == MaterialTapTargetPrompt.STATE_DISMISSED)
                        {
                            edit.show();
                        }
                    }
                });
        edit.setTarget(R.id.btnEdit)
                .setPrimaryText(R.string.help_edit_title).setSecondaryText(R.string.help_edit_desc)
                .setPromptStateChangeListener(new MaterialTapTargetPrompt.PromptStateChangeListener() {
                    @Override
                    public void onPromptStateChanged(@NonNull MaterialTapTargetPrompt prompt, int state) {
                        if (state == MaterialTapTargetPrompt.STATE_DISMISSED)
                        {
                            export.show();
                        }
                    }
                });
        export.setTarget(R.id.btnExport)
                .setPrimaryText(R.string.help_export_title).setSecondaryText(R.string.help_export_desc)
                .setPromptStateChangeListener(new MaterialTapTargetPrompt.PromptStateChangeListener() {
                    @Override
                    public void onPromptStateChanged(@NonNull MaterialTapTargetPrompt prompt, int state) {
                        if (state == MaterialTapTargetPrompt.STATE_DISMISSED)
                        {
                            delete.show();
                        }
                    }
                });
        delete.setTarget(R.id.btnDelete)
                .setPrimaryText(R.string.help_delete_title).setSecondaryText(R.string.help_delete_desc);
        addNew.show();
    }
}
