package ca.coffeeshopstudio.gaminginterfaceclient.views;

import android.content.Context;
import android.support.v7.app.AlertDialog;
import android.view.View;
import android.widget.AdapterView;
import android.widget.GridView;
import android.widget.Toast;

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
    public ImageGridDialog(final Context context) {
        super (context);

        setTitle(R.string.image_grid_title);

        GridView gridView = new GridView(context);
        gridView.setAdapter(new ImageAdapter(getContext()));

        gridView.setNumColumns(2);               // Number of columns
        gridView.setChoiceMode(GridView.CHOICE_MODE_SINGLE);       // Choice mode
        gridView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                // do something here
                Toast.makeText(context, "Position: " + position, Toast.LENGTH_SHORT).show();
                dismiss();
            }
        });
        setView(gridView);
    }
}
