package ca.coffeeshopstudio.gaminginterfaceclient.models.screen;

import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;
import android.util.SparseArray;

import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import androidx.annotation.NonNull;
import ca.coffeeshopstudio.gaminginterfaceclient.R;
import ca.coffeeshopstudio.gaminginterfaceclient.models.GICControl;

import static android.content.Context.MODE_PRIVATE;

/**
 * TODO: HEADER COMMENT HERE.
 */
public class ScreenRepository implements IScreenRepository {
    static List<IScreen> cache;
    public static final String PREFS_NAME = "gicsScreen";
    private static final String PREFS_SCREEN = "screen_";
    private static final String PREFS_BACKGROUND_SUFFIX = "_background";
    private static final String PREFS_BACKGROUND_PATH_SUFFIX = "_background_path";
    private static final String PREFS_CONTROLS = "_control_";
    private Context context;
    private final static Pattern lastIntPattern = Pattern.compile("[^0-9]+([0-9]+)$");

    public ScreenRepository(Context context) {
        this.context = context;
    }

    @Override
    public void loadScreens(@NonNull final LoadCallback callback) {
        loadScreens();
        callback.onLoaded(cache);
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
                if (entry.getKey().contains(PREFS_SCREEN)) {
                    Matcher matcher = lastIntPattern.matcher(entry.getKey());
                    if (matcher.find()) {
                        String someNumberStr = matcher.group(1);
                        screenId = Integer.parseInt(someNumberStr);
                    }

                    Screen screen = new Screen(screenId, context);
                    try { //legacy used an integer dummy value, so we need to handle that
                        screen.setName((String) entry.getValue());
                    } catch (Exception e) {
                        screen.setName("Screen " + screenId);
                    }
                    cache.add(screen);
                    loadBackground(screen);
                    loadControls(screen);
                }
            }
        }
    }

    //this handles both legacy (1.x) and new builds
    public void init() {
        loadScreens();
        if (cache.size() == 0) {
            //load in the legacy
            Screen screen = new Screen(0, context);
            SharedPreferences prefs = context.getApplicationContext().getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
            SharedPreferences.Editor prefsEditor = prefs.edit();

            prefsEditor.putInt(PREFS_SCREEN + screen.getScreenId(), 1);

            prefsEditor.apply();

            loadBackground(screen);
            loadControls(screen);
            cache.add(screen);
        }
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
        int backgroundColor = prefs.getInt(screen.getScreenId() + PREFS_BACKGROUND_SUFFIX, context.getResources().getColor(R.color.default_background));
        String backgroundPath = prefs.getString(screen.getScreenId() + PREFS_BACKGROUND_PATH_SUFFIX, "");
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
            prefsEditor.remove("background");
            prefsEditor.apply();
        }
        String backgroundPath = "background" + ".jpg";
        File file = new File(context.getFilesDir() + "/" + backgroundPath);
        if (file.exists()) {
            String newBackgroundPath = screen.getScreenId() + "_background.png";
            File newFile = new File(context.getFilesDir() + "/" + newBackgroundPath);
            file.renameTo(newFile);
        }
    }

    @Override
    public Screen newScreen() {
        Screen newScreen = new Screen(getUniqueId(cache.size()), context);
        newScreen.setBackgroundColor(context.getResources().getColor(R.color.default_background));
        cache = null; //invalidate the cache
        //cache.add(newScreen);

        save(newScreen);
        loadScreens(new LoadCallback() {
            @Override
            public void onLoaded(List<IScreen> screens) {
                //ignore
            }
        });
        return newScreen;
    }

    @Override
    public void importScreen(final IScreen screen) {
        loadScreens(new LoadCallback() {
            @Override
            public void onLoaded(List<IScreen> screens) {
                getUniqueName(screen);
                final Screen newScreen = (Screen) screen;
                newScreen.setScreenId(getUniqueId(cache.size()));
                cache = null; //invalidate the cache
                //cache.add(newScreen);
                save(newScreen);
            }
        });
    }

    private int getUniqueId(int startingId) {
        int unique = startingId;

        if (cache != null) {
            for (IScreen screen : cache) {
                if (unique == screen.getScreenId()) {
                    unique = getUniqueId(startingId + 1);
                }
            }
        }
        return unique;
    }

    private void getUniqueName(IScreen newScreen) {
        for (IScreen screen : cache) {
            if (screen.getName().equals(newScreen.getName())) {
                newScreen.setName(newScreen.getName() + "1");
                getUniqueName(newScreen);
            }
        }
    }


    @Override
    public void save(IScreen screen) {
        SharedPreferences prefs = context.getApplicationContext().getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
        SharedPreferences.Editor prefsEditor = prefs.edit();

        prefsEditor.putString(PREFS_SCREEN + screen.getScreenId(), screen.getName());

        //save the background image
//        if (screen.getBackground() != null) {
//            if (screen.getBackground() instanceof ColorDrawable) {
//                ColorDrawable color = (ColorDrawable) screen.getBackground();
        prefsEditor.putInt(screen.getScreenId() + PREFS_BACKGROUND_SUFFIX, screen.getBackgroundColor());
//            } else {
//                prefsEditor.putInt(screen.getScreenId() + PREFS_BACKGROUND_SUFFIX, -1);
//            }
        prefsEditor.putString(screen.getScreenId() + PREFS_BACKGROUND_PATH_SUFFIX, screen.getBackgroundFile());
//            } else {
//                screen.setBackgroundFile(context.getFilesDir() + "/" + screen.getScreenId() + PREFS_BACKGROUND_SUFFIX + ".png");
//                saveBitmap(screen.getScreenId() + PREFS_BACKGROUND_SUFFIX, ((BitmapDrawable) image).getBitmap());
//                prefsEditor.putInt(screen.getScreenId() + PREFS_BACKGROUND_SUFFIX, -1);
//                prefsEditor.putString(screen.getScreenId() + PREFS_BACKGROUND_PATH_SUFFIX, screen.getBackgroundFile());
//            }
//        }

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
            //Toast.makeText(context, R.string.edit_activity_saved, Toast.LENGTH_SHORT).show();
        } catch (IOException e) {
            e.printStackTrace();
            //Toast.makeText(context, e.getLocalizedMessage(), Toast.LENGTH_LONG).show();
        }
    }

    @Override
    public IScreen getScreen(int id) {
        for (int i = 0; i < cache.size(); i++) {
            if (cache.get(i).getScreenId() == id)
                return cache.get(i);
        }
        return null;
    }

    //this is used by the main screen
