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
import ca.coffeeshopstudio.gaminginterfaceclient.models.ImageAdapter;

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
public class ImageGridDialog extends AlertDialog {
    public ImageGridDialog(final Fragment fragment) {
        super(Objects.requireNonNull(fragment.getActivity()));
        File file;
        int customCount = 0;
        for (int i = 0; i < Integer.MAX_VALUE; i++) {
            file = new File(getContext().getFilesDir(), "button_" + i + ".png");
            if (!file.exists()) {
                customCount = i;
                break;
            }
        }


        setTitle(R.string.image_grid_title);

        GridView gridView = new GridView(fragment.getActivity());
        gridView.setAdapter(new ImageAdapter(getContext(), customCount));

        gridView.setNumColumns(2);               // Number of columns
        gridView.setChoiceMode(GridView.CHOICE_MODE_SINGLE);       // Choice mode
        gridView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                if (position == 0) {
                    Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
                    intent.addCategory(Intent.CATEGORY_OPENABLE);
                    intent.setType("image/*");
                    fragment.startActivityForResult(intent, EditActivity.OPEN_REQUEST_CODE_IMPORT_BUTTON);
                    dismiss();
                } else {
                    dismiss();
                }
            }
        });
        setView(gridView);
    }

}
