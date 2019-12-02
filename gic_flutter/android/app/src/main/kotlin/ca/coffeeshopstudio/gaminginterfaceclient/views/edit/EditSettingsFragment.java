package ca.coffeeshopstudio.gaminginterfaceclient.views.edit;

import android.app.Activity;
import android.app.Dialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.provider.MediaStore;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.Button;
import android.widget.SeekBar;
import android.widget.Toast;

import com.flask.colorpicker.ColorPickerView;
import com.flask.colorpicker.builder.ColorPickerClickListener;
import com.flask.colorpicker.builder.ColorPickerDialogBuilder;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Objects;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;
import ca.coffeeshopstudio.gaminginterfaceclient.R;

import static ca.coffeeshopstudio.gaminginterfaceclient.views.edit.EditActivity.PREF_KEY_GRID_SIZE;

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
public class EditSettingsFragment extends DialogFragment implements View.OnClickListener {
    private int primary;
    private Button btnPrimary;
    private SeekBar seekGridSize;
    private int screenId;
    private boolean changedColor = false;

    @NonNull
    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        Dialog dialog = super.onCreateDialog(savedInstanceState);
        Objects.requireNonNull(dialog.getWindow()).requestFeature(Window.FEATURE_NO_TITLE);

        return dialog;
    }
    // Empty constructor is required for DialogFragment
    // Make sure not to add arguments to the constructor
    // Use `newInstance` instead as shown below
    public EditSettingsFragment() {
    }

    public static EditSettingsFragment newInstance(int primary, int screenId) {
        EditSettingsFragment frag = new EditSettingsFragment();
        Bundle args = new Bundle();
        args.putInt("primary", primary);
        args.putInt("screen", screenId);
        frag.setArguments(args);
        return frag;
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        // Fetch arguments from bundle and set title
        primary = getArguments().getInt("primary", Color.BLACK);
        screenId = getArguments().getInt("screen", 0);
        getDialog().setTitle(R.string.edit_fragment_settings_title);
        setupControls(view);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_edit_settings, container);
    }

    @Override
    public void onStart() {
        super.onStart();

        Dialog dialog = getDialog();
        if (dialog != null) {
            Objects.requireNonNull(dialog.getWindow()).setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        }
    }

    private void setupControls(View view) {
        btnPrimary = view.findViewById(R.id.btnColor1);
        btnPrimary.setOnClickListener(this);
        btnPrimary.setTextColor(primary);

        seekGridSize = view.findViewById(R.id.seekGrid);
        int gridSize = PreferenceManager.getDefaultSharedPreferences(getContext())
                .getInt(PREF_KEY_GRID_SIZE, 64);
        seekGridSize.setProgress((gridSize / 32));

        view.findViewById(R.id.btnBackgroundImage).setOnClickListener(this);
        view.findViewById(R.id.btnSave).setOnClickListener(this);
    }

    @Override
    public void onClick(View view) {
        EditDialogListener listener = (EditDialogListener) getActivity();
        switch (view.getId()) {
            case R.id.btnSave:
                int gridSize = seekGridSize.getProgress() * 32;
                PreferenceManager.getDefaultSharedPreferences(getContext()).edit()
                        .putInt(PREF_KEY_GRID_SIZE, gridSize)
                        .apply();

                int colorToSend = -1; //default to no change
                if (changedColor)
                    colorToSend = btnPrimary.getTextColors().getDefaultColor();
                listener.onFinishEditSettingsDialog(colorToSend, null);
                dismiss();
                break;
            case R.id.btnColor1:
                displayColorPicker(view);
                break;
            case R.id.btnBackgroundImage:
                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
                    Toast.makeText(getContext(), R.string.android_too_old, Toast.LENGTH_SHORT).show();
                } else {
                    Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
                    intent.addCategory(Intent.CATEGORY_OPENABLE);
                    intent.setType("image/*");
                    startActivityForResult(intent, EditActivity.OPEN_REQUEST_CODE_BACKGROUND);
                }
                break;
            default:
                break;
        }
    }

    private void displayColorPicker(final View view) {
        ColorPickerDialogBuilder
                .with(getContext())
                .setTitle(getString(R.string.color_picker_title))
                .initialColor(((Button) view).getCurrentTextColor())
                .wheelType(ColorPickerView.WHEEL_TYPE.FLOWER)
                .density(12)
//                .setOnColorSelectedListener(new OnColorSelectedListener() {
//                    @Override
//                    public void onColorSelected(int selectedColor) {
//                        //toast("onColorSelected: 0x" + Integer.toHexString(selectedColor));
//                    }
//                })
                .setPositiveButton(getString(android.R.string.ok), new ColorPickerClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int selectedColor, Integer[] allColors) {
                        ((Button) view).setTextColor(selectedColor);
                        changedColor = true;
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
        if (resultCode == Activity.RESULT_OK)
        {
            if (requestCode == EditActivity.OPEN_REQUEST_CODE_BACKGROUND) {
                if (resultData != null) {
                    Uri currentUri = resultData.getData();
                    File file = null;
                    if (currentUri != null) {
                        try {
                            Bitmap bitmap = MediaStore.Images.Media.getBitmap(getActivity().getContentResolver(), currentUri);
                            file = new File(getContext().getFilesDir(), screenId + "_background.png");
                            FileOutputStream out = new FileOutputStream(file);
                            bitmap.compress(Bitmap.CompressFormat.PNG, 90, out);
                            out.flush();
                            out.close();
                        } catch (IOException e) {
                            Toast.makeText(getActivity(), e.getLocalizedMessage(), Toast.LENGTH_LONG).show();
                        }
                    }

                    EditDialogListener listener = (EditDialogListener) getActivity();
                    listener.onFinishEditSettingsDialog(-1, file.getAbsolutePath());
                    dismiss();
                }
            }
        }
    }

    public interface EditDialogListener {
        void onFinishEditSettingsDialog(int primaryColor, String backgroundPath);
    }
}