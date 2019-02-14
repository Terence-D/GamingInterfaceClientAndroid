package ca.coffeeshopstudio.gaminginterfaceclient.models.screen;

import android.content.Context;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.ColorDrawable;
import android.util.Log;
import android.util.SparseArray;
import android.widget.Toast;

import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import ca.coffeeshopstudio.gaminginterfaceclient.R;
import ca.coffeeshopstudio.gaminginterfaceclient.models.GICControl;

import static android.content.Context.MODE_PRIVATE;

/**
 * TODO: HEADER COMMENT HERE.
 */
public class ScreenRepository implements IScreenRepository {
    static List<Screen> cache;
    private final String PREFS_NAME = "gicsScreen";
    private final String PREFS_SCREEN = "screen_";
    private final String PREFS_BACKGROUND_SUFFIX = "_background";
    private final String PREFS_CONTROLS = "_control_";
    private Context context;

    public ScreenRepository(Context context) {
        this.context = context;
    }

    @Override
    public void loadScreens() {
        if (cache == null) {
            //init the cache
            cache = new ArrayList<>();

            SharedPreferences prefs = context.getApplicationContext().getSharedPreferences(PREFS_NAME, MODE_PRIVATE);

            int screenId = 0;
            Map<String, ?> keys = prefs.getAll();
            for (Map.Entry<String, ?> entry : keys.entrySet()) {
                if (entry.getKey().contains(PREFS_SCREEN + screenId)) {
                    Screen screen = new Screen(screenId, context);
                    cache.add(screen);
                    loadBackground(screen);
                    loadControls(screen);
                }
            }
            if (cache.size() == 0) {
                //load in the legacy
                cache.add(loadLegacyScreen());
            }
        }
    }

    private Screen loadLegacyScreen() {
        Screen screen = new Screen(0, context);
        cache.add(screen);
        loadBackground(screen);
        loadControls(screen);
        return screen;
    }

    private void loadControls(Screen screen) {
        convertLegacyControls(screen);
        SharedPreferences prefs = context.getApplicationContext().getSharedPreferences(PREFS_NAME, MODE_PRIVATE);

        final ObjectMapper mapper = new ObjectMapper();

        Map<String, ?> keys = prefs.getAll();
        for (Map.Entry<String, ?> entry : keys.entrySet()) {
            if (entry.getKey().contains(screen.getScreenId() + "_control_")) {
                try {
                    screen.addControl(mapper.readValue(prefs.getString(entry.getKey(), ""), GICControl.class));
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    private void loadBackground(Screen screen) {
        convertLegacyBackground(screen);
        SharedPreferences prefs = context.getApplicationContext().getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
        int backgroundColor = prefs.getInt(screen.getScreenId() + "_background", context.getResources().getColor(R.color.default_background));
        String backgroundPath = screen.getScreenId() + "_background.png";
        screen.setBackgroundColor(backgroundColor);
        screen.setBackgroundFile(backgroundPath);
    }

    private void convertLegacyControls(Screen screen) {
        SharedPreferences prefs = context.getApplicationContext().getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
        SharedPreferences.Editor prefsEditor = prefs.edit();

        Map<String, ?> keys = prefs.getAll();
        for (Map.Entry<String, ?> entry : keys.entrySet()) {
            if (entry.getKey().startsWith("control_")) {
                prefsEditor.remove(entry.getKey());

                if (entry.getValue() instanceof Integer) {
                    prefsEditor.putInt(screen.getScreenId() + "_" + entry.getKey(), (Integer) entry.getValue());
                } else if (entry.getValue() instanceof String) {
                    prefsEditor.putString(screen.getScreenId() + "_" + entry.getKey(), (String) entry.getValue());
                } else {
                    Log.d("GICS", "convertLegacyControls: unknown type of pref " + entry.getValue());
                }
            }
        }
        prefsEditor.apply();
    }

    private void convertLegacyBackground(Screen screen) {
        SharedPreferences prefs = context.getApplicationContext().getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
        if (prefs.contains("background")) {
            SharedPreferences.Editor prefsEditor = prefs.edit();
            int backgroundColor = prefs.getInt("background", -1);
            prefsEditor.putInt(screen.getScreenId() + "_background", backgroundColor);
            prefsEditor.remove("background");
            prefsEditor.apply();
        }
        String backgroundPath = "background" + ".jpg";
        File file = new File(context.getFilesDir() + "/" + backgroundPath);
        if (file.exists()) {
            String newBackgroundPath = screen.getScreenId() + "_background" + ".png";
            File newFile = new File(context.getFilesDir() + "/" + newBackgroundPath);
            file.renameTo(newFile);
        }
    }

    @Override
    public Screen newScreen() {
        Screen newScreen = new Screen(cache.size(), context);
        cache.add(newScreen);

        return newScreen;
    }

    @Override
    public void save(Screen screen) {
        SharedPreferences prefs = context.getApplicationContext().getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
        SharedPreferences.Editor prefsEditor = prefs.edit();

        prefsEditor.putInt(PREFS_SCREEN + screen.getScreenId(), 1);

        //save the background image
        if (screen.getBackground() != null) {
            if (screen.getBackground() instanceof ColorDrawable) {
                ColorDrawable color = (ColorDrawable) screen.getBackground();
                prefsEditor.putInt(screen.getScreenId() + PREFS_BACKGROUND_SUFFIX, color.getColor());
            } else {
                BitmapDrawable bitmap = (BitmapDrawable) screen.getBackground();
                saveBitmap(screen.getScreenId() + PREFS_BACKGROUND_SUFFIX, bitmap.getBitmap());
                prefsEditor.putInt(screen.getScreenId() + PREFS_BACKGROUND_SUFFIX, -1);
            }
        }

        ObjectMapper mapper = new ObjectMapper();

        //first we need to remove all existing views
        Map<String, ?> keys = prefs.getAll();
        for (Map.Entry<String, ?> entry : keys.entrySet()) {
            if (entry.getKey().contains(screen.getScreenId() + PREFS_CONTROLS)) {
                prefsEditor.remove(entry.getKey());
            }
        }

        try {
            int i = 0;
            for (GICControl control : screen.getControls()) {
                String json = mapper.writeValueAsString(control);
                prefsEditor.putString(screen.getScreenId() + PREFS_CONTROLS + i, json);
                i++;
            }
            prefsEditor.apply();
            Toast.makeText(context, R.string.edit_activity_saved, Toast.LENGTH_SHORT).show();
        } catch (IOException e) {
            e.printStackTrace();
            Toast.makeText(context, e.getLocalizedMessage(), Toast.LENGTH_LONG).show();
        }
    }

    @Override
    public Screen getScreen(int id) {
        if (id >= cache.size())
            return null;
        return cache.get(id);
    }

    @Override
    public SparseArray<String> getScreenList() {

        SparseArray<String> rv = new SparseArray<>();
        for (Screen screen : cache) {
            rv.put(screen.getScreenId(), screen.getName());
        }
        return rv;
    }

    @Override
    public void removeScreen(int id) {
        //TODO
    }

    private void saveBitmap(String fileName, Bitmap image) {
        File file = new File(context.getFilesDir(), fileName + ".png");

        try {
            FileOutputStream out = new FileOutputStream(file);
            image.compress(Bitmap.CompressFormat.PNG, 90, out);
            out.flush();
            out.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}