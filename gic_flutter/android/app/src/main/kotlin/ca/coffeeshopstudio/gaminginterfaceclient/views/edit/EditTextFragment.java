package ca.coffeeshopstudio.gaminginterfaceclient.views.edit;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Typeface;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.MediaStore;
import android.text.InputFilter;
import android.util.DisplayMetrics;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.flask.colorpicker.ColorPickerView;
import com.flask.colorpicker.builder.ColorPickerClickListener;
import com.flask.colorpicker.builder.ColorPickerDialogBuilder;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Objects;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;
import ca.coffeeshopstudio.gaminginterfaceclient.R;
import ca.coffeeshopstudio.gaminginterfaceclient.models.FontAdapter;
import ca.coffeeshopstudio.gaminginterfaceclient.models.FontCache;
import ca.coffeeshopstudio.gaminginterfaceclient.models.GICControl;
import ca.coffeeshopstudio.gaminginterfaceclient.utils.NumberFilter;

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
public class EditTextFragment extends DialogFragment implements View.OnClickListener {

    private GICControl controlToLoad;

    private TextView text;
    private Button btnFontColor;
    private Button btnFont;

    private EditText txtLeft;
    private EditText txtTop;
    private EditText txtHeight;
    private EditText txtWidth;
    private EditText txtFontSize;

    private float screenWidth;
    private float screenHeight;

    // Empty constructor is required for DialogFragment
    // Make sure not to add arguments to the constructor
    // Use `newInstance` instead as shown below
    public EditTextFragment() {
    }

    static EditTextFragment newInstance(GICControl control) {
        EditTextFragment frag = new EditTextFragment();
        Bundle args = new Bundle();
        frag.setArguments(args);
        if (control != null)
            frag.loadControl(control);
        return frag;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        Objects.requireNonNull(getDialog()).setTitle(R.string.edit_fragment_title);
        setupControls(view);
    }

    private void loadControl(GICControl control) {
        controlToLoad = control;
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
        return inflater.inflate(R.layout.fragment_edit_text, container);
    }

    @SuppressLint("SetTextI18n")
    private void setupControls(View view) {

        getScreenDimensions();

        buildSizeControls(view);

        text = view.findViewById(R.id.txtText);

        text.setText(controlToLoad.getText());
        //load in any data we brought in
        btnFontColor = view.findViewById(R.id.btnFontColor);
        btnFont = view.findViewById(R.id.btnFont);

        btnFontColor.setOnClickListener(this);
        btnFontColor.setTextColor(controlToLoad.getFontColor());
        btnFont.setOnClickListener(this);

        setFontTypeface();

        view.findViewById(R.id.btnSave).setOnClickListener(this);
        view.findViewById(R.id.btnHelp).setOnClickListener(this);
        view.findViewById(R.id.btnDelete).setOnClickListener(this);

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

    @Override
    public void onClick(View view) {
        EditTextListener listener = (EditTextListener) getActivity();
        switch (view.getId()) {
            case R.id.btnSave:
                saveControl();
                assert listener != null;
                listener.onFinishEditDialog(true, controlToLoad);
                dismiss();
                break;
            case R.id.btnDelete:
                assert listener != null;
                listener.onFinishEditDialog(false, controlToLoad);
                dismiss();
                break;
            case R.id.btnFontColor:
                displayColorPicker(view);
                break;
            case R.id.btnFont:
                showFontPopup();
                break;
            case R.id.btnHelp:
                EditActivity.ShowHelp(getContext(), R.string.help_edit_text);
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
        controlToLoad.setText(text.getText().toString());
        controlToLoad.setFontColor(btnFontColor.getTextColors().getDefaultColor());
        controlToLoad.setFontSize(Integer.parseInt(txtFontSize.getText().toString()));
        controlToLoad.setHeight(Integer.parseInt(txtHeight.getText().toString()));
        controlToLoad.setWidth(Integer.parseInt(txtWidth.getText().toString()));
        controlToLoad.setTop(Float.parseFloat(txtTop.getText().toString()));
        controlToLoad.setLeft(Float.parseFloat(txtLeft.getText().toString()));
    }

    private void displayColorPicker(final View view) {
        ColorPickerDialogBuilder
                .with(Objects.requireNonNull(getContext()))
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
    public void onActivityResult(int requestCode, int resultCode, @Nullable Intent resultData) {
        super.onActivityResult(requestCode, resultCode, resultData);
        if (resultCode == Activity.RESULT_OK) {
            if (requestCode == EditActivity.OPEN_REQUEST_CODE_IMPORT_BUTTON) {
                if (resultData != null) {
                    Uri currentUri = resultData.getData();
                    if (currentUri != null) {
                        try {
                            Bitmap bitmap = MediaStore.Images.Media.getBitmap(Objects.requireNonNull(getActivity()).getContentResolver(), currentUri);
                            File file = null;
                            for (int i = 0; i < Integer.MAX_VALUE; i++) {
                                file = new File(Objects.requireNonNull(getContext()).getFilesDir(), "button_" + i + ".png");
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
                assert resultData != null;
                Uri currentUri = resultData.getData();
                if (currentUri != null) {

                    String sourceFilename = currentUri.getPath();
                    String destinationFilename = Objects.requireNonNull(getContext()).getFilesDir() + currentUri.getLastPathSegment();

                    BufferedInputStream bis = null;
                    BufferedOutputStream bos = null;

                    try {
                        assert sourceFilename != null;
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

    public interface EditTextListener {
        void onFinishEditDialog(boolean toSave, GICControl control);
    }

}