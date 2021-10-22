package ca.coffeeshopstudio.gaminginterfaceclient.views.edit;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.Typeface;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.StateListDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.text.InputFilter;
import android.util.DisplayMetrics;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;

import com.flask.colorpicker.ColorPickerView;
import com.flask.colorpicker.builder.ColorPickerClickListener;
import com.flask.colorpicker.builder.ColorPickerDialogBuilder;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Objects;

import ca.coffeeshopstudio.gaminginterfaceclient.R;
import ca.coffeeshopstudio.gaminginterfaceclient.models.AutoItKeyMap;
import ca.coffeeshopstudio.gaminginterfaceclient.models.ControlTypes;
import ca.coffeeshopstudio.gaminginterfaceclient.models.FontAdapter;
import ca.coffeeshopstudio.gaminginterfaceclient.models.FontCache;
import ca.coffeeshopstudio.gaminginterfaceclient.models.GICControl;
import ca.coffeeshopstudio.gaminginterfaceclient.models.ImageAdapter;
import ca.coffeeshopstudio.gaminginterfaceclient.utils.NumberFilter;

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
public class EditButtonFragment extends DialogFragment implements
        AdapterView.OnItemSelectedListener,
        View.OnClickListener,
        AbstractGridDialog.GridDialogListener,
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
    private Switch quickMode;

    private Button btnFontColor;
    private Button btnPrimary;
    private Button btnSecondary;
    private Button btnNormal;
    private Button btnPressed;
    private Button btnFont;
    private Button preview;

    private EditText txtLeft;
    private EditText txtTop;
    private EditText txtHeight;
    private EditText txtWidth;
    private EditText txtFontSize;

    private int state = 0; //are we looking at normal (0) or secondary (1) for button
    private boolean mode = true;

    private float screenWidth;
    private float screenHeight;

    // Empty constructor is required for DialogFragment
    // Make sure not to add arguments to the constructor
    // Use `newInstance` instead as shown below
    public EditButtonFragment() {
    }

    static EditButtonFragment newInstance(GICControl control, View view) {
        EditButtonFragment frag = new EditButtonFragment();
        Bundle args = new Bundle();
        frag.setArguments(args);
        if (view != null)
            frag.loadView(view);
        if (control != null)
            frag.loadControl(control);
        return frag;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        getDialog().setTitle(R.string.edit_fragment_title);
        setupControls(view);
    }

    private void loadControl(GICControl control) {
        controlToLoad = control;
        if (controlToLoad.getPrimaryImage() == null)
            controlToLoad.setPrimaryImage("");
        if (controlToLoad.getSecondaryImage() == null)
            controlToLoad.setSecondaryImage("");
    }

    private void loadView(View view) {
        incomingView = view;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

//        if (((App) Objects.requireNonNull(getContext()).getApplicationContext()).isNightModeEnabled())
//            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
//                setStyle(DialogFragment.STYLE_NORMAL, android.R.style.Theme_Material_Dialog);
//            } else {
//                setStyle(DialogFragment.STYLE_NORMAL, android.R.style.Theme_Holo_Dialog);
//            }
    }

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        Objects.requireNonNull(Objects.requireNonNull(getDialog()).getWindow()).setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN);
        return inflater.inflate(R.layout.fragment_edit_button, container);
    }

    @SuppressLint("SetTextI18n")
    private void setupControls(View view) {

        getScreenDimensions();

        buildSizeControls(view);

        text = view.findViewById(R.id.txtText);
        lShift = view.findViewById(R.id.chkLShift);
        //rShift = view.findViewById(R.id.chkRShift);
        lCtrl = view.findViewById(R.id.chkLCtrl);
        //rCtrl = view.findViewById(R.id.chkRCtrl);
        lAlt = view.findViewById(R.id.chkLAlt);
        //rAlt = view.findViewById(R.id.chkRAlt);

        quickMode = view.findViewById(R.id.switchQuick);
        if (controlToLoad.getViewType() == GICControl.TYPE_BUTTON_QUICK)
            quickMode.setChecked(true);

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
        view.findViewById(R.id.btnHelp).setOnClickListener(this);
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
            preview.setVisibility(View.INVISIBLE);
            ((Switch) view.findViewById(R.id.switchType)).setChecked(false);
            mode = false;
        }
        ((Switch) view.findViewById(R.id.switchType)).setOnCheckedChangeListener(this);
    }

    private void buildSizeControls(View view) {
        txtFontSize = view.findViewById(R.id.txtFontSize);
        txtHeight = view.findViewById(R.id.txtHeight);
        txtLeft = view.findViewById(R.id.txtLeft);
        txtTop = view.findViewById(R.id.txtTop);
        txtWidth = view.findViewById(R.id.txtWidth);

        txtFontSize.setText(Integer.toString(controlToLoad.getFontSize()));
        txtHeight.setText(Integer.toString(controlToLoad.getHeight()));
        txtLeft.setText(Float.toString(controlToLoad.getLeft()));
        txtTop.setText(Float.toString(controlToLoad.getTop()));
        txtWidth.setText(Integer.toString(controlToLoad.getWidth()));

        txtFontSize.setFilters(new InputFilter[]{new NumberFilter(1, 1000)});
        txtHeight.setFilters(new InputFilter[]{new NumberFilter(1, (int) screenHeight)});
        txtLeft.setFilters(new InputFilter[]{new NumberFilter(1, (int) screenWidth)});
        txtTop.setFilters(new InputFilter[]{new NumberFilter(1, (int) (screenHeight - 10))});
        txtWidth.setFilters(new InputFilter[]{new NumberFilter(1, (int) (screenWidth - 10))});
    }

    private void getScreenDimensions() {
        DisplayMetrics displayMetrics = getResources().getDisplayMetrics();
        screenHeight = displayMetrics.heightPixels / displayMetrics.density;
        screenWidth = displayMetrics.widthPixels / displayMetrics.density;
    }

    private void buildCommandSpinner(View view) {
        spinner = view.findViewById(R.id.spinner);
        spinner.setOnItemSelectedListener(this);

        Collection<String> values = map.getKeys().values();
        String[] spinnerArray = values.toArray(new String[values.size()]);
        ArrayAdapter<CharSequence> dataAdapter = new ArrayAdapter<CharSequence>(getActivity(), android.R.layout.simple_spinner_dropdown_item, spinnerArray);

        dataAdapter.setDropDownViewResource(R.layout.simple_dropdown_item_1line);
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
//        if (((App) getContext().getApplicationContext()).isNightModeEnabled())
//            ((TextView) adapterView.getChildAt(0)).setTextColor(Color.WHITE);
    }

    @Override
    public void onNothingSelected(AdapterView<?> adapterView) {

    }

    @Override
    public void onClick(View view) {
        EditButtonListener listener = (EditButtonListener) getActivity();
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
                assert listener != null;
                listener.onFinishEditDialog(true, controlToLoad);
                dismiss();
                break;
            case R.id.btnDelete:
                assert listener != null;
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
            case R.id.btnHelp:
                EditActivity.ShowHelp(getContext(), R.string.help_edit_button);
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
        controlToLoad.setFontColor(btnFontColor.getTextColors().getDefaultColor());

        controlToLoad.setFontSize(Integer.parseInt(txtFontSize.getText().toString()));
        controlToLoad.setHeight(Integer.parseInt(txtHeight.getText().toString()));
        controlToLoad.setWidth(Integer.parseInt(txtWidth.getText().toString()));
        controlToLoad.setTop(Float.parseFloat(txtTop.getText().toString()));
        controlToLoad.setLeft(Float.parseFloat(txtLeft.getText().toString()));

        controlToLoad.getCommand().removeAllModifiers();
        if (lShift.isChecked()) {
            controlToLoad.getCommand().addModifier("SHIFT");
        }
        if (lCtrl.isChecked()) {
            controlToLoad.getCommand().addModifier("CTRL");
        }
        if (lAlt.isChecked()) {
            controlToLoad.getCommand().addModifier("ALT");
        }

        if (incomingView instanceof Button) {
            if (quickMode.isChecked())
                controlToLoad.setViewType(GICControl.TYPE_BUTTON_QUICK);
            else
                controlToLoad.setViewType(GICControl.TYPE_BUTTON);
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
        ImageGridDialog gridView = new ImageGridDialog(this, new ImageAdapter(getContext()));
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
                controlToLoad.setPrimaryImageResource(0);
            }
            if (controlToLoad.getSecondaryImageResource() == -1 && controlToLoad.getSecondaryImage().isEmpty()) {
                controlToLoad.setSecondaryImageResource(1);
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
            } else if (requestCode == EditActivity.OPEN_REQUEST_CODE_FONT) {
                Uri currentUri = resultData.getData();
                if (currentUri != null) {

                    String sourceFilename = currentUri.getPath();
                    String destinationFilename = getContext().getFilesDir() + currentUri.getLastPathSegment();

                    BufferedInputStream bis = null;
                    BufferedOutputStream bos = null;

                    try {
                        bis = new BufferedInputStream(new FileInputStream(sourceFilename));
                        bos = new BufferedOutputStream(new FileOutputStream(destinationFilename, false));
                        byte[] buf = new byte[1024];
                        bis.read(buf);
                        do {
                            bos.write(buf);
                        } while (bis.read(buf) != -1);
                    } catch (IOException e) {
                        e.printStackTrace();
                    } finally {
                        try {
                            if (bis != null) bis.close();
                            if (bos != null) bos.close();
                        } catch (IOException e) {
                            e.printStackTrace();
                        }
                    }
                }
            }

        }
    }

    @Override
    public void onImageSelected(String custom, int actionRequest) {
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
    public void onImageSelected(int builtIn, int actionRequest) {
        if (state == 0) {
            controlToLoad.setPrimaryImage("");
            controlToLoad.setPrimaryImageResource(ControlTypes.GetButtonByResourceId(builtIn));
        }
        if (state == 1) {
            controlToLoad.setSecondaryImage("");
            controlToLoad.setSecondaryImageResource(ControlTypes.GetButtonByResourceId(builtIn));
        }
        controlToLoad.setPrimaryColor(-1);
        controlToLoad.setSecondaryColor(-1);
        preview.setBackground(buildStatePreview());
    }

    private StateListDrawable buildStatePreview() {
        Drawable normal = null;
        Drawable secondary = null;

        if (controlToLoad.getPrimaryImageResource() != -1) {
            normal = getResources().getDrawable(ControlTypes.GetButtonDrawableId(controlToLoad.getPrimaryImageResource(), true));
        }
        if (controlToLoad.getPrimaryImage() != null && !controlToLoad.getPrimaryImage().isEmpty()) {
            normal = Drawable.createFromPath(controlToLoad.getPrimaryImage());
        }

        if (controlToLoad.getSecondaryImageResource() != -1) {
            secondary = getResources().getDrawable(ControlTypes.GetButtonDrawableId(controlToLoad.getSecondaryImageResource(), false));
        }
        if (controlToLoad.getSecondaryImage() != null && !controlToLoad.getSecondaryImage().isEmpty()) {
            secondary = Drawable.createFromPath(controlToLoad.getSecondaryImage());
        }

        StateListDrawable res = new StateListDrawable();
        if (normal != null && secondary != null) {
            res.addState(new int[]{android.R.attr.state_pressed}, secondary);
            res.addState(new int[]{}, normal);
        }
        return res;
    }

    public interface EditButtonListener {
        void onFinishEditDialog(boolean toSave, GICControl control);
    }

}