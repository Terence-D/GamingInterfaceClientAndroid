package ca.coffeeshopstudio.gaminginterfaceclient.views.screenmanager;

import android.Manifest;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.SparseArray;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import ca.coffeeshopstudio.gaminginterfaceclient.R;
import ca.coffeeshopstudio.gaminginterfaceclient.models.screen.ScreenRepository;

public class ScreenManagerActivity extends AppCompatActivity implements IContract.IView, AdapterView.OnItemSelectedListener, View.OnClickListener {
    // permissions request code
    private final static int REQUEST_CODE_ASK_PERMISSIONS = 501;

    private IContract.IViewActionListener actionListener;
    private SparseArray<String> screenList;

    private ProgressDialog dialog;
    private Spinner spinner;

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
        }
    }

    private void export() {
        //first ensure we have write permission
        checkPermissions();
    }

    protected void checkPermissions() {
        int permissionCheck = ContextCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE);
        if (permissionCheck != PackageManager.PERMISSION_GRANTED) {
            // User may have declined earlier, ask Android if we should show him a reason
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                if (shouldShowRequestPermissionRationale(Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
                    // show an explanation to the user
                    // Good practise: don't block thread after the user sees the explanation, try again to request the permission.
                    Toast.makeText(this, R.string.need_permission, Toast.LENGTH_SHORT).show();
                } else {
                    // request the permission.
                    // CALLBACK_NUMBER is a integer constants
                    requestPermissions(new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE}, REQUEST_CODE_ASK_PERMISSIONS);
                    // The callback method gets the result of the request.
                }
            } else {
                actionListener.exportCurrent(screenList.keyAt(spinner.getSelectedItemPosition()));
            }
        } else {
            actionListener.exportCurrent(screenList.keyAt(spinner.getSelectedItemPosition()));
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String permissions[], @NonNull int[] grantResults) {
        switch (requestCode) {
            case REQUEST_CODE_ASK_PERMISSIONS: {
                // If request is cancelled, the result arrays are empty.
                if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    actionListener.exportCurrent(screenList.keyAt(spinner.getSelectedItemPosition()));
                }
                break;
            }
        }
    }
}
