package ca.coffeeshopstudio.gaminginterfaceclient.views;

import android.content.SharedPreferences;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.GradientDrawable;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.widget.Button;
import android.widget.FrameLayout;

import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import ca.coffeeshopstudio.gaminginterfaceclient.R;
import ca.coffeeshopstudio.gaminginterfaceclient.models.Control;

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
public abstract class AbstractGameActivity extends AppCompatActivity implements View.OnClickListener {
    protected List<View> controls = new ArrayList<>();
    protected List<Integer> primaryColors = new ArrayList<>();
    protected List<Integer> secondaryColors = new ArrayList<>();

    protected int activeControl = -1;

    protected void loadControls() {
        SharedPreferences prefs = getApplicationContext().getSharedPreferences("gicsScreen", MODE_PRIVATE);

        ColorDrawable color = (ColorDrawable) findViewById(R.id.topLayout).getBackground();
        int backgroundColor = prefs.getInt("background", Color.BLUE);
        color.setColor(backgroundColor);

        final ObjectMapper mapper = new ObjectMapper();
        List<Control> customControls = new ArrayList<>();

        Map<String,?> keys = prefs.getAll();
        for (Map.Entry<String, ?> entry : keys.entrySet()) {
            if (entry.getKey().contains("control_")) {
                try {
                    customControls.add(mapper.readValue(prefs.getString(entry.getKey(), ""), Control.class));
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }

        for (Control control : customControls) {
            Button button = new Button(AbstractGameActivity.this);

            button.setBackgroundResource(R.drawable.button_selector);
            button.setX(control.getLeft());
            button.setY(control.getTop());
            button.setWidth(control.getWidth());
            button.setHeight(control.getHeight());
            button.setTextColor(control.getFontColor());

            GradientDrawable gd = new GradientDrawable(
                    GradientDrawable.Orientation.TOP_BOTTOM,
                    new int[]{control.getSecondaryColor(), control.getPrimaryColor()});
            gd.setCornerRadius(3f);

            button.setBackground(gd);
            button.setTag(control.getCommand());
            button.setText(control.getText());
            button.setOnClickListener(this);
                addDragDrop(button);
            FrameLayout layout = findViewById(R.id.topLayout);
            FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.WRAP_CONTENT, FrameLayout.LayoutParams.WRAP_CONTENT);
            layout.addView(button, lp);
            controls.add(button);
            primaryColors.add(control.getPrimaryColor());
            secondaryColors.add(control.getSecondaryColor());
            button.setId(controls.size()-1);
        }
        //activeControl = controls.size()-1;

    }

    protected abstract void addDragDrop(View view);

    @Override
    public void onClick(View view) {

    }
}
