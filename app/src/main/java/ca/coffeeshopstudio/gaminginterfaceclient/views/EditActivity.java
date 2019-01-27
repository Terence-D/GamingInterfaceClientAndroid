package ca.coffeeshopstudio.gaminginterfaceclient.views;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.content.ClipData;
import android.content.Context;
import android.content.DialogInterface;
import android.content.SharedPreferences;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.support.v4.app.FragmentManager;
import android.util.TypedValue;
import android.view.DragEvent;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.FrameLayout;
import android.widget.SeekBar;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;

import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.util.Map;

import ca.coffeeshopstudio.gaminginterfaceclient.R;
import ca.coffeeshopstudio.gaminginterfaceclient.models.Command;
import ca.coffeeshopstudio.gaminginterfaceclient.models.Control;
import top.defaults.colorpicker.ColorPickerPopup;

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
    private SeekBar width;
    private SeekBar height;
    private SeekBar fontSize;
    private boolean mode = false;
    private final int minControlSize = 48;
    private final int maxFontSize = 256;

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

    private View findControl(int id) {
        for (View view : views) {
            if (view.getId() == id)
                return view;
        }
        return null;
    }

    private void toggleEditControls(int visibility) {
        if (activeControl >= 0) {
            View view = findControl(activeControl);
            if (view instanceof Button) {
                findViewById(R.id.seekFont).setVisibility(visibility);
            } else {
                findViewById(R.id.seekFont).setVisibility(View.GONE);
            }
            findViewById(R.id.seekHeight).setVisibility(visibility);
            findViewById(R.id.seekWidth).setVisibility(visibility);
        }
    }

    private void setupControls() {
        width = findViewById(R.id.seekWidth);
        height = findViewById(R.id.seekHeight);
        fontSize = findViewById(R.id.seekFont);

        findViewById(R.id.topLayout).setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                v.performClick();
                return gd.onTouchEvent(event);
            }
        });
        findViewById(R.id.topLayout).setOnDragListener(new DragDropListener());

        ((Switch) findViewById(R.id.toggleMode)).setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton compoundButton, boolean b) {
                mode = b;
                if (mode) {
                    toggleEditControls(View.GONE);
                    Toast.makeText(EditActivity.this, R.string.edit_activity_drag_mode, Toast.LENGTH_SHORT).show();
                } else if (activeControl > -1) {
                    toggleEditControls(View.VISIBLE);
                    Toast.makeText(EditActivity.this, R.string.edit_activity_detail_edit_mode, Toast.LENGTH_SHORT).show();
                }
            }
        });

        width.setMax(maxControlSize);
        height.setMax(maxControlSize);
        fontSize.setMax(maxFontSize);
        width.setOnSeekBarChangeListener(this);
        height.setOnSeekBarChangeListener(this);
        fontSize.setOnSeekBarChangeListener(this);

        findViewById(R.id.btnSave).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                saveScreen();
            }
        });

        findViewById(R.id.btnSettings).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                displayColorPicker(findViewById(R.id.topLayout));
            }
        });
    }

    private void displayColorPicker(final View view) {
        ColorDrawable color = (ColorDrawable) view.getBackground();
        new ColorPickerPopup.Builder(this)
                .initialColor(color.getColor()) // Set initial color
                .enableBrightness(true) // Enable brightness slider or not
                //.enableAlpha(true) // Enable alpha slider or not
                .okTitle(getString(R.string.color_picker_title))
                .cancelTitle(getString(android.R.string.cancel))
                .showIndicator(true)
                .showValue(true)
                .build()
                .show(view, new ColorPickerPopup.ColorPickerObserver() {
                    @Override
                    public void onColorPicked(int color) {
                        view.setBackgroundColor(color);
                    }
                });
    }

    private void saveScreen() {
        SharedPreferences prefs = getApplicationContext().getSharedPreferences("gicsScreen", MODE_PRIVATE);
        SharedPreferences.Editor prefsEditor = prefs.edit();

        ObjectMapper mapper = new ObjectMapper();

        //first we need to remove all existing views
        Map<String,?> keys = prefs.getAll();
        for (Map.Entry<String, ?> entry : keys.entrySet()) {
            if (entry.getKey().contains("control_")) {
                prefsEditor.remove(entry.getKey());
            }
        }

        ColorDrawable color = (ColorDrawable) findViewById(R.id.topLayout).getBackground();
        prefsEditor.putInt("background", color.getColor());
        try {
            int i = 0;
            for (View view : views) {
                Control control = new Control();
                control.setCommand((Command) view.getTag());
                control.setWidth(view.getWidth());
                control.setLeft(view.getX());
                control.setFontSize((int) ((TextView) view).getTextSize());
                control.setText(((TextView) view).getText().toString());
                control.setTop(view.getY());
                control.setHeight(view.getBottom());
                control.setFontColor(((TextView) view).getTextColors().getDefaultColor());
                control.setPrimaryColor(primaryColors.get(i));
                control.setSecondaryColor(secondaryColors.get(i));
                if (view instanceof Button)
                    control.setViewType(0);
                else
                    control.setViewType(1);
                String json = mapper.writeValueAsString(control);
                prefsEditor.putString("control_" + i, json);
                i++;
            }
            prefsEditor.apply();
            Toast.makeText(EditActivity.this, R.string.edit_activity_saved, Toast.LENGTH_SHORT).show();
        } catch (IOException e) {
            e.printStackTrace();
            Toast.makeText(EditActivity.this, e.getLocalizedMessage(), Toast.LENGTH_LONG).show();
        }
    }

    private void setupDoubleTap(final Context context) {
        gd = new GestureDetector(context, new GestureDetector.SimpleOnGestureListener(){
            //here is the method for double tap
            @Override
            public boolean onDoubleTap(MotionEvent e) {
                showControlPopup();
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

    private void showControlPopup() {
        AlertDialog.Builder builderSingle = new AlertDialog.Builder(EditActivity.this);

        final ArrayAdapter<String> arrayAdapter = new ArrayAdapter<>(EditActivity.this, android.R.layout.simple_list_item_1);
        arrayAdapter.add("Button");
        arrayAdapter.add("Text");

        builderSingle.setNegativeButton(android.R.string.cancel, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();
            }
        });

        builderSingle.setAdapter(arrayAdapter, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                switch (which) {
                    case 0:
                        addButton();
                        break;
                    case 1:
                        addTextView();
                        break;
                }
            }
        });
        builderSingle.show();
    }

    @SuppressLint("ClickableViewAccessibility")
    private void addTextView() {
        //unselect any previous button
        unselectedPreviousView();

        Control control = new Control();
        control.setText(getString(R.string.default_control_text));

        width.setProgress(control.getWidth());
        height.setProgress(control.getHeight());

        buildText(control);

        View view = views.get(views.size()-1);

        view.setOnClickListener(this);
        view.setOnTouchListener(new TouchListener());
        activeControl = views.size() - 1;
        toggleEditControls(View.VISIBLE);
    }

    private void unselectedPreviousView() {
//        if (activeControl >= 0) {
//            View previous = findViewById(views.get(activeControl).getId());
//            if (previous instanceof Button) {
//                previous.setBackground(setButtonBackground(primaryColors.get(activeControl), secondaryColors.get(activeControl)));
//            }
//        }
    }

    @SuppressLint("ClickableViewAccessibility")
    private void addButton() {
        //unselect any previous button
        unselectedPreviousView();

        Control control = new Control();
        control.setText(getString(R.string.default_control_text));

        width.setProgress(control.getWidth());
        height.setProgress(control.getHeight());

        buildButton(control);

        View view = views.get(views.size()-1);
        ((Button) view).setTextSize(TypedValue.COMPLEX_UNIT_PX, 48);

        fontSize.setProgress((int) ((Button) view).getTextSize());

        view.setOnClickListener(this);
        view.setOnTouchListener(new TouchListener());
        activeControl = views.size() - 1;
        toggleEditControls(View.VISIBLE);
    }

    private void displayEditDialog() {
        FragmentManager fm = getSupportFragmentManager();
        TextView view = (TextView) findControl(activeControl);
        int fontColor = view.getTextColors().getDefaultColor();
        int primaryColor = primaryColors.get(activeControl);
        int secondaryColor = secondaryColors.get(activeControl);
        String buttonText = (String) view.getText();
        Command commandToSend = ((Command) findControl(activeControl).getTag());
        EditFragment editNameDialogFragment = EditFragment.newInstance(getString(R.string.title_fragment_edit), buttonText, commandToSend, primaryColor, secondaryColor, fontColor, view);
        editNameDialogFragment.show(fm, "fragment_edit_name");
    }

    @Override
    protected void addDragDrop(View view) {
        view.setOnTouchListener(new TouchListener());
    }

    @Override
    public void onClick(View view) {
        if (activeControl == view.getId()) {
            displayEditDialog();
        } else {
            if (activeControl >= 0) {
                if (findControl(activeControl) instanceof Button)
                    findControl(activeControl).setBackground(setButtonBackground(primaryColors.get(activeControl), secondaryColors.get(activeControl)));
            }
            activeControl = view.getId();

            if (view instanceof Button)
                view.setBackground(setButtonBackground(secondaryColors.get(activeControl), primaryColors.get(activeControl)));

            width.setProgress(view.getWidth());
            height.setProgress(view.getHeight());
            fontSize.setProgress((int) ((TextView) view).getTextSize());
            toggleEditControls(View.VISIBLE);
        }
    }

    @Override
    public void onFinishEditDialog(Command command, String text, int primaryColor, int secondaryColor, int fontColor) {
        if (command == null && text.equals("DELETE")) {
            if (activeControl >= 0) {
                FrameLayout layout = findViewById(R.id.topLayout);
                layout.removeView(findControl(activeControl));
                views.remove(findControl(activeControl));
                //primaryColors.remove(activeControl);
                //secondaryColors.remove(activeControl);
                activeControl = -1;
                toggleEditControls(View.GONE);
            }
        } else {
            primaryColors.set(activeControl, primaryColor);
            secondaryColors.set(activeControl, secondaryColor);

            View view = findControl(activeControl);

            if (view instanceof Button)
                view.setBackground(setButtonBackground(primaryColor, secondaryColor));

            ((TextView) view).setText(text);
            ((TextView) view).setTextColor(fontColor);
            view.setTag(command);
        }
    }

    @Override
    public void onProgressChanged(SeekBar seekBar, int value, boolean b) {
        if (activeControl >= 0) {
            TextView view = (TextView) findControl(activeControl);

            int newWidth = view.getWidth();
            int newHeight = view.getHeight();
            int newFont = (int) view.getTextSize();
            switch (seekBar.getId()) {
                case R.id.seekHeight:
                    newHeight = value;
                    break;
                case R.id.seekWidth:
                    newWidth = value;
                    break;
                case R.id.seekFont:
                    newFont = value;
                    break;
            }
            if (newWidth >= minControlSize && newHeight >= minControlSize)
                view.setLayoutParams(new FrameLayout.LayoutParams(newWidth, newHeight));
            view.setTextSize(TypedValue.COMPLEX_UNIT_PX, newFont);
        }
    }

    @Override
    public void onStartTrackingTouch(SeekBar seekBar) {

    }

    @Override
    public void onStopTrackingTouch(SeekBar seekBar) {

    }

    private final class TouchListener implements View.OnTouchListener {
        public boolean onTouch(View view, MotionEvent motionEvent) {
            if (motionEvent.getAction() == MotionEvent.ACTION_DOWN && mode) {
                ClipData data = ClipData.newPlainText("", "");
                View.DragShadowBuilder shadowBuilder = new View.DragShadowBuilder(
                        view);
                view.startDrag(data, shadowBuilder, view, 0);
                view.setVisibility(View.INVISIBLE);
                return true;
            } else if (motionEvent.getAction() == MotionEvent.ACTION_UP) {
                view.performClick();
                onClick(view);
                return true;
            } else {
                return false;
            }
        }
    }

    @SuppressWarnings("IntegerDivisionInFloatingPointContext")
    private final class DragDropListener implements View.OnDragListener {
        @Override
        public boolean onDrag(View v, DragEvent event) {
            switch (event.getAction()) {
                case DragEvent.ACTION_DRAG_STARTED:
                    break;
                case DragEvent.ACTION_DRAG_LOCATION:
                    break;
                case DragEvent.ACTION_DRAG_ENTERED:
                    break;
                case DragEvent.ACTION_DRAG_EXITED:
                    break;
                case DragEvent.ACTION_DROP:
                    View view = (View) event.getLocalState();
                    float x = event.getX();
                    float y = event.getY();
                    view.setX(x-(view.getWidth()/2));
                    view.setY(y-(view.getHeight()/2));
                    view.setVisibility(View.VISIBLE);
                    break;
                case DragEvent.ACTION_DRAG_ENDED:
                default:
                    break;
            }
            return true;
        }
    }
}
