package ca.coffeeshopstudio.gaminginterfaceclient.views;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.DialogFragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.Button;

import ca.coffeeshopstudio.gaminginterfaceclient.R;
import top.defaults.colorpicker.ColorPickerPopup;

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
public class EditBackgroundFragment extends DialogFragment implements View.OnClickListener {
    private int primary;
    private Button btnPrimary;
    private Uri currentUri;

    private static final int OPEN_REQUEST_CODE = 41;

    public static EditBackgroundFragment newInstance(String title, int primary) {
        EditBackgroundFragment frag = new EditBackgroundFragment();
        Bundle args = new Bundle();
        args.putString("title", title);
        args.putInt("primary", primary);
        frag.setArguments(args);
        return frag;
    }

    // Empty constructor is required for DialogFragment
    // Make sure not to add arguments to the constructor
    // Use `newInstance` instead as shown below
    public EditBackgroundFragment() {
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        // Fetch arguments from bundle and set title
        String title;
        if (getArguments() != null) {
            title = getArguments().getString("title", "Enter Name");
        } else
            title = getString(R.string.default_control_text);
        primary = getArguments().getInt("primary", Color.BLACK);
        getDialog().setTitle(title);
        // Show soft keyboard automatically and request focus to field
        getDialog().getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_VISIBLE);
        setupControls(view);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_edit_background, container);
    }

    private void setupControls(View view) {
        btnPrimary = view.findViewById(R.id.btnColor1);
        btnPrimary.setOnClickListener(this);
        btnPrimary.setTextColor(primary);

        view.findViewById(R.id.btnBackgroundImage).setOnClickListener(this);
        view.findViewById(R.id.btnSave).setOnClickListener(this);
    }

    @Override
    public void onClick(View view) {
        EditDialogListener listener = (EditDialogListener) getActivity();
        switch (view.getId()) {
            case R.id.btnSave:
                listener.onFinishEditBackgroundDialog(btnPrimary.getTextColors().getDefaultColor(), null);
                dismiss();
                break;
            case R.id.btnColor1:
                displayColorPicker(view);
                break;
            case R.id.btnBackgroundImage:
                Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
                intent.addCategory(Intent.CATEGORY_OPENABLE);
                intent.setType("image/*");
                startActivityForResult(intent, OPEN_REQUEST_CODE);
                break;
            default:
                break;
        }
    }

    private void displayColorPicker(final View view) {
        int color = ((Button) view).getTextColors().getDefaultColor();
        new ColorPickerPopup.Builder(getActivity())
                .initialColor(color) // Set initial color
                .enableBrightness(true) // Enable brightness slider or not
                .okTitle(getString(R.string.color_picker_title))
                .cancelTitle(getString(android.R.string.cancel))
                .showIndicator(true)
                .showValue(true)
                .build()
                .show(view, new ColorPickerPopup.ColorPickerObserver() {
                    @Override
                    public void onColorPicked(int color) {
                        ((Button) view).setTextColor(color);
                    }
                });
    }


    public interface EditDialogListener {
        void onFinishEditBackgroundDialog(int primaryColor, Uri background);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, @Nullable Intent resultData) {
        super.onActivityResult(requestCode, resultCode, resultData);
        if (resultCode == Activity.RESULT_OK)
        {
            if (requestCode == OPEN_REQUEST_CODE) {
                if (resultData != null) {
                    currentUri = resultData.getData();
                    EditDialogListener listener = (EditDialogListener) getActivity();
                    listener.onFinishEditBackgroundDialog(-1, currentUri);
                    dismiss();

                    //String content = readFileContent(currentUri);
                    //textView.setText(content);
                }
            }
        }
    }
}