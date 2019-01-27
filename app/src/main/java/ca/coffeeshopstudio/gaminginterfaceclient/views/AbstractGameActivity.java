package ca.coffeeshopstudio.gaminginterfaceclient.views;

import android.annotation.SuppressLint;
import android.content.SharedPreferences;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.GradientDrawable;
import android.graphics.drawable.StateListDrawable;
import android.os.Build;
import android.support.v4.widget.TextViewCompat;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.AppCompatTextView;
import android.util.TypedValue;
import android.view.View;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.TextView;

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
    protected List<View> views = new ArrayList<>();
    protected List<Integer> primaryColors = new ArrayList<>();
    protected List<Integer> secondaryColors = new ArrayList<>();
    protected int maxControlSize = 800;
    protected int currentApiVersion;

    protected int activeControl = -1;

    private int newId = 0;

    @SuppressLint("NewApi")
    @Override
    public void onWindowFocusChanged(boolean hasFocus) {
        super.onWindowFocusChanged(hasFocus);
        if (currentApiVersion >= Build.VERSION_CODES.KITKAT && hasFocus) {
            getWindow().getDecorView().setSystemUiVisibility(
                    View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                            | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                            | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                            | View.SYSTEM_UI_FLAG_FULLSCREEN
                            | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                            | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY);
        }
    }

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
        res.addState(new int[]{android.R.attr.state_pressed}, gdPressed);
        res.addState(new int[]{}, gd);
        return res;
    }

    protected void addDragDrop(View view) {
        //unused
    }

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

    protected void buildText(Control control) {
        AppCompatTextView view = new AppCompatTextView(AbstractGameActivity.this);
        TextViewCompat.setAutoSizeTextTypeUniformWithConfiguration(view, 24, maxControlSize, 2, TypedValue.COMPLEX_UNIT_SP);
        buildControl(control, view);
    }

    protected void buildButton(Control control) {
        Button view = new Button(AbstractGameActivity.this);
        buildControl(control, view);
        view.setBackground(makeSelector(control));
    }

    private void buildControl(Control control, TextView view) {
        FrameLayout layout = findViewById(R.id.topLayout);
        FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.WRAP_CONTENT, FrameLayout.LayoutParams.WRAP_CONTENT);
        layout.addView(view, lp);

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
        views.add(view);
        primaryColors.add(control.getPrimaryColor());
        secondaryColors.add(control.getSecondaryColor());
        view.setId(newId);
        newId++;
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

    protected void setupFullScreen() {
        currentApiVersion = Build.VERSION.SDK_INT;
        final int flags = View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                | View.SYSTEM_UI_FLAG_FULLSCREEN
                | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY;
        if (currentApiVersion >= Build.VERSION_CODES.KITKAT) {
            getWindow().getDecorView().setSystemUiVisibility(flags);
            final View decorView = getWindow().getDecorView();
            decorView.setOnSystemUiVisibilityChangeListener(new View.OnSystemUiVisibilityChangeListener() {
                @Override
                public void onSystemUiVisibilityChange(int visibility) {
                    if ((visibility & View.SYSTEM_UI_FLAG_FULLSCREEN) == 0) {
                        decorView.setSystemUiVisibility(flags);
                    }
                }
            });
        }
    }

}
