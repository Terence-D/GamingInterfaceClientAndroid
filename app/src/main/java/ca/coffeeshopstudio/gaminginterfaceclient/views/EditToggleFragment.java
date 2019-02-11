package ca.coffeeshopstudio.gaminginterfaceclient.views;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Typeface;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.StateListDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.support.annotation.Nullable;
import android.support.v4.app.DialogFragment;
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
import ca.coffeeshopstudio.gaminginterfaceclient.models.FontAdapter;
import ca.coffeeshopstudio.gaminginterfaceclient.models.FontCache;
import ca.coffeeshopstudio.gaminginterfaceclient.models.GICControl;

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
public class EditToggleFragment extends DialogFragment implements
        ImageGridDialog.ImageGridDialogListener,
        AdapterView.OnItemSelectedListener,
        View.OnClickListener,
        CompoundButton.OnCheckedChangeListener {

    private AutoItKeyMap map = new AutoItKeyMap();
    private View incomingView;
    private Spinner spinner;
    private Spinner spinnerOff;
    private GICControl controlToLoad;

    private CheckBox lShift;
    //private CheckBox rShift;
    private CheckBox lCtrl;
    //private CheckBox rCtrl;
    private CheckBox lAlt;
    //private CheckBox rAlt;
    private CheckBox lShiftOff;
    //private CheckBox rShiftOff;
    private CheckBox lCtrlOff;
    //private CheckBox rCtrlOff;
    private CheckBox lAltOff;
    //private CheckBox rAltOff;

    private TextView text;

    private Button btnFontColor;
    private Button btnPrimary;
    private Button btnSecondary;
    private Button btnNormal;
    private Button btnPressed;
    private Button btnFont;
    private Button preview;

    private int state = 0; //are we looking at normal (0) or secondary (1) for button
    private boolean mode = true;

    // Empty constructor is required for DialogFragment
    // Make sure not to add arguments to the constructor
    // Use `newInstance` instead as shown below
    public EditToggleFragment() {
    }

    public static EditToggleFragment newInstance(GICControl control, View view) {
        EditToggleFragment frag = new EditToggleFragment();
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
        return inflater.inflate(R.layout.fragment_edit_toggle, container);
    }

    private void setupControls(View view) {
        text = view.findViewById(R.id.txtText);
        lShift = view.findViewById(R.id.chkLShift);
        //rShift = view.findViewById(R.id.chkRShift);
        lCtrl = view.findViewById(R.id.chkLCtrl);
        //rCtrl = view.findViewById(R.id.chkRCtrl);
        lAlt = view.findViewById(R.id.chkLAlt);
        //rAlt = view.findViewById(R.id.chkRAlt);

        lShiftOff = view.findViewById(R.id.chkLShiftOff);
        //rShiftOff = view.findViewById(R.id.chkRShiftOff);
        lCtrlOff = view.findViewById(R.id.chkLCtrlOff);
        //rCtrlOff = view.findViewById(R.id.chkRCtrlOff);
        lAltOff = view.findViewById(R.id.chkLAltOff);
        //rAltOff = view.findViewById(R.id.chkRAltOff);

        buildCommandSpinners(view);

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

        if (controlToLoad.getCommandSecondary() != null) {
            lAltOff.setChecked(false);
            lCtrlOff.setChecked(false);
            lShiftOff.setChecked(false);
            for (int i = 0; i < controlToLoad.getCommandSecondary().getModifiers().size(); i++) {
                if (controlToLoad.getCommandSecondary().getModifiers().get(i).equals("ALT"))
                    lAltOff.setChecked(true);
                if (controlToLoad.getCommandSecondary().getModifiers().get(i).equals("CTRL"))
                    lCtrlOff.setChecked(true);
                if (controlToLoad.getCommandSecondary().getModifiers().get(i).equals("SHIFT"))
                    lShiftOff.setChecked(true);
            }
        }

        btnFontColor = view.findViewById(R.id.btnFontColor);
        btnPrimary = view.findViewById(R.id.btnPrimary);
        btnSecondary = view.findViewById(R.id.btnSecondary);
        btnNormal = view.findViewById(R.id.btnNormal);
        btnPressed = view.findViewById(R.id.btnPressed);
        btnFont = view.findViewById(R.id.btnFont);

        btnFontColor.setOnClickListener(this);
        btnFontColor.setTextColor(controlToLoad.getFontColor());

        btnPrimary.setOnClickListener(this);
        btnPrimary.setTextColor(controlToLoad.getPrimaryColor());

        btnSecondary.setOnClickListener(this);
        btnSecondary.setTextColor(controlToLoad.getSecondaryColor());

        btnPressed.setOnClickListener(this);
        btnNormal.setOnClickListener(this);

        btnFont.setOnClickListener(this);

        setFontTypeface();

        preview = view.findViewById(R.id.preview);
        preview.setBackground(buildStatePreview());

        view.findViewById(R.id.btnSave).setOnClickListener(this);
        view.findViewById(R.id.btnDelete).setOnClickListener(this);

        if (controlToLoad.getPrimaryImageResource() != -1 || !controlToLoad.getPrimaryImage().isEmpty()) {
            btnSecondary.setVisibility(View.INVISIBLE);
            btnPrimary.setVisibility(View.INVISIBLE);
            btnPressed.setVisibility(View.VISIBLE);
            btnNormal.setVisibility(View.VISIBLE);
            preview.setVisibility(View.VISIBLE);
        } else {
            btnSecondary.setVisibility(View.VISIBLE);
            btnPrimary.setVisibility(View.VISIBLE);
            btnPressed.setVisibility(View.INVISIBLE);
            btnNormal.setVisibility(View.INVISIBLE);
            preview.setVisibility(View.GONE);
            ((Switch) view.findViewById(R.id.switchType)).setChecked(false);
            mode = false;
        }
        ((Switch) view.findViewById(R.id.switchType)).setOnCheckedChangeListener(this);
    }

    private void buildCommandSpinners(View view) {
        spinner = view.findViewById(R.id.spinner);
        spinner.setOnItemSelectedListener(this);
        spinnerOff = view.findViewById(R.id.spinnerOff);
        spinnerOff.setOnItemSelectedListener(this);

        Collection<String> values = map.getKeys().values();
        String[] spinnerArray = values.toArray(new String[values.size()]);
        ArrayAdapter<CharSequence> dataAdapter = new ArrayAdapter<CharSequence>(getActivity(), android.R.layout.simple_spinner_dropdown_item, spinnerArray);

        dataAdapter.setDropDownViewResource(android.R.layout.simple_dropdown_item_1line);
        spinner.setAdapter(dataAdapter);
        spinnerOff.setAdapter(dataAdapter);

        if (controlToLoad.getCommand() != null) {
            String key = controlToLoad.getCommand().getKey();
            List<String> keys = new ArrayList<>(map.getKeys().keySet());

            for (int i = 0; i < keys.size(); i++) {
                if (keys.get(i).equals(key)) {
                    spinner.setSelection(i);
                    break;
                }
            }
        }
        if (controlToLoad.getCommandSecondary() != null) {
            String key = controlToLoad.getCommandSecondary().getKey();
            List<String> keys = new ArrayList<>(map.getKeys().keySet());

            for (int i = 0; i < keys.size(); i++) {
                if (keys.get(i).equals(key)) {
                    spinnerOff.setSelection(i);
                    break;
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
        EditToggleListener listener = (EditToggleListener) getActivity();
        switch (view.getId()) {
            case R.id.btnSave:
                saveControl();
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
            case R.id.btnFont:
                showFontPopup();
                break;
            default:
                break;
        }
    }

    private void showFontPopup() {
        AlertDialog.Builder builderSingle = new AlertDialog.Builder(getContext());

        builderSingle.setNegativeButton(android.R.string.cancel, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();
            }
        });

        builderSingle.setAdapter(new FontAdapter(getContext(), android.R.layout.simple_list_item_1), new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                if (which == 0) { //IMPORT FONT MAKE THIS 1
                    controlToLoad.setFontName("");
//                } else if (which == 0) {
//                    Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
//                    intent.addCategory(Intent.CATEGORY_OPENABLE);
//                    intent.setType("*/*");
//                    startActivityForResult(intent, EditActivity.OPEN_REQUEST_CODE_FONT);
                } else
                    controlToLoad.setFontName(FontCache.getFontName(which - 1)); //IMPORT FONT MAKE THIS 2
                setFontTypeface();
            }
        });
        builderSingle.show();
    }

    private void setFontTypeface() {
        if (controlToLoad.getFontName().isEmpty()) {
            btnFont.setTypeface(Typeface.DEFAULT);
        } else {
            if (controlToLoad.getFontType() == 0) {
                btnFont.setTypeface(FontCache.get(controlToLoad.getFontName(), getContext()));
            } else {
                btnFont.setTypeface(FontCache.get(controlToLoad.getFontName(), getContext()));
            }
        }
    }

    private void saveControl() {
        List<String> keys = new ArrayList<>(map.getKeys().keySet());
        controlToLoad.setText(text.getText().toString());
        controlToLoad.getCommand().setKey(keys.get(spinner.getSelectedItemPosition()));
        controlToLoad.getCommandSecondary().setKey(keys.get(spinnerOff.getSelectedItemPosition()));
        controlToLoad.setFontColor(btnFontColor.getTextColors().getDefaultColor());

        if (lShift.isChecked()) {
            controlToLoad.getCommand().addModifier("SHIFT");
        }
        if (lCtrl.isChecked()) {
            controlToLoad.getCommand().addModifier("CTRL");
        }
        if (lAlt.isChecked()) {
            controlToLoad.getCommand().addModifier("ALT");
        }

        if (lShiftOff.isChecked()) {
            controlToLoad.getCommandSecondary().addModifier("SHIFT");
        }
        if (lCtrlOff.isChecked()) {
            controlToLoad.getCommandSecondary().addModifier("CTRL");
        }
        if (lAltOff.isChecked()) {
            controlToLoad.getCommandSecondary().addModifier("ALT");
        }

        if (mode) {
            controlToLoad.setSecondaryColor(-1);
            controlToLoad.setPrimaryColor(-1);
        } else {
            controlToLoad.setSecondaryColor(btnSecondary.getTextColors().getDefaultColor());
            controlToLoad.setPrimaryColor(btnPrimary.getTextColors().getDefaultColor());
            controlToLoad.setPrimaryImage("");
            controlToLoad.setSecondaryImage("");
            controlToLoad.setPrimaryImageResource(-1);
            controlToLoad.setSecondaryImageResource(-1);
        }
    }

    private void displayImageLoader() {
        ImageGridDialog gridView = new ImageGridDialog(this);
        gridView.show();
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
        mode = checked;
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
            if (requestCode == EditActivity.OPEN_REQUEST_CODE_IMPORT_SWITCH) {
                if (resultData != null) {
                    Uri currentUri = resultData.getData();
                    if (currentUri != null) {
                        try {
                            Bitmap bitmap = MediaStore.Images.Media.getBitmap(getActivity().getContentResolver(), currentUri);
                            File file = null;
                            for (int i = 0; i < Integer.MAX_VALUE; i++) {
                                file = new File(getContext().getFilesDir(), "switch_" + i + ".png");
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

        if (controlToLoad.getPrimaryImageResource() != -1) {
            normal = getResources().getDrawable(controlToLoad.getPrimaryImageResource());
        }
        if (!controlToLoad.getPrimaryImage().isEmpty()) {
            normal = Drawable.createFromPath(controlToLoad.getPrimaryImage());
        }

        if (controlToLoad.getSecondaryImageResource() != -1) {
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

    public interface EditToggleListener {
        void onFinishEditDialog(boolean toSave, GICControl control);
    }
}