package ca.coffeeshopstudio.gaminginterfaceclient.models;

import android.content.Context;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.view.View;
import android.widget.Button;
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
    private Context context;
    //private View layoutView;
    private List<Control> customControls = new ArrayList<>();
    private List<View> views = new ArrayList<>();
    private List<Integer> primaryColors = new ArrayList<>();
    private List<Integer> secondaryColors = new ArrayList<>();
    private int maxControlSize = 800;
    private int activeControl = -1;
    private int newId = 0;

    public Screen(Context context) {
        this.context = context;
    }

    public void saveScreen(Drawable background) {
        SharedPreferences prefs = context.getApplicationContext().getSharedPreferences("gicsScreen", MODE_PRIVATE);
        SharedPreferences.Editor prefsEditor = prefs.edit();

        //save the images
        if (background instanceof ColorDrawable) {
            ColorDrawable color = (ColorDrawable) background;
            prefsEditor.putInt("background", color.getColor());
        } else {
            BitmapDrawable bitmap = (BitmapDrawable) background;
            saveBitmapIntoSDCardImage(bitmap.getBitmap());
            prefsEditor.putInt("background", -1);
        }

        ObjectMapper mapper = new ObjectMapper();

        //first we need to remove all existing views
        Map<String, ?> keys = prefs.getAll();
        for (Map.Entry<String, ?> entry : keys.entrySet()) {
            if (entry.getKey().contains("control_")) {
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
            Toast.makeText(context, R.string.edit_activity_saved, Toast.LENGTH_SHORT).show();
        } catch (IOException e) {
            e.printStackTrace();
            Toast.makeText(context, e.getLocalizedMessage(), Toast.LENGTH_LONG).show();
        }
    }

    public void loadControls() {
        SharedPreferences prefs = context.getApplicationContext().getSharedPreferences("gicsScreen", MODE_PRIVATE);

        final ObjectMapper mapper = new ObjectMapper();

        Map<String, ?> keys = prefs.getAll();
        for (Map.Entry<String, ?> entry : keys.entrySet()) {
            if (entry.getKey().contains("control_")) {
                try {
                    customControls.add(mapper.readValue(prefs.getString(entry.getKey(), ""), Control.class));
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    public Drawable loadBackground() {
        SharedPreferences prefs = context.getApplicationContext().getSharedPreferences("gicsScreen", MODE_PRIVATE);
        int backgroundColor = prefs.getInt("background", 0xFF0099CC);
        if (backgroundColor == -1) {
            String backgroundPath = "background" + ".jpg";

            Bitmap bitmap = BitmapFactory.decodeFile(context.getFilesDir() + "/" + backgroundPath);
            Drawable bitmapDrawable = new BitmapDrawable(context.getResources(), bitmap);

            return bitmapDrawable;
        } else {
            ColorDrawable color = new ColorDrawable();
            color.setColor(backgroundColor);
            return color;
        }
    }

    public int getMaxControlSize() {
        return maxControlSize;
    }

    private boolean saveBitmapIntoSDCardImage(Bitmap finalBitmap) {
        String fname = "background" + ".jpg";
        File file = new File(context.getFilesDir(), fname);

        try {
            FileOutputStream out = new FileOutputStream(file);
            finalBitmap.compress(Bitmap.CompressFormat.JPEG, 90, out);
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

    public int getActiveControl() {
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

    public View findActiveControl() {
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
        getViews().remove(findActiveControl());
        //primaryColors.remove(activeControl);
        //secondaryColors.remove(activeControl);
        unsetActiveControl();
    }

    public List<Control> getCustomControls() {
        return customControls;
    }
}
