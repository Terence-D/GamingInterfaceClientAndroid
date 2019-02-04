package ca.coffeeshopstudio.gaminginterfaceclient.views;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.DialogFragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import ca.coffeeshopstudio.gaminginterfaceclient.R;

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

    // Empty constructor is required for DialogFragment
    // Make sure not to add arguments to the constructor
    // Use `newInstance` instead as shown below
    public EditImageFragment() {
    }

    public static EditImageFragment newInstance() {
        EditImageFragment frag = new EditImageFragment();
        return frag;
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        // Fetch arguments from bundle and set title
        getDialog().setTitle(R.string.edit_fragment_image_title);
        setupControls(view);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_edit_image, container);
    }

    private void setupControls(View view) {
        view.findViewById(R.id.btnImage).setOnClickListener(this);
        view.findViewById(R.id.btnDelete).setOnClickListener(this);
    }

    @Override
    public void onClick(View view) {
        EditImageDialogListener listener = (EditImageDialogListener) getActivity();
        switch (view.getId()) {
            case R.id.btnImage:
                Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
                intent.addCategory(Intent.CATEGORY_OPENABLE);
                intent.setType("image/*");
                startActivityForResult(intent, EditActivity.OPEN_REQUEST_CODE_IMAGE);
                break;
            case R.id.btnDelete:
                listener.onFinishEditImageDialog(null);
                dismiss();
                break;
            default:
                break;
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, @Nullable Intent resultData) {
        super.onActivityResult(requestCode, resultCode, resultData);
        if (resultCode == Activity.RESULT_OK) {
            if (requestCode == EditActivity.OPEN_REQUEST_CODE_IMAGE) {
                if (resultData != null) {
                    Uri currentUri = resultData.getData();
                    EditImageFragment.EditImageDialogListener listener = (EditImageFragment.EditImageDialogListener) getActivity();
                    listener.onFinishEditImageDialog(currentUri);

                    dismiss();
                }
            }
        }
    }

    public interface EditImageDialogListener {
        void onFinishEditImageDialog(Uri imageUri);
    }
}