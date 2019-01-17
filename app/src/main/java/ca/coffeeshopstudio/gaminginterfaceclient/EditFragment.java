package ca.coffeeshopstudio.gaminginterfaceclient;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.DialogFragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.TextView;

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
public class EditFragment extends DialogFragment {

    public interface EditDialogListener {
        void onFinishEditDialog(String command, String text);
    }

    // Empty constructor is required for DialogFragment
    // Make sure not to add arguments to the constructor
    // Use `newInstance` instead as shown below
    public EditFragment() {
    }

    public static EditFragment newInstance(String title) {
        EditFragment frag = new EditFragment();
        Bundle args = new Bundle();
        args.putString("title", title);
        frag.setArguments(args);
        return frag;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_edit_control, container);
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        // Fetch arguments from bundle and set title
        String title = getArguments().getString("title", "Enter Name");
        getDialog().setTitle(title);
        // Show soft keyboard automatically and request focus to field
        getDialog().getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_VISIBLE);

        final TextView command = view.findViewById(R.id.txtKey);
        final TextView text = view.findViewById(R.id.txtText);
        view.findViewById(R.id.btnSave).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                EditDialogListener listener = (EditDialogListener) getActivity();
                listener.onFinishEditDialog(command.getText().toString(), text.getText().toString());
                dismiss();
            }
        });
    }
}