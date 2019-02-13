package ca.coffeeshopstudio.gaminginterfaceclient.views;

import android.content.Intent;
import android.support.v4.app.Fragment;
import android.support.v7.app.AlertDialog;
import android.view.View;
import android.widget.AdapterView;
import android.widget.GridView;

import java.io.File;
import java.util.Objects;

import ca.coffeeshopstudio.gaminginterfaceclient.R;
import ca.coffeeshopstudio.gaminginterfaceclient.models.ToggleAdapter;

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
public class ToggleGridDialog extends AlertDialog {
    private int customCount = 0;

    public ToggleGridDialog(final Fragment fragment) {
        super(Objects.requireNonNull(fragment.getActivity()));
        File file;
        for (int i = 0; i < Integer.MAX_VALUE; i++) {
            file = new File(getContext().getFilesDir(), "switch_" + i + ".png");
            if (!file.exists()) {
                customCount = i;
                break;
            }
        }

        setTitle(R.string.image_grid_title);

        GridView gridView = new GridView(fragment.getActivity());
        gridView.setAdapter(new ToggleAdapter(getContext(), customCount));

        gridView.setNumColumns(2);               // Number of columns
        gridView.setChoiceMode(GridView.CHOICE_MODE_SINGLE);       // Choice mode
        gridView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                if (position == 0) { //import
                    Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
                    intent.addCategory(Intent.CATEGORY_OPENABLE);
                    intent.setType("image/*");
                    fragment.startActivityForResult(intent, EditActivity.OPEN_REQUEST_CODE_IMPORT_SWITCH);
                    dismiss();
                } else if (position <= customCount) {
                    String path = fragment.getActivity().getFilesDir() + "/switch_" + (position - 1) + ".png";
                    ((ToggleGridDialogListener) fragment).onImageSelected(path);
                    dismiss();
                } else if (position - customCount <= ToggleAdapter.builtIn.length) {
                    ((ToggleGridDialogListener) fragment).onImageSelected(ToggleAdapter.builtIn[position - customCount - 1]);
                    dismiss();
                }
            }
        });
        setView(gridView);
    }

    public interface ToggleGridDialogListener {
        void onImageSelected(String custom);

        void onImageSelected(int builtIn);
    }
}
