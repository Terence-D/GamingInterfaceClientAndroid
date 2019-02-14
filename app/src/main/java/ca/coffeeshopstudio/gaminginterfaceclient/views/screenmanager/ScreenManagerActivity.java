package ca.coffeeshopstudio.gaminginterfaceclient.views.screenmanager;

import android.app.ProgressDialog;
import android.content.Context;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.SparseArray;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Spinner;
import android.widget.TextView;

import ca.coffeeshopstudio.gaminginterfaceclient.R;
import ca.coffeeshopstudio.gaminginterfaceclient.models.screen.ScreenRepository;

public class ScreenManagerActivity extends AppCompatActivity implements IContract.IView, AdapterView.OnItemSelectedListener {
    private ProgressDialog dialog;
    private IContract.IViewActionListener actionListener;
    private SparseArray<String> screenList;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_screen_manager);
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        setViewActionListener(new Presentation(new ScreenRepository(getApplicationContext()), this));
        actionListener.load();
    }

    @Override
    public void setViewActionListener(IContract.IViewActionListener listener) {
        actionListener = listener;
    }

    @Override
    public void showError(int errorResource) {

    }

    @Override
    public void showMessage(int messageId) {

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
        return null;
    }

    @Override
    public void updateSpinner(SparseArray<String> screenList) {
        this.screenList = screenList;
        Spinner spinner = findViewById(R.id.spnScreens);

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
}
