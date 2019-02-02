package ca.coffeeshopstudio.gaminginterfaceclient.models;

import android.content.Context;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.support.v7.widget.AppCompatTextView;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import ca.coffeeshopstudio.gaminginterfaceclient.R;

import static android.content.Context.MODE_PRIVATE;

/**
 * TODO: HEADER COMMENT HERE.
 */
public class Screen {
    private final String PREFS_NAME = "gicsScreen";
    
    private Context context;
    //private View layoutView;
    private List<Control> customControls = new ArrayList<>();
    private List<View> views = new ArrayList<>();
    private List<Integer> primaryColors = new ArrayList<>();
    private List<Integer> secondaryColors = new ArrayList<>();
    private int maxControlSize = 800;
    private int activeControl = -1;
    private int newId = 0;

    private int screenId;

    public Screen(Context context) {
        this.context = context;
    }

    public void saveScreen(Drawable background) {
        SharedPreferences prefs = context.getApplicationContext().getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
        SharedPreferences.Editor prefsEditor = prefs.edit();

        //save the images
        if (background instanceof ColorDrawable) {
            ColorDrawable color = (ColorDrawable) background;
            prefsEditor.putInt(screenId + "_background", color.getColor());
        } else {
            BitmapDrawable bitmap = (BitmapDrawable) background;
            saveBitmap(screenId + "_background.png", bitmap.getBitmap());
            prefsEditor.putInt(screenId + "_background", -1);
        }

        ObjectMapper mapper = new ObjectMapper();

        //first we need to remove all existing views
        Map<String, ?> keys = prefs.getAll();
        for (Map.Entry<String, ?> entry : keys.entrySet()) {
            if (entry.getKey().contains(screenId + "_control_")) {
                prefsEditor.remove(entry.getKey());
            }
        }

        try {
            int i = 0;
            for (View view : views) {
                Control control = new Control();
                control.setCommand((Command) view.getTag());
                control.setWidth(view.getWidth());
                control.setLeft(view.getX());
                control.setTop(view.getY());
                control.setHeight(view.getBottom());
                control.setPrimaryColor(primaryColors.get(i));
                control.setSecondaryColor(secondaryColors.get(i));

                if (view instanceof ImageView) {
                    control.setViewType(2);
                    //in newer version of android, if this is an adaptive icon, it might crash.
                    //so instead of dealing with different code / different versions -
                    // simple try/catch
                    try {
                        BitmapDrawable bitmap = (BitmapDrawable) ((ImageView) view).getDrawable();
                        String imageName = screenId + "_control" + i + ".png";
                        saveBitmap(imageName, bitmap.getBitmap());
                        control.setPrimaryImage(imageName);
                    } catch (Exception e) {
                        e.printStackTrace();
                        //no big, it'll just load the default
                    }
                } else if (view instanceof Button)
                    control.setViewType(0);
                else if (view instanceof AppCompatTextView)
                    control.setViewType(1);

                //common between Button and AppCompatTextView above
                if (view instanceof TextView) {
                    control.setFontSize((int) ((TextView) view).getTextSize());
                    control.setText(((TextView) view).getText().toString());
                    control.setFontColor(((TextView) view).getTextColors().getDefaultColor());
                }

                String json = mapper.writeValueAsString(control);
                prefsEditor.putString(screenId + "_control_" + i, json);
                i++;
            }
            prefsEditor.apply();
            Toast.makeText(context, R.string.edit_activity_saved, Toast.LENGTH_SHORT).show();
        } catch (IOException e) {
            e.printStackTrace();
            Toast.makeText(context, e.getLocalizedMessage(), Toast.LENGTH_LONG).show();
        }
    }

    //TODO remove this after next big release
    private void convertLegacyControls() {
        SharedPreferences prefs = context.getApplicationContext().getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
        SharedPreferences.Editor prefsEditor = prefs.edit();

        Map<String, ?> keys = prefs.getAll();
        for (Map.Entry<String, ?> entry : keys.entrySet()) {
            if (entry.getKey().startsWith("control_")) {
                prefsEditor.remove(entry.getKey());

                if (entry.getValue() instanceof Integer) {
                    prefsEditor.putInt(screenId + "_" + entry.getKey(), (Integer) entry.getValue());
                } else if (entry.getValue() instanceof String) {
                    prefsEditor.putString(screenId + "_" + entry.getKey(), (String) entry.getValue());
                } else {
                    Log.d("GICS", "convertLegacyControls: unknown type of pref " + entry.getValue());
                }
            }
        }
        prefsEditor.apply();
    }

