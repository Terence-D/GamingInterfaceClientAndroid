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
public class EditActivity extends AbstractGameActivity implements EditFragment.EditDialogListener {
    private GestureDetector gd;
    private int currentApiVersion;
    private SeekBar horizontal;
    private SeekBar vertical;

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

        if (activeControl > -1) {
            findViewById(R.id.btnEdit).setVisibility(View.VISIBLE);
            findViewById(R.id.btnDelete).setVisibility(View.VISIBLE);
        }
    }

    private void setupControls() {
        horizontal = findViewById(R.id.seekHorizontal);
        vertical = findViewById(R.id.seekVertical);

        findViewById(R.id.topLayout).setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                return gd.onTouchEvent(event);
            }
        });
        Display display = getWindowManager().getDefaultDisplay();

        horizontal.setMax(display.getWidth() - 32);
        vertical.setMax(display.getHeight() - 32);
        horizontal.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int i, boolean b) {
                if (activeControl >= 0) {
                    controls.get(activeControl).setX(i);
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });
        vertical.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int i, boolean b) {
                if (activeControl >= 0)
                    controls.get(activeControl).setY(i);
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });
        findViewById(R.id.btnEdit).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                FragmentManager fm = getSupportFragmentManager();

                EditFragment editNameDialogFragment = EditFragment.newInstance(getString(R.string.title_fragment_edit));
                editNameDialogFragment.show(fm, "fragment_edit_name");
            }
        });
        findViewById(R.id.btnDelete).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (activeControl >= 0) {
                    FrameLayout layout = findViewById(R.id.topLayout);
                    layout.removeView(controls.get(activeControl));
                    controls.remove(activeControl);
                    activeControl = -1;
                    findViewById(R.id.btnEdit).setVisibility(View.GONE);
                    findViewById(R.id.btnDelete).setVisibility(View.GONE);
                }
            }
        });
        findViewById(R.id.btnSave).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                SharedPreferences prefs = getApplicationContext().getSharedPreferences("gicsScreen", MODE_PRIVATE);
                SharedPreferences.Editor prefsEditor = prefs.edit();

                ObjectMapper mapper = new ObjectMapper();
                try {
                    for (View aview : controls ) {
                        Control control = new Control();
                        control.setCommand((String) aview.getTag());
                        control.setWidth(aview.getWidth());
                        control.setLeft(aview.getX());
                        control.setText(((Button)aview).getText().toString());
                        control.setTop(aview.getY());
                        control.setHeight(aview.getBottom());
                        String json = mapper.writeValueAsString(control);
                        prefsEditor.putString("control_" + aview.getId(), json);
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
                return true;
            }
        });
    }

    private void addButton(Context context) {
        Button myButton = new Button(context);
        myButton.setText("New");
        myButton.setId(controls.size());
        FrameLayout layout = findViewById(R.id.topLayout);
        FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.WRAP_CONTENT, FrameLayout.LayoutParams.WRAP_CONTENT);
        layout.addView(myButton, lp);
        myButton.setOnClickListener(this);
        controls.add(myButton);
        activeControl = controls.size() - 1;
        horizontal.setProgress(0);
        vertical.setProgress(0);
        findViewById(R.id.btnEdit).setVisibility(View.VISIBLE);
        findViewById(R.id.btnDelete).setVisibility(View.VISIBLE);
    }

    @Override
    public void onClick(View view) {
        activeControl = view.getId();
        horizontal.setProgress((int) view.getX());
        vertical.setProgress((int) view.getY());
    }

    @Override
    public void onFinishEditDialog(String command, String text) {
        ((Button) controls.get(activeControl)).setText(text);
        controls.get(activeControl).setTag(command);
    }
}
