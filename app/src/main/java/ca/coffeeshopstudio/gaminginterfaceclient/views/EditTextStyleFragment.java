package ca.coffeeshopstudio.gaminginterfaceclient.views;

import android.Manifest;
import android.app.Activity;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.StateListDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.support.annotation.Nullable;
import android.support.v4.app.ActivityCompat;
import android.support.v4.app.DialogFragment;
import android.support.v4.content.ContextCompat;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.Spinner;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;

import com.flask.colorpicker.ColorPickerView;
import com.flask.colorpicker.builder.ColorPickerClickListener;
import com.flask.colorpicker.builder.ColorPickerDialogBuilder;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import ca.coffeeshopstudio.gaminginterfaceclient.R;
import ca.coffeeshopstudio.gaminginterfaceclient.models.AutoItKeyMap;
import ca.coffeeshopstudio.gaminginterfaceclient.models.GICControl;

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
public class EditTextStyleFragment extends DialogFragment implements
        ImageGridDialog.ImageGridDialogListener,
        AdapterView.OnItemSelectedListener,
        View.OnClickListener,
        CompoundButton.OnCheckedChangeListener {

    private AutoItKeyMap map = new AutoItKeyMap();
    private View incomingView;
    private Spinner spinner;
    private GICControl controlToLoad;

    private CheckBox lShift;
    //private CheckBox rShift;
    private CheckBox lCtrl;
    //private CheckBox rCtrl;
    private CheckBox lAlt;
    //private CheckBox rAlt;
    private TextView text;

    private Button btnFont;
    private Button btnPrimary;
    private Button btnSecondary;
    private Button btnNormal;
    private Button btnPressed;
    private Button preview;

    private int state = 0; //are we looking at normal (0) or secondary (1) for button

    // Empty constructor is required for DialogFragment
    // Make sure not to add arguments to the constructor
    // Use `newInstance` instead as shown below
    public EditTextStyleFragment() {
    }

    public static EditTextStyleFragment newInstance(GICControl control, View view) {
        EditTextStyleFragment frag = new EditTextStyleFragment();
        Bundle args = new Bundle();
        frag.setArguments(args);
        if (view != null)
            frag.loadView(view);
        if (control != null)
            frag.loadControl(control);
        return frag;
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        setupControls(view);
    }

    public void loadControl(GICControl control) {
        controlToLoad = control;
    }

    public void loadView(View view) {
        incomingView = view;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_edit_control, container);
    }

    private void setupControls(View view) {
        text = view.findViewById(R.id.txtText);
        lShift = view.findViewById(R.id.chkLShift);
        //rShift = view.findViewById(R.id.chkRShift);
        lCtrl = view.findViewById(R.id.chkLCtrl);
        //rCtrl = view.findViewById(R.id.chkRCtrl);
        lAlt = view.findViewById(R.id.chkLAlt);
        //rAlt = view.findViewById(R.id.chkRAlt);

        buildCommandSpinner(view);

        text.setText(controlToLoad.getText());
        //load in any data we brought in
        if (controlToLoad.getCommand() != null) {
            lAlt.setChecked(false);
            lCtrl.setChecked(false);
            lShift.setChecked(false);
            for (int i = 0; i < controlToLoad.getCommand().getModifiers().size(); i++) {
                if (controlToLoad.getCommand().getModifiers().get(i).equals("ALT"))
                    lAlt.setChecked(true);
                if (controlToLoad.getCommand().getModifiers().get(i).equals("CTRL"))
                    lCtrl.setChecked(true);
                if (controlToLoad.getCommand().getModifiers().get(i).equals("SHIFT"))
                    lShift.setChecked(true);
            }
        }

        btnFont = view.findViewById(R.id.btnFontColor);
        btnPrimary = view.findViewById(R.id.btnPrimary);
        btnSecondary = view.findViewById(R.id.btnSecondary);
        btnNormal = view.findViewById(R.id.btnNormal);
        btnPressed = view.findViewById(R.id.btnPressed);

        btnFont.setOnClickListener(this);
        btnFont.setTextColor(controlToLoad.getFontColor());

        btnPrimary.setOnClickListener(this);
        btnPrimary.setTextColor(controlToLoad.getPrimaryColor());

        btnSecondary.setOnClickListener(this);
        btnSecondary.setTextColor(controlToLoad.getSecondaryColor());

        btnPressed.setOnClickListener(this);
        btnNormal.setOnClickListener(this);

        preview = view.findViewById(R.id.preview);
        preview.setBackground(buildStatePreview());

        view.findViewById(R.id.btnSave).setOnClickListener(this);
        view.findViewById(R.id.btnDelete).setOnClickListener(this);

        ((Switch) view.findViewById(R.id.switchType)).setOnCheckedChangeListener(this);

        if (incomingView != null && !(incomingView instanceof Button)) {
            view.findViewById(R.id.btnSecondary).setVisibility(View.INVISIBLE);
            view.findViewById(R.id.btnPrimary).setVisibility(View.INVISIBLE);
            view.findViewById(R.id.btnPressed).setVisibility(View.INVISIBLE);
            view.findViewById(R.id.btnNormal).setVisibility(View.INVISIBLE);
            view.findViewById(R.id.switchType).setVisibility(View.INVISIBLE);
            view.findViewById(R.id.preview).setVisibility(View.INVISIBLE);

            view.findViewById(R.id.lblInstructions).setVisibility(View.INVISIBLE);
            view.findViewById(R.id.spinner).setVisibility(View.INVISIBLE);
            view.findViewById(R.id.chkLShift).setVisibility(View.INVISIBLE);
            view.findViewById(R.id.chkLAlt).setVisibility(View.INVISIBLE);
            view.findViewById(R.id.chkLCtrl).setVisibility(View.INVISIBLE);
        }
    }

    private void buildCommandSpinner(View view) {
        spinner = view.findViewById(R.id.spinner);
        spinner.setOnItemSelectedListener(this);

        Collection<String> values = map.getKeys().values();
        String[] spinnerArray = values.toArray(new String[values.size()]);
        ArrayAdapter<CharSequence> dataAdapter = new ArrayAdapter<CharSequence>(getActivity(), android.R.layout.simple_spinner_dropdown_item, spinnerArray);

        dataAdapter.setDropDownViewResource(android.R.layout.simple_dropdown_item_1line);
        spinner.setAdapter(dataAdapter);

        if (controlToLoad.getCommand() != null) {
            String key = controlToLoad.getCommand().getKey();
            List<String> keys = new ArrayList<>(map.getKeys().keySet());

            for (int i = 0; i < keys.size(); i++) {
                if (keys.get(i).equals(key)) {
                    spinner.setSelection(i);
                    return;
                }
            }
        }
    }

    @Override
    public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {

    }

    @Override
    public void onNothingSelected(AdapterView<?> adapterView) {

    }

    @Override
    public void onClick(View view) {
        EditDialogListener listener = (EditDialogListener) getActivity();
        switch (view.getId()) {
            case R.id.btnSave:
                List<String> keys = new ArrayList<>(map.getKeys().keySet());
                controlToLoad.getCommand().setKey(keys.get(spinner.getSelectedItemPosition()));
                controlToLoad.setText(text.getText().toString());
                if (lShift.isChecked()) {
                    controlToLoad.getCommand().addModifier("SHIFT");
                }
                if (lCtrl.isChecked()) {
                    controlToLoad.getCommand().addModifier("CTRL");
                }
                if (lAlt.isChecked()) {
                    controlToLoad.getCommand().addModifier("ALT");
                }
                //for now disabling "right" handed modifiers.  AutoIt seems to have a bug
                //where it won't properly release them.
//                if (rShift.isChecked()) {
//                    savedCommand.addModifier("SHIFT");
//                }
//                if (rCtrl.isChecked()) {
//                    savedCommand.addModifier("CTRL");
//                }
//                if (rAlt.isChecked()) {
//                    savedCommand.addModifier("ALT");
//                }
                listener.onFinishEditDialog(true, controlToLoad);
                dismiss();
                break;
            case R.id.btnDelete:
                listener.onFinishEditDialog(false, controlToLoad);
                dismiss();
                break;
            case R.id.btnPrimary:
                displayColorPicker(view);
                break;
            case R.id.btnSecondary:
                displayColorPicker(view);
                break;
            case R.id.btnFontColor:
                displayColorPicker(view);
                break;
            case R.id.btnPressed:
                state = 1;
                displayImageLoader();
                break;
            case R.id.btnNormal:
                state = 0;
                displayImageLoader();
                break;
            default:
                break;
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
        switch (requestCode) {
            case 1337: {
                // If request is cancelled, the result arrays are empty.
                if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    displayImageLoader();
                }
            }
            break;
        }
    }

    private void displayImageLoader() {
        if (ContextCompat.checkSelfPermission(getActivity(), Manifest.permission.READ_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
            // Permission is not granted
            // Should we show an explanation?
            if (ActivityCompat.shouldShowRequestPermissionRationale(getActivity(), Manifest.permission.READ_EXTERNAL_STORAGE)) {
                // Show an explanation to the user *asynchronously* -- don't block
                // this thread waiting for the user's response! After the user
                // sees the explanation, try again to request the permission.
                Toast.makeText(getActivity(), "test", Toast.LENGTH_SHORT).show();
            } else {
                // No explanation needed, we can request the permission.
                ActivityCompat.requestPermissions(getActivity(),
                        new String[]{Manifest.permission.READ_EXTERNAL_STORAGE}, 1337);
            }
        } else {
            ImageGridDialog gridView = new ImageGridDialog(this);
            gridView.show();
        }
    }

    private void displayColorPicker(final View view) {
        ColorPickerDialogBuilder
                .with(getContext())
                .setTitle(getString(R.string.color_picker_title))
                .initialColor(((Button) view).getCurrentTextColor())
                .wheelType(ColorPickerView.WHEEL_TYPE.FLOWER)
                .density(12)
                .setPositiveButton(getString(android.R.string.ok), new ColorPickerClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int selectedColor, Integer[] allColors) {
                        if (view.getId() == R.id.btnColor1) {
                            controlToLoad.setPrimaryImage("");
                            controlToLoad.setPrimaryImageResource(-1);
                            controlToLoad.setPrimaryColor(selectedColor);
                        } else if (view.getId() == R.id.btnColor2) {
                            controlToLoad.setSecondaryImage("");
                            controlToLoad.setSecondaryImageResource(-1);
                            controlToLoad.setSecondaryColor(selectedColor);
                        } else {
                            controlToLoad.setFontColor(selectedColor);
                        }
                        ((Button) view).setTextColor(selectedColor);
                    }
                })
                .setNegativeButton(getString(android.R.string.cancel), new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                    }
                })
                .build()
                .show();
    }

    @Override
    public void onCheckedChanged(CompoundButton compoundButton, boolean checked) {
        if (checked) {
            btnSecondary.setVisibility(View.INVISIBLE);
            btnPrimary.setVisibility(View.INVISIBLE);
            preview.setVisibility(View.VISIBLE);
            btnNormal.setVisibility(View.VISIBLE);
            btnPressed.setVisibility(View.VISIBLE);
            if (controlToLoad.getPrimaryImageResource() == -1 && controlToLoad.getPrimaryImage().isEmpty()) {
                controlToLoad.setPrimaryImageResource(R.drawable.neon_button);
            }
            if (controlToLoad.getSecondaryImageResource() == -1 && controlToLoad.getSecondaryImage().isEmpty()) {
                controlToLoad.setSecondaryImageResource(R.drawable.neon_button_pressed);
            }
            preview.setBackground(buildStatePreview());
        } else {
            btnSecondary.setVisibility(View.VISIBLE);
            btnPrimary.setVisibility(View.VISIBLE);
            preview.setVisibility(View.INVISIBLE);
            btnNormal.setVisibility(View.INVISIBLE);
            btnPressed.setVisibility(View.INVISIBLE);
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, @Nullable Intent resultData) {
        super.onActivityResult(requestCode, resultCode, resultData);
        if (resultCode == Activity.RESULT_OK) {
            if (requestCode == EditActivity.OPEN_REQUEST_CODE_IMPORT_BUTTON) {
                if (resultData != null) {
                    Uri currentUri = resultData.getData();
                    if (currentUri != null) {
                        try {
                            Bitmap bitmap = MediaStore.Images.Media.getBitmap(getActivity().getContentResolver(), currentUri);
                            File file = null;
                            for (int i = 0; i < Integer.MAX_VALUE; i++) {
                                file = new File(getContext().getFilesDir(), "button_" + i + ".png");
                                if (!file.exists())
                                    break;
                            }
                            FileOutputStream out = new FileOutputStream(file);
                            bitmap.compress(Bitmap.CompressFormat.PNG, 90, out);
                            out.flush();
                            out.close();
                        } catch (IOException e) {
                            Toast.makeText(getActivity(), e.getLocalizedMessage(), Toast.LENGTH_LONG).show();
                        }
                    }
                }
            }
        }
    }

    @Override
    public void onImageSelected(String custom) {
        if (state == 0) {
            controlToLoad.setPrimaryImage(custom);
            controlToLoad.setPrimaryImageResource(-1);
        }
        if (state == 1) {
            controlToLoad.setSecondaryImage(custom);
            controlToLoad.setSecondaryImageResource(-1);
        }
        controlToLoad.setPrimaryColor(-1);
        controlToLoad.setSecondaryColor(-1);
        preview.setBackground(buildStatePreview());
    }

    @Override
    public void onImageSelected(int builtIn) {
        if (state == 0) {
            controlToLoad.setPrimaryImage("");
            controlToLoad.setPrimaryImageResource(builtIn);
        }
        if (state == 1) {
            controlToLoad.setSecondaryImage("");
            controlToLoad.setSecondaryImageResource(builtIn);
        }
        controlToLoad.setPrimaryColor(-1);
        controlToLoad.setSecondaryColor(-1);
        preview.setBackground(buildStatePreview());
    }

    private StateListDrawable buildStatePreview() {
        Drawable normal = null;
        Drawable secondary = null;

        if (controlToLoad.getPrimaryImageResource() > -1) {
            normal = getResources().getDrawable(controlToLoad.getPrimaryImageResource());
        }
        if (!controlToLoad.getPrimaryImage().isEmpty()) {
            normal = Drawable.createFromPath(controlToLoad.getPrimaryImage());
        }

        if (controlToLoad.getSecondaryImageResource() > -1) {
            secondary = getResources().getDrawable(controlToLoad.getSecondaryImageResource());
        }
        if (!controlToLoad.getSecondaryImage().isEmpty()) {
            secondary = Drawable.createFromPath(controlToLoad.getSecondaryImage());
        }

        StateListDrawable res = new StateListDrawable();
        if (normal != null && secondary != null) {
            res.addState(new int[]{android.R.attr.state_pressed}, secondary);
            res.addState(new int[]{}, normal);
        }
        return res;
    }

    public interface EditDialogListener {
        void onFinishEditDialog(boolean toSave, GICControl control);
    }

}