//    @Override
//    public IScreen getScreenByPosition(int index) {
//        return cache.get(index);
//    }

    @Override
    public void getScreenList(@NonNull final LoadScreenListCallback callback) {

        if (cache != null) {
            SparseArray<String> rv = new SparseArray<>();
            for (IScreen screen : cache) {
                rv.put(screen.getScreenId(), screen.getName());
            }
            callback.onLoaded(rv);
        } else {
            loadScreens(new LoadCallback() {
                @Override
                public void onLoaded(List<IScreen> screens) {
                    SparseArray<String> rv = new SparseArray<>();
                    for (IScreen screen : cache) {
                        rv.put(screen.getScreenId(), screen.getName());
                    }
                    callback.onLoaded(rv);
                }
            });
        }
    }

    @Override
    public void removeScreen(int id) {
        for (int i = 0; i < cache.size(); i++) {
            if (cache.get(i).getScreenId() == id)
                deleteScreen(cache.get(i));
        }
        cache = null;
        loadScreens(new LoadCallback() {
            @Override
            public void onLoaded(List<IScreen> screens) {
                //ignore
            }
        });
    }

    private void deleteScreen(IScreen screen) {
        SharedPreferences prefs = context.getApplicationContext().getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
        SharedPreferences.Editor prefsEditor = prefs.edit();
        prefsEditor.remove(PREFS_SCREEN + screen.getScreenId());
        prefsEditor.remove(screen.getScreenId() + PREFS_BACKGROUND_SUFFIX);

        //first we need to remove all existing views
        Map<String, ?> keys = prefs.getAll();
        for (Map.Entry<String, ?> entry : keys.entrySet()) {
            if (entry.getKey().contains(screen.getScreenId() + PREFS_CONTROLS)) {
                prefsEditor.remove(entry.getKey());
            }
        }
        prefsEditor.apply();
    }

//    private void saveBitmap(String fileName, Bitmap image) {
//        File file = new File(context.getFilesDir(), fileName + ".png");
//
//        try {
//            FileOutputStream out = new FileOutputStream(file);
//            image.compress(Bitmap.CompressFormat.PNG, 90, out);
//            out.flush();
//            out.close();
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//    }
}