    private void convertLegacyBackground() {
        SharedPreferences prefs = context.getApplicationContext().getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
        if (prefs.contains("background")) {
            SharedPreferences.Editor prefsEditor = prefs.edit();
            int backgroundColor = prefs.getInt("background", -1);
            prefsEditor.putInt(screenId + "_background", backgroundColor);
            prefsEditor.remove("background");
            prefsEditor.apply();
        }
        String backgroundPath = "background" + ".jpg";
        File file = new File(context.getFilesDir() + "/" + backgroundPath);
        if (file.exists()) {
            String newBackgroundPath = screenId + "_background" + ".png";
            File newFile = new File(context.getFilesDir() + "/" + newBackgroundPath);
            file.renameTo(newFile);
        }
    }

    public void loadControls() {
        convertLegacyControls();
        SharedPreferences prefs = context.getApplicationContext().getSharedPreferences(PREFS_NAME, MODE_PRIVATE);

        final ObjectMapper mapper = new ObjectMapper();

        Map<String, ?> keys = prefs.getAll();
        for (Map.Entry<String, ?> entry : keys.entrySet()) {
            if (entry.getKey().contains(screenId + "_control_")) {
                try {
                    customControls.add(mapper.readValue(prefs.getString(entry.getKey(), ""), Control.class));
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    public Drawable loadBackground() {
        convertLegacyBackground();
        SharedPreferences prefs = context.getApplicationContext().getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
        int backgroundColor = prefs.getInt(screenId + "_background", 0xFF0099CC);
        if (backgroundColor == -1) {
            String backgroundPath = screenId + "_background.png";

            Bitmap bitmap = BitmapFactory.decodeFile(context.getFilesDir() + "/" + backgroundPath);
            Drawable bitmapDrawable = new BitmapDrawable(context.getResources(), bitmap);

            return bitmapDrawable;
        } else {
            ColorDrawable color = new ColorDrawable();
            color.setColor(backgroundColor);
            return color;
        }
    }

    public Drawable loadImage(String fileName) {
        if (fileName.startsWith(screenId + "_control")) {
            Bitmap bitmap = BitmapFactory.decodeFile(context.getFilesDir() + "/" + fileName);
            Drawable bitmapDrawable = new BitmapDrawable(context.getResources(), bitmap);
            return bitmapDrawable;
        }
        return null;
    }

    public int getMaxControlSize() {
        return maxControlSize;
    }

    private boolean saveBitmap(String fileName, Bitmap image) {
        File file = new File(context.getFilesDir(), fileName);

        try {
            FileOutputStream out = new FileOutputStream(file);
            image.compress(Bitmap.CompressFormat.PNG, 90, out);
            out.flush();
            out.close();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public void addView(View view) {
        views.add(view);
    }

    public void addPrimaryColor(int primaryColor) {
        primaryColors.add(primaryColor);
    }

    public void addSecondaryColor(int secondaryColor) {
        secondaryColors.add(secondaryColor);
    }

    public int getNewId() {
        newId++;
        return newId - 1;
    }

    public List<View> getViews() {
        return views;
    }

    public int getActiveControlId() {
        return activeControl;
    }

    public void setActiveControl(int id) {
        activeControl = id;
    }

    //resets what our current active control is to the last added one
    public void resetActiveControl() {
        activeControl = views.size() - 1;
    }

    public void unsetActiveControl() {
        activeControl = -1;
    }

    public View getActiveView() {
        return findControl(activeControl);
    }

    public int getActiveControlPrimaryColor() {
        return primaryColors.get(activeControl);
    }

    public void setActiveControlPrimaryColor(int color) {
        primaryColors.set(activeControl, color);
    }

    public int getActiveControlSecondaryColor() {
        return secondaryColors.get(activeControl);
    }

    public void setActiveControlSecondaryColor(int color) {
        secondaryColors.set(activeControl, color);
    }

    private View findControl(int id) {
        for (View view : getViews()) {
            if (view.getId() == id)
                return view;
        }
        return null;
    }

    public void removeCurrentView() {
        getViews().remove(getActiveView());
        //primaryColors.remove(activeControl);
        //secondaryColors.remove(activeControl);
        unsetActiveControl();
    }

    public List<Control> getCustomControls() {
        return customControls;
    }
}
