package ca.coffeeshopstudio.gaminginterfaceclient.views;

import android.content.SharedPreferences;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.GradientDrawable;
import android.graphics.drawable.StateListDrawable;
import android.support.v4.widget.TextViewCompat;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.AppCompatTextView;
import android.util.TypedValue;
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
    protected int maxControlSize = 800;

    protected int activeControl = -1;

    private static StateListDrawable makeSelector(Control control) {
        GradientDrawable gd = new GradientDrawable(
                GradientDrawable.Orientation.TOP_BOTTOM,
                new int[]{control.getSecondaryColor(), control.getPrimaryColor()});
        gd.setCornerRadius(3f);

        GradientDrawable gdPressed = new GradientDrawable(
                GradientDrawable.Orientation.BOTTOM_TOP,
                new int[]{0x880f0f10, 0x885d5d5e});
        gd.setCornerRadius(3f);

        StateListDrawable res = new StateListDrawable();
        //res.setExitFadeDuration(400);
        //res.setAlpha(45);
        res.addState(new int[]{android.R.attr.state_pressed}, gdPressed);
        res.addState(new int[]{}, gd);
        return res;
    }

    protected abstract void addDragDrop(View view);

    protected void loadControls() {
        SharedPreferences prefs = getApplicationContext().getSharedPreferences("gicsScreen", MODE_PRIVATE);

        ColorDrawable color = (ColorDrawable) findViewById(R.id.topLayout).getBackground();
        int backgroundColor = prefs.getInt("background", 0xFF0099CC);
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
            if (control.getViewType() == 0)
                buildButton(control);
            else
                buildText(control);
        }
    }

    private void buildText(Control control) {
        AppCompatTextView view = new AppCompatTextView(AbstractGameActivity.this);
        TextViewCompat.setAutoSizeTextTypeUniformWithConfiguration(view, 24, maxControlSize, 2, TypedValue.COMPLEX_UNIT_SP);

        view.setX(control.getLeft());
        view.setY(control.getTop());
        view.setWidth(control.getWidth());
        view.setHeight(control.getHeight());
        view.setTextColor(control.getFontColor());

        view.setTextSize(TypedValue.COMPLEX_UNIT_PX, control.getFontSize());
        view.setTag(control.getCommand());
        view.setText(control.getText());

        setClick(view);

        addDragDrop(view);
        FrameLayout layout = findViewById(R.id.topLayout);
        FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.WRAP_CONTENT, FrameLayout.LayoutParams.WRAP_CONTENT);
        layout.addView(view, lp);
        controls.add(view);
        primaryColors.add(control.getPrimaryColor());
        secondaryColors.add(control.getSecondaryColor());
        view.setId(controls.size() - 1);
    }

    protected void buildButton(Control control) {
        Button button = new Button(AbstractGameActivity.this);

        button.setX(control.getLeft());
        button.setY(control.getTop());
        button.setWidth(control.getWidth());
        button.setHeight(control.getHeight());
        button.setTextColor(control.getFontColor());

        button.setBackground(makeSelector(control));

        button.setTextSize(TypedValue.COMPLEX_UNIT_PX, control.getFontSize());
        button.setTag(control.getCommand());
        button.setText(control.getText());

        setClick(button);

        addDragDrop(button);
        FrameLayout layout = findViewById(R.id.topLayout);
        FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.WRAP_CONTENT, FrameLayout.LayoutParams.WRAP_CONTENT);
        layout.addView(button, lp);
        controls.add(button);
        primaryColors.add(control.getPrimaryColor());
        secondaryColors.add(control.getSecondaryColor());
        button.setId(controls.size() - 1);
    }

    protected GradientDrawable setButtonBackground(int primaryColor, int secondaryColor) {
        GradientDrawable gd = new GradientDrawable(
                GradientDrawable.Orientation.TOP_BOTTOM,
                new int[]{secondaryColor, primaryColor});
        gd.setCornerRadius(3f);

        return gd;
    }

    protected void setClick(View view) {
        view.setOnClickListener(this);
    }

    @Override
    public void onClick(View view) {

    }
}
