package ca.coffeeshopstudio.gaminginterfaceclient.views.screenmanager;

import android.Manifest;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.text.Html;
import android.util.SparseArray;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import ca.coffeeshopstudio.gaminginterfaceclient.R;
import ca.coffeeshopstudio.gaminginterfaceclient.models.screen.ScreenRepository;
import pub.devrel.easypermissions.EasyPermissions;

public class ScreenManagerActivity extends AppCompatActivity implements IContract.IView, AdapterView.OnItemSelectedListener, View.OnClickListener {
    // permissions request code
    private final static int REQUEST_CODE_ASK_PERMISSIONS = 501;
    private final static int REQUEST_CODE_IMPORT = 510;

    private IContract.IViewActionListener actionListener;
    private SparseArray<String> screenList;

    private ProgressDialog dialog;
    private Spinner spinner;
    private int selectedScreenIndex = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_screen_manager);
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        setViewActionListener(new Presentation(new ScreenRepository(getApplicationContext()), this));
        actionListener.load();

        buildControls();
    }

    private void buildControls() {
        findViewById(R.id.btnExport).setOnClickListener(this);
        findViewById(R.id.btnNew).setOnClickListener(this);
        findViewById(R.id.btnUpdate).setOnClickListener(this);
        findViewById(R.id.btnDelete).setOnClickListener(this);
        findViewById(R.id.btnImport).setOnClickListener(this);
    }

    @Override
    public void setViewActionListener(IContract.IViewActionListener listener) {
        actionListener = listener;
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
            case R.id.btnNew:
                actionListener.create();
                break;
            case R.id.btnDelete:
                delete();
                break;
            case R.id.btnUpdate:
                String screenName = ((TextView) findViewById(R.id.txtName)).getText().toString();
                actionListener.update(screenList.keyAt(selectedScreenIndex), screenName);
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
                        actionListener.delete(screenList.keyAt(selectedScreenIndex));
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
            actionListener.exportCurrent(screenList.keyAt(spinner.getSelectedItemPosition()));
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
//                    actionListener.exportCurrent(screenList.keyAt(spinner.getSelectedItemPosition()));
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
                    actionListener.importNew(currentUri);
//                    EditBackgroundFragment.EditDialogListener listener = (EditBackgroundFragment.EditDialogListener) getActivity();
//                    listener.onFinishEditBackgroundDialog(-1, currentUri);
//                    dismiss();
                }
            }
        }
    }
}
