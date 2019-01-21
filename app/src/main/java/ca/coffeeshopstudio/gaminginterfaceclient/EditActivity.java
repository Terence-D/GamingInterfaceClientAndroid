package ca.coffeeshopstudio.gaminginterfaceclient;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Build;
import android.os.Bundle;
import android.support.v4.app.FragmentManager;
import android.view.Display;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.SeekBar;

import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.util.Map;

import ca.coffeeshopstudio.gaminginterfaceclient.models.Command;
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
public class EditActivity extends AbstractGameActivity implements EditFragment.EditDialogListener, SeekBar.OnSeekBarChangeListener {
    private GestureDetector gd;
    private int currentApiVersion;
    private SeekBar horizontal;
    private SeekBar vertical;
    private SeekBar width;
    private SeekBar height;

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

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_edit);
        setupFullScreen();
        setupDoubleTap(EditActivity.this);
        setupControls();
        loadControls();
        toggleEditControls(View.GONE);
    }

    private void toggleEditControls(int visibility) {
        findViewById(R.id.seekHorizontal).setVisibility(visibility);
        findViewById(R.id.seekVertical).setVisibility(visibility);
        findViewById(R.id.seekHeight).setVisibility(visibility);
        findViewById(R.id.seekWidth).setVisibility(visibility);
    }

    private void setupControls() {
        horizontal = findViewById(R.id.seekHorizontal);
        vertical = findViewById(R.id.seekVertical);
        width = findViewById(R.id.seekWidth);
        height = findViewById(R.id.seekHeight);

        findViewById(R.id.topLayout).setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                return gd.onTouchEvent(event);
            }
        });
        Display display = getWindowManager().getDefaultDisplay();

        horizontal.setMax(display.getWidth() - 32);
        vertical.setMax(display.getHeight() - 32);
        width.setMax(400);
        height.setMax(400);
        horizontal.setOnSeekBarChangeListener(this);
        vertical.setOnSeekBarChangeListener(this);
        width.setOnSeekBarChangeListener(this);
        height.setOnSeekBarChangeListener(this);

        findViewById(R.id.btnSave).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                SharedPreferences prefs = getApplicationContext().getSharedPreferences("gicsScreen", MODE_PRIVATE);
                SharedPreferences.Editor prefsEditor = prefs.edit();

                ObjectMapper mapper = new ObjectMapper();

                //first we need to remove all existing controls
                Map<String,?> keys = prefs.getAll();
                for (Map.Entry<String, ?> entry : keys.entrySet()) {
                    if (entry.getKey().contains("control_")) {
                        prefsEditor.remove(entry.getKey());
                    }
                }

                try {
                    int i = 0;
                    for (View aview : controls ) {
                        Control control = new Control();
                        control.setCommand((Command) aview.getTag());
                        control.setWidth(aview.getWidth());
                        control.setLeft(aview.getX());
                        control.setText(((Button)aview).getText().toString());
                        control.setTop(aview.getY());
                        control.setHeight(aview.getBottom());
                        String json = mapper.writeValueAsString(control);
                        prefsEditor.putString("control_" + i, json);
                        i++;
                    }
                    prefsEditor.apply();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        });
    }

    private void setupFullScreen() {
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

    private void setupDoubleTap(final Context context) {
        gd = new GestureDetector(context, new GestureDetector.SimpleOnGestureListener(){
            //here is the method for double tap
            @Override
            public boolean onDoubleTap(MotionEvent e) {
                addButton(context);
                return true;
            }

            @Override
            public void onLongPress(MotionEvent e) {
                super.onLongPress(e);
            }

            @Override
            public boolean onDoubleTapEvent(MotionEvent e) {
                return true;
            }

            @Override
            public boolean onDown(MotionEvent e) {
//                if (activeControl >= 0) {
//                    findViewById(controls.get(activeControl).getId()).setBackgroundResource(R.drawable.button_standard);
//                }
//
//                toggleEditControls(View.GONE);
                return true;
            }
        });
    }

    private void addButton(Context context) {
        FrameLayout layout = findViewById(R.id.topLayout);
        if (activeControl >= 0) {
            findViewById(controls.get(activeControl).getId()).setBackgroundResource(R.drawable.button_standard);
        }

        Button myButton = new Button(context);
        myButton.setBackgroundResource(R.drawable.selected_button);
        myButton.setText("New");
        myButton.setId(controls.size());
        myButton.setOnClickListener(this);
        controls.add(myButton);
        activeControl = controls.size() - 1;
        horizontal.setProgress(0);
        vertical.setProgress(0);
        width.setProgress(100);
        height.setProgress(100);
        toggleEditControls(View.VISIBLE);
        FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.WRAP_CONTENT, FrameLayout.LayoutParams.WRAP_CONTENT);
        layout.addView(myButton, lp);
    }

    private void displayEditDialog() {
        FragmentManager fm = getSupportFragmentManager();
        Command commandToSend = null;
        String buttonText = null;
        if (activeControl >= 0) {
            buttonText = (String) ((Button) controls.get(activeControl)).getText();
            buttonText = (String) ((Button) controls.get(activeControl)).getText();
            commandToSend = ((Command) controls.get(activeControl).getTag());
        }
        EditFragment editNameDialogFragment = EditFragment.newInstance(getString(R.string.title_fragment_edit), buttonText, commandToSend);
        editNameDialogFragment.show(fm, "fragment_edit_name");
    }

    @Override
    public void onClick(View view) {
        if (activeControl == view.getId()) {
            displayEditDialog();
        } else {
            if (activeControl >= 0) {
                controls.get(activeControl).setBackgroundResource(R.drawable.button_standard);
            }
            activeControl = view.getId();
            view.setBackgroundResource(R.drawable.selected_button);
            horizontal.setProgress((int) view.getX());
            vertical.setProgress((int) view.getY());
            width.setProgress(view.getWidth());
            height.setProgress(view.getHeight());
            toggleEditControls(View.VISIBLE);
        }
    }

    @Override
    public void onFinishEditDialog(Command command, String text) {
        if (command == null && text.equals("DELETE")) {
            if (activeControl >= 0) {
                FrameLayout layout = findViewById(R.id.topLayout);
                layout.removeView(controls.get(activeControl));
                controls.remove(activeControl);
                activeControl = -1;
                toggleEditControls(View.GONE);
            }
        } else {
            ((Button) controls.get(activeControl)).setText(text);
            controls.get(activeControl).setTag(command);
        }
    }

    @Override
    public void onProgressChanged(SeekBar seekBar, int i, boolean b) {
        if (activeControl >= 0) {
            switch (seekBar.getId()) {
                case R.id.seekHorizontal:
                    controls.get(activeControl).setX(i);
                    break;
                case R.id.seekVertical:
                    controls.get(activeControl).setY(i);
                    break;
                case R.id.seekHeight:
                    controls.get(activeControl).setLayoutParams(new FrameLayout.LayoutParams(controls.get(activeControl).getWidth(), i));
                    break;
                case R.id.seekWidth:
                    controls.get(activeControl).setLayoutParams(new FrameLayout.LayoutParams(i, controls.get(activeControl).getHeight()));
                    break;
            }
        }
    }

    @Override
    public void onStartTrackingTouch(SeekBar seekBar) {

    }

    @Override
    public void onStopTrackingTouch(SeekBar seekBar) {

    }
}
