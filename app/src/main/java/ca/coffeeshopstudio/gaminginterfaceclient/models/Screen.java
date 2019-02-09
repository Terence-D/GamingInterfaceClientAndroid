package ca.coffeeshopstudio.gaminginterfaceclient.models;

import android.content.Context;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.util.Log;
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
    private List<GICControl> customControls = new ArrayList<>();
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

        //save the background image
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
            for (GICControl control : customControls) {
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
                    customControls.add(mapper.readValue(prefs.getString(entry.getKey(), ""), GICControl.class));
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    public Drawable loadBackground() {
        convertLegacyBackground();
        SharedPreferences prefs = context.getApplicationContext().getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
        int backgroundColor = prefs.getInt(screenId + "_background", context.getResources().getColor(R.color.default_background) );
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

    public void addControl(GICControl control) {
        customControls.add(control);
    }

    public int getNewId() {
        newId++;
        //activeControl = newId - 1;
        return newId - 1;
    }

    public List<GICControl> getControls() {
        return customControls;
    }

    public int getScreenId() {
        return screenId;
    }

    public void removeControl(GICControl control) {
        customControls.remove(control);
    }
}
