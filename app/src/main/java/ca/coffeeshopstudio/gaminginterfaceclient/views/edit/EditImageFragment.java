package ca.coffeeshopstudio.gaminginterfaceclient.views.edit;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
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
import android.widget.EditText;
import android.widget.Toast;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Objects;

import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;
import ca.coffeeshopstudio.gaminginterfaceclient.App;
import ca.coffeeshopstudio.gaminginterfaceclient.R;
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
public class EditImageFragment extends DialogFragment implements View.OnClickListener {
    private int screenId;
    private GICControl controlToLoad;
    private EditText txtLeft;
    private EditText txtTop;
    private EditText txtHeight;
    private EditText txtWidth;

    private float screenWidth;
    private float screenHeight;

    // Empty constructor is required for DialogFragment
    // Make sure not to add arguments to the constructor
    // Use `newInstance` instead as shown below
    public EditImageFragment() {
    }

    public static EditImageFragment newInstance(GICControl control, int screenId) {
        EditImageFragment frag = new EditImageFragment();
        Bundle args = new Bundle();
        args.putInt("screen", screenId);
        frag.setArguments(args);
        frag.loadControl(control);
        return frag;
    }

    public void loadControl(GICControl control) {
        controlToLoad = control;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (((App) getContext().getApplicationContext()).isNightModeEnabled())
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                setStyle(DialogFragment.STYLE_NORMAL, android.R.style.Theme_Material_Dialog);
            } else {
                setStyle(DialogFragment.STYLE_NORMAL, android.R.style.Theme_Holo_Dialog);
            }
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        // Fetch arguments from bundle and set title

        screenId = getArguments().getInt("screen");
        getDialog().setTitle(R.string.edit_fragment_image_title);
        setupControls(view);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        Objects.requireNonNull(getDialog().getWindow()).setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN);
        return inflater.inflate(R.layout.fragment_edit_image, container);
    }

    private void setupControls(View view) {

        getScreenDimensions();

        buildSizeControls(view);

        view.findViewById(R.id.btnImage).setOnClickListener(this);
        view.findViewById(R.id.btnDelete).setOnClickListener(this);
        view.findViewById(R.id.btnSave).setOnClickListener(this);
    }

    private void buildSizeControls(View view) {

        txtHeight = view.findViewById(R.id.txtHeight);
        txtLeft = view.findViewById(R.id.txtLeft);
        txtTop = view.findViewById(R.id.txtTop);
        txtWidth = view.findViewById(R.id.txtWidth);

        txtHeight.setText(Integer.toString(controlToLoad.getHeight()));
        txtLeft.setText(Float.toString(controlToLoad.getLeft()));
        txtTop.setText(Float.toString(controlToLoad.getTop()));
        txtWidth.setText(Integer.toString(controlToLoad.getWidth()));

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
        EditImageDialogListener listener = (EditImageDialogListener) getActivity();
        switch (view.getId()) {
            case R.id.btnSave:
                saveControl();
                dismiss();
                listener.onFinishEditImageDialog("");
                break;
            case R.id.btnImage:
                Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
                intent.addCategory(Intent.CATEGORY_OPENABLE);
                intent.setType("image/*");
                startActivityForResult(intent, EditActivity.OPEN_REQUEST_CODE_IMAGE);
                break;
            case R.id.btnDelete:
                listener.onFinishEditImageDialog("DELETE");
                dismiss();
                break;
            default:
                break;
        }
    }

    private void saveControl() {
        controlToLoad.setHeight(Integer.parseInt(txtHeight.getText().toString()));
        controlToLoad.setWidth(Integer.parseInt(txtWidth.getText().toString()));
        controlToLoad.setTop(Float.parseFloat(txtTop.getText().toString()));
        controlToLoad.setLeft(Float.parseFloat(txtLeft.getText().toString()));
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, @Nullable Intent resultData) {
        super.onActivityResult(requestCode, resultCode, resultData);
        if (resultCode == Activity.RESULT_OK) {
            if (requestCode == EditActivity.OPEN_REQUEST_CODE_IMAGE) {
                if (resultData != null) {
                    Uri currentUri = resultData.getData();
                    File file = null;
                    if (currentUri != null) {
                        try {
                            Bitmap bitmap = MediaStore.Images.Media.getBitmap(getActivity().getContentResolver(), currentUri);
                            for (int i = 0; i < Integer.MAX_VALUE; i++) {
                                file = new File(getContext().getFilesDir(), screenId + "_control_" + i + ".png");
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

                    EditImageFragment.EditImageDialogListener listener = (EditImageFragment.EditImageDialogListener) getActivity();
                    if (file == null)
                        listener.onFinishEditImageDialog("");
                    else
                        listener.onFinishEditImageDialog(file.getAbsolutePath());
                    dismiss();
                }
            }
        }
    }

    public interface EditImageDialogListener {
        void onFinishEditImageDialog(String imagePath);
    }
}