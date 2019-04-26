package ca.coffeeshopstudio.gaminginterfaceclient.views.edit;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.ClipData;
import android.content.Context;
import android.content.DialogInterface;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.util.TypedValue;
import android.view.DragEvent;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.SeekBar;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.ToggleButton;

import androidx.fragment.app.FragmentManager;
import ca.coffeeshopstudio.gaminginterfaceclient.R;
import ca.coffeeshopstudio.gaminginterfaceclient.models.ControlDefaults;
import ca.coffeeshopstudio.gaminginterfaceclient.models.ControlTypes;
import ca.coffeeshopstudio.gaminginterfaceclient.models.GICControl;
import ca.coffeeshopstudio.gaminginterfaceclient.models.screen.IScreen;
import ca.coffeeshopstudio.gaminginterfaceclient.models.screen.IScreenRepository;
import ca.coffeeshopstudio.gaminginterfaceclient.models.screen.Screen;
import ca.coffeeshopstudio.gaminginterfaceclient.views.AbstractGameActivity;

import static java.lang.Math.round;

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
public class EditActivity extends AbstractGameActivity implements EditTextStyleFragment.EditDialogListener,
        SeekBar.OnSeekBarChangeListener,
        EditImageFragment.EditImageDialogListener,
        EditToggleFragment.EditToggleListener,
        EditSettingsFragment.EditDialogListener {

    public static final String PREF_KEY_GRID_SIZE = "prefGridSize";
    private GestureDetector gd;
    private SeekBar seekWidth;
    private SeekBar seekHeight;
    private SeekBar seekFontSize;
    private boolean mode = false;
    private final int minControlSize = 48;
    private final int minFontSize = 4;
    private final int maxFontSize = 256;
    private ControlTypes controlTypes;
    private int gridSize;
    private ControlDefaults defaults;

    private View selectedView; //which view is active

    protected static final int OPEN_REQUEST_CODE_BACKGROUND = 41;
    protected static final int OPEN_REQUEST_CODE_IMAGE = 42;
    public static final int OPEN_REQUEST_CODE_IMPORT_BUTTON = 43;
    public static final int OPEN_REQUEST_CODE_IMPORT_SWITCH = 43;
    public static final int OPEN_REQUEST_CODE_FONT = 44;

    @Override
    protected void onStop() {
        defaults.saveDefaults(this, currentScreen.getScreenId());
        super.onStop();
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        controlTypes = new ControlTypes(getApplicationContext());

    }

    @Override
    protected void loadScreen() {
        setContentView(R.layout.activity_edit);

        setupFullScreen();
        setupDoubleTap(EditActivity.this);
        setupControls();

        defaults = new ControlDefaults(this, currentScreen.getScreenId());

        toggleEditControls(View.GONE);
        gridSize = PreferenceManager.getDefaultSharedPreferences(this)
                .getInt(PREF_KEY_GRID_SIZE, 64);

        if (currentScreen.getControls().size() > 0)
            findViewById(R.id.txtHelp).setVisibility(View.GONE);
        super.loadScreen();
    }

    private void toggleEditControls(int visibility) {
        seekFontSize.setVisibility(View.GONE);
        seekHeight.setVisibility(visibility);
        seekWidth.setVisibility(visibility);

        //now if displaying, update the seek progress bars
        if (visibility == View.VISIBLE) {
            seekWidth.setProgress(selectedView.getWidth());
            seekHeight.setProgress(selectedView.getHeight());
            if (selectedView instanceof Button || selectedView instanceof ToggleButton) {
                seekFontSize.setProgress((int) ((Button) selectedView).getTextSize());
                seekFontSize.setVisibility(visibility);
            }
        }
    }

    private void setupControls() {
        seekWidth = findViewById(R.id.seekWidth);
        seekHeight = findViewById(R.id.seekHeight);
        seekFontSize = findViewById(R.id.seekFontSize);

        findViewById(R.id.topLayout).setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                v.performClick();
                return gd.onTouchEvent(event);
            }
        });
        findViewById(R.id.topLayout).setOnDragListener(new DragDropListener());

        setupToggleSwitch();

        seekWidth.setMax(Screen.MAX_CONTROL_SIZE);
        seekHeight.setMax(Screen.MAX_CONTROL_SIZE);
        seekFontSize.setMax(maxFontSize);
        seekWidth.setOnSeekBarChangeListener(this);
        seekHeight.setOnSeekBarChangeListener(this);
        seekFontSize.setOnSeekBarChangeListener(this);

        setupButtons();
    }

    //TODO move this to presentation on refactor
    private ProgressDialog dialog;

    private void setupToggleSwitch() {
        ((Switch) findViewById(R.id.toggleMode)).setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton compoundButton, boolean b) {
                toggleEditControls(View.GONE);
                mode = b;
                if (mode) {
                    Toast.makeText(EditActivity.this, R.string.edit_activity_drag_mode, Toast.LENGTH_SHORT).show();
                } else {
                    Toast.makeText(EditActivity.this, R.string.edit_activity_detail_edit_mode, Toast.LENGTH_SHORT).show();
                }
            }
        });
    }

    private void setupDoubleTap(final Context context) {
        gd = new GestureDetector(context, new GestureDetector.SimpleOnGestureListener(){
            //here is the method for double tap
            @Override
            public boolean onDoubleTap(MotionEvent e) {
                showControlPopup(e);
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

    private void showControlPopup(final MotionEvent e) {
        AlertDialog.Builder builderSingle;
        builderSingle = new AlertDialog.Builder(EditActivity.this);

        final ArrayAdapter<String> arrayAdapter = new ArrayAdapter<>(EditActivity.this, android.R.layout.simple_list_item_1, controlTypes.getStringValues());

        builderSingle.setNegativeButton(android.R.string.cancel, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();
            }
        });

        final int x = gridSize * round(e.getX() / gridSize);
        final int y = gridSize * round(e.getY() / gridSize);

        builderSingle.setAdapter(arrayAdapter, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                if (controlTypes.getValue(which).equals(getString(R.string.control_type_button)))
                    addButton(e.getX(), e.getY());
                if (controlTypes.getValue(which).equals(getString(R.string.control_type_text)))
                    addTextView(e.getX(), e.getY());
                if (controlTypes.getValue(which).equals(getString(R.string.control_type_image)))
                    addImage(e.getX(), e.getY());
                if (controlTypes.getValue(which).equals(getString(R.string.control_type_switch)))
                    addSwitch(e.getX(), e.getY());
            }
        });
        builderSingle.show();
    }


    private void addImage(float startingX, float startingY) {
        GICControl control = initNewControl();
        control.setWidth(defaults.getImageDefaults().getWidth());
        control.setHeight(defaults.getImageDefaults().getHeight());
        control.setViewType(GICControl.TYPE_IMAGE);

        float x = getPosition(startingX, control.getWidth());
        float y = getPosition(startingY, control.getHeight());
        control.setLeft(x);
        control.setTop(y);
        View view = buildImage(control);
        updateDisplay(view);
    }

    private void addTextView(float startingX, float startingY) {
        //un select any previous button
        GICControl control = initNewControl();
        control.setWidth(defaults.getTextDefaults().getWidth());
        control.setHeight(defaults.getTextDefaults().getHeight());

        control.setFontColor(defaults.getTextDefaults().getFontColor());
        control.setText(getString(R.string.default_control_text));
        control.setFontName(defaults.getTextDefaults().getFontName());
        control.setViewType(GICControl.TYPE_TEXT);

        float x = getPosition(startingX, control.getWidth());
        float y = getPosition(startingY, control.getHeight());
        control.setLeft(x);
        control.setTop(y);
        View view = buildText(control);

        updateDisplay(view);
    }

    private void addButton(float startingX, float startingY) {
        //unselect any previous button
        GICControl control = initNewControl();

        control.setFontColor(defaults.getButtonDefaults().getFontColor());
        control.setText(getString(R.string.default_control_text));
        control.setViewType(GICControl.TYPE_BUTTON);
        control.setFontSize(defaults.getButtonDefaults().getFontSize());
        control.setPrimaryColor(defaults.getButtonDefaults().getPrimaryColor());
        control.setSecondaryColor(defaults.getButtonDefaults().getSecondaryColor());
        control.setPrimaryImageResource(defaults.getButtonDefaults().getPrimaryImageResource());
        control.setSecondaryImageResource(defaults.getButtonDefaults().getSecondaryImageResource());
        control.setPrimaryImage(defaults.getButtonDefaults().getPrimaryImage());
        control.setSecondaryImage(defaults.getButtonDefaults().getSecondaryImage());
        control.setWidth(defaults.getButtonDefaults().getWidth());
        control.setHeight(defaults.getButtonDefaults().getHeight());
        control.setFontName(defaults.getButtonDefaults().getFontName());

        float x = getPosition(startingX, control.getWidth());
        float y = getPosition(startingY, control.getHeight());
        control.setLeft(x);
        control.setTop(y);
        View view = buildButton(control);

        updateDisplay(view);

        ((Button) view).setTextSize(TypedValue.COMPLEX_UNIT_PX, defaults.getButtonDefaults().getFontSize());
    }

    private void addSwitch(float startingX, float startingY) {
        //unselect any previous button
        GICControl control = initNewControl();

        control.setFontColor(defaults.getSwitchDefaults().getFontColor());
        control.setText(getString(R.string.default_control_text));
        control.setViewType(GICControl.TYPE_SWITCH);
        control.setFontSize(defaults.getSwitchDefaults().getFontSize());
        control.setPrimaryColor(defaults.getSwitchDefaults().getPrimaryColor());
        control.setSecondaryColor(defaults.getSwitchDefaults().getSecondaryColor());
        control.setPrimaryImageResource(defaults.getSwitchDefaults().getPrimaryImageResource());
        control.setSecondaryImageResource(defaults.getSwitchDefaults().getSecondaryImageResource());
        control.setPrimaryImage(defaults.getSwitchDefaults().getPrimaryImage());
        control.setSecondaryImage(defaults.getSwitchDefaults().getSecondaryImage());
        control.setWidth(defaults.getSwitchDefaults().getWidth());
        control.setHeight(defaults.getSwitchDefaults().getHeight());
        control.setFontName(defaults.getSwitchDefaults().getFontName());

        control.setPrimaryImageResource(0);
        control.setSecondaryImageResource(1);
        control.setText("");

        float x = getPosition(startingX, control.getWidth());
        float y = getPosition(startingY, control.getHeight());
        control.setLeft(x);
        control.setTop(y);
        View view = buildSwitch(control);
        updateDisplay(view);
        ((ToggleButton) view).setTextSize(TypedValue.COMPLEX_UNIT_PX, defaults.getSwitchDefaults().getFontSize());
    }

    private GICControl initNewControl() {
        //un select any previous view visually
        unselectedPreviousView();
        return new GICControl();
    }

    private void unselectedPreviousView() {
//        if (activeControl >= 0) {
//            View previous = findViewById(views.get(activeControl).getId());
//            if (previous instanceof Button) {
//                previous.loadBackground(setButtonBackground(primaryColors.get(activeControl), secondaryColors.get(activeControl)));
//            }
//        }
    }

    //called after addControlType style methods
    @SuppressLint("ClickableViewAccessibility")
    private View updateDisplay(View view) {
        view.setOnClickListener(this);
        view.setOnTouchListener(new TouchListener());
        toggleEditControls(View.GONE);
        currentScreen.addControl((GICControl) view.getTag());
        findViewById(R.id.txtHelp).setVisibility(View.GONE);

        return view;
    }

    private void displayEditBackgroundDialog() {
        int color = Color.BLACK;
        Drawable background = findViewById(R.id.topLayout).getBackground();
        if (background instanceof ColorDrawable)
            color = ((ColorDrawable) background).getColor();

        int primaryColor = color;

        FragmentManager fm = getSupportFragmentManager();
        EditSettingsFragment editBackgroundFragment = EditSettingsFragment.newInstance(primaryColor, currentScreen.getScreenId());

        editBackgroundFragment.show(fm, "fragment_edit_background_name");
    }

    private void displayImageEditDialog() {
        FragmentManager fm = getSupportFragmentManager();
        ImageView view = (ImageView) selectedView;

        EditImageFragment editFragment = EditImageFragment.newInstance((GICControl) view.getTag(), currentScreen.getScreenId());
        editFragment.show(fm, "fragment_edit_image_name");
    }

    private void displayTextEditDialog() {
        FragmentManager fm = getSupportFragmentManager();
        TextView view = (TextView) selectedView;

        EditTextStyleFragment editTextDialog = EditTextStyleFragment.newInstance((GICControl) view.getTag(), view);
        editTextDialog.show(fm, "fragment_edit_name");
    }

    private void displayToggleEditDialog() {
        FragmentManager fm = getSupportFragmentManager();
        ToggleButton view = (ToggleButton) selectedView;

        EditToggleFragment editToggleDialog = EditToggleFragment.newInstance((GICControl) view.getTag(), view);
        editToggleDialog.show(fm, "fragment_edit_toggle");
    }

    @Override
    protected void addDragDrop(View view) {
        view.setOnTouchListener(new TouchListener());
    }

    //to fix a case of the onClick firing twice i moved the code in here
    private void clickHandler(View view) {
        //we already tapped once on this, lets open
        if (selectedView != null && selectedView.equals(view)) {
            toggleEditControls(View.VISIBLE);
            if (view instanceof ToggleButton)
                displayToggleEditDialog();
            else if (view instanceof TextView)
                displayTextEditDialog();
            else if (view instanceof ImageView)
                displayImageEditDialog();
        } else {
            unselectedPreviousView();
            //this is us selecting
            selectedView = view;
            toggleEditControls(View.VISIBLE);
        }
    }

    @Override
    public void onClick(View view) {
        clickHandler(view);
    }

    @Override
    public void onFinishEditSettingsDialog(int primaryColor, String image) {
        gridSize = PreferenceManager.getDefaultSharedPreferences(this)
                .getInt(PREF_KEY_GRID_SIZE, 64);
        if (primaryColor != -1) {
            currentScreen.setBackgroundColor(primaryColor);
            currentScreen.setBackgroundFile("");
            findViewById(R.id.topLayout).setBackgroundColor(primaryColor);
        }
        if (image != null) {
            currentScreen.setBackgroundColor(-1);
            currentScreen.setBackgroundFile(image);
            Drawable drawable = currentScreen.getImage(image);
            findViewById(R.id.topLayout).setBackground(drawable);
        }
    }

    private void deleteView() {
        FrameLayout layout = findViewById(R.id.topLayout);
        currentScreen.removeControl((GICControl) selectedView.getTag());
        layout.removeView(selectedView);
        toggleEditControls(View.GONE);
    }

    @Override
    public void onFinishEditImageDialog(String imagePath) {
        if (imagePath == "DELETE") {
            deleteView();
        } else {
            ImageView image = ((ImageView) selectedView);

            GICControl control = (GICControl) selectedView.getTag();
            if (imagePath != null && !imagePath.isEmpty()) {
                control.setPrimaryImage(imagePath);
                image.setImageDrawable(currentScreen.getImage(imagePath));
            }
            selectedView.setX(control.getLeft());
            selectedView.setY(control.getTop());
            resizeImageView(image, control.getWidth(), control.getHeight());
        }
    }

    @Override
    public void onFinishEditDialog(boolean toSave, GICControl control) {
        if (!toSave) {
            deleteView();
        } else {
            selectedView.setTag(control);

            if (selectedView instanceof Button || selectedView instanceof ToggleButton) {
                selectedView.setBackground(buildButtonDrawable(control));
            }

            ((TextView) selectedView).setText(control.getText());
            ((TextView) selectedView).setTextColor(control.getFontColor());

            setFontTypeface((TextView) selectedView, control);

            selectedView.setLayoutParams(new FrameLayout.LayoutParams(control.getWidth(), control.getHeight()));
            selectedView.setX(control.getLeft());
            selectedView.setY(control.getTop());
            defaults.saveControl(control);

            selectedView.setTag(control);
        }
    }

    private void resizeImageView(int seekBarId, int value) {
        ImageView view = (ImageView) selectedView;

        int newWidth = view.getWidth();
        int newHeight = view.getHeight();
        switch (seekBarId) {
            case R.id.seekHeight:
                newHeight = value;
                break;
            case R.id.seekWidth:
                newWidth = value;
                break;
        }
        if (newWidth >= minControlSize && newHeight >= minControlSize) {
            resizeImageView(view, newWidth, newHeight);
            ((GICControl) view.getTag()).setWidth(newWidth);
            ((GICControl) view.getTag()).setHeight(newHeight);
            defaults.saveControl((GICControl) view.getTag());
        }
    }

    //TextView based controls including buttons
    private void resizeTextView(int seekBarId, int value) {
        TextView view = (TextView) selectedView;

        int newWidth = view.getWidth();
        int newHeight = view.getHeight();
        int newFont = (int) view.getTextSize();
        switch (seekBarId) {
            case R.id.seekHeight:
                newHeight = value;
                break;
            case R.id.seekWidth:
                newWidth = value;
                break;
            case R.id.seekFontSize:
                newFont = value;
                break;
        }
        if (newWidth >= minControlSize && newHeight >= minControlSize && newFont >= minFontSize) {
            view.setLayoutParams(new FrameLayout.LayoutParams(newWidth, newHeight));
            view.setTextSize(TypedValue.COMPLEX_UNIT_PX, newFont);
            ((GICControl) view.getTag()).setWidth(newWidth);
            ((GICControl) view.getTag()).setHeight(newHeight);
            ((GICControl) view.getTag()).setFontSize(newFont);
            defaults.saveControl((GICControl) view.getTag());
        }
    }

    @Override
    public void onProgressChanged(SeekBar seekBar, int value, boolean b) {
        if (selectedView instanceof TextView) {
            resizeTextView(seekBar.getId(), value);
        } else if (selectedView instanceof ImageView) {
            resizeImageView(seekBar.getId(), value);
        }
    }

    @Override
    public void onStartTrackingTouch(SeekBar seekBar) {

    }

    @Override
    public void onStopTrackingTouch(SeekBar seekBar) {

    }

    @SuppressWarnings("IntegerDivisionInFloatingPointContext")
    private float getPosition(float startingPosition, int controlSize) {
        float pos = startingPosition - (controlSize / 2);

        if (gridSize > 0) {
            float temp = pos % gridSize;
            if (temp < (gridSize / 2))
                pos = pos - temp;
            else
                pos = pos + gridSize - temp;
        }


        return pos;
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
                    float x = getPosition(event.getX(), view.getWidth());
                    float y = getPosition(event.getY(), view.getHeight());

                    view.setX(x);
                    view.setY(y);

                    view.setVisibility(View.VISIBLE);
                    ((GICControl) view.getTag()).setLeft(view.getX());
                    ((GICControl) view.getTag()).setTop(view.getY());
                    break;
                case DragEvent.ACTION_DRAG_ENDED:
                default:
                    break;
            }
            return true;
        }
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
                //clickHandler(view);
                return true;
            } else {
                return false;
            }
        }
    }

    private void setupButtons() {
        final EditActivity editActivity = this;
        findViewById(R.id.btnSave).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (dialog == null) {
                    //prepare our dialog
                    dialog = new ProgressDialog(editActivity);
                    dialog.setMessage(getString(R.string.loading));
                    dialog.setIndeterminate(true);
                }
                dialog.show();
                currentScreen.setBackground(findViewById(R.id.topLayout).getBackground());
                screenRepository.save(currentScreen, new IScreenRepository.LoadScreenCallback() {
                    @Override
                    public void onLoaded(IScreen screen) {
                        dialog.dismiss();
                    }
                });
            }
        });

        findViewById(R.id.btnSettings).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                displayEditBackgroundDialog();
            }
        });
    }

}
