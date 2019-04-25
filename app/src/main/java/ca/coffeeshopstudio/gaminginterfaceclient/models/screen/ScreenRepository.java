package ca.coffeeshopstudio.gaminginterfaceclient.models.screen;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.util.Log;
import android.util.SparseArray;

import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.File;
import java.io.IOException;
import java.lang.ref.WeakReference;
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
    private static List<IScreen> cache;
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

    private static void screenLoader(Context context) {
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
                    loadBackground(screen, context);
                    loadControls(screen, context);
                    cache.add(screen);
                }
            }
        }
    }

    private static void loadControls(Screen screen, Context context) {
        convertLegacyControls(screen, context);
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

    private static void loadBackground(Screen screen, Context context) {
        convertLegacyBackground(screen, context);
        SharedPreferences prefs = context.getApplicationContext().getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
        int backgroundColor = prefs.getInt(screen.getScreenId() + PREFS_BACKGROUND_SUFFIX, context.getResources().getColor(R.color.default_background));
        String backgroundPath = prefs.getString(screen.getScreenId() + PREFS_BACKGROUND_PATH_SUFFIX, "");
        screen.setBackgroundColor(backgroundColor);
        screen.setBackgroundFile(backgroundPath);
    }

    private static void convertLegacyControls(Screen screen, Context context) {
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

    private static void convertLegacyBackground(Screen screen, Context context) {
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

    private static int getUniqueId(int startingId) {
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

    private static void getUniqueName(IScreen newScreen) {
        for (IScreen screen : cache) {
            if (screen.getName().equals(newScreen.getName())) {
                newScreen.setName(newScreen.getName() + "1");
                getUniqueName(newScreen);
            }
        }
    }

    private static void screenSaver(Context context, IScreen screen) {
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

    private static void deleteScreen(Context context, IScreen screen) {
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

    @Override
    public void loadScreens(@NonNull LoadCallback callback) {
        new LoadScreenAsync(context, callback);
    }

    @Override
    public void getScreenList(@NonNull LoadScreenListCallback callback) {
        new GetScreenListAsync(context, callback).execute();
    }

    //this handles both legacy (1.x) and new builds
    @Override
    public void init(@NonNull LoadCallback callback) {
        new InitAsync(context, callback).execute();
    }

    @Override
    public void newScreen(@NonNull LoadScreenCallback callback) {
        new NewScreenAsync(context, callback).execute();
    }

    @Override
    public void importScreen(final IScreen screen, @NonNull LoadScreenCallback callback) {
        new ImportScreenAsync(context, screen, callback).execute();
    }

    @Override
    public void importScreenSync(IScreen screen) {
        screenLoader(context);
        getUniqueName(screen);
        final Screen newScreen = (Screen) screen;
        newScreen.setScreenId(getUniqueId(cache.size()));
        cache = null; //invalidate the cache
        //cache.add(newScreen);
        screenSaver(context, newScreen);
    }

    @Override
    public void save(IScreen screen, @NonNull LoadScreenCallback callback) {
        new SaveScreenAsync(context, screen, callback);
    }

    @Override
    public void getScreen(int id, @NonNull LoadScreenCallback callback) {
        new GetScreenAsync(context, id, callback);
    }

    @Override
    public IScreen getScreenSync(int id) {
        for (int i = 0; i < cache.size(); i++) {
            if (cache.get(i).getScreenId() == id)
                return cache.get(i);
        }
        return null;
    }

    @Override
    public void removeScreen(int id, @NonNull LoadScreenCallback callback) {
        new DeleteScreenAsync(context, id, callback);
    }

    private static class GetScreenListAsync extends AsyncTask<Void, Void, Void> {
        final WeakReference<Context> weakContext;
        LoadScreenListCallback callback;
        // Weak references will still allow the Activity to be garbage-collected
        private SparseArray<String> rv = new SparseArray<>();

        GetScreenListAsync(Context context, LoadScreenListCallback callback) {
            weakContext = new WeakReference<>(context);
            this.callback = callback;
        }

        @Override
        protected Void doInBackground(Void... voids) {
            if (cache != null) {
                for (IScreen screen : cache) {
                    rv.put(screen.getScreenId(), screen.getName());
                }
            } else {
                screenLoader(weakContext.get());
                SparseArray<String> rv = new SparseArray<>();
                for (IScreen screen : cache) {
                    rv.put(screen.getScreenId(), screen.getName());
                }
            }
            callback.onLoaded(rv);

            return null;
        }

        @Override
        protected void onPostExecute(Void aVoid) {
            super.onPostExecute(aVoid);
            callback.onLoaded(rv);
        }
    }

    private static class InitAsync extends AsyncTask<Void, Void, Void> {
        // Weak references will still allow the Activity to be garbage-collected
        final WeakReference<Context> weakContext;
        LoadCallback callback;

        InitAsync(Context context, LoadCallback callback) {
            weakContext = new WeakReference<>(context);
            this.callback = callback;
        }


        @Override
        protected Void doInBackground(Void... voids) {
            screenLoader(weakContext.get());
            if (cache.size() == 0) {
                //load in the legacy
                Screen screen = new Screen(0, weakContext.get());
                SharedPreferences prefs = weakContext.get().getApplicationContext().getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
                SharedPreferences.Editor prefsEditor = prefs.edit();

                prefsEditor.putInt(PREFS_SCREEN + screen.getScreenId(), 1);

                prefsEditor.apply();

                loadBackground(screen, weakContext.get());
                loadControls(screen, weakContext.get());
                cache.add(screen);
            }
            return null;
        }

        @Override
        protected void onPostExecute(Void aVoid) {
            super.onPostExecute(aVoid);
            callback.onLoaded(cache);
        }
    }

    private static class SaveScreenAsync extends AsyncTask<Void, Void, Void> {
        // Weak references will still allow the Activity to be garbage-collected
        final WeakReference<Context> weakContext;
        LoadScreenCallback callback;
        IScreen screen;

        SaveScreenAsync(Context context, IScreen screen, LoadScreenCallback callback) {
            weakContext = new WeakReference<>(context);
            this.callback = callback;
            this.screen = screen;
        }


        @Override
        protected Void doInBackground(Void... voids) {
            screenSaver(weakContext.get(), screen);
            return null;
        }

        @Override
        protected void onPostExecute(Void aVoid) {
            super.onPostExecute(aVoid);
            callback.onLoaded(screen);
        }
    }

    private static class LoadScreenAsync extends AsyncTask<Void, Void, Void> {
        // Weak references will still allow the Activity to be garbage-collected
        final WeakReference<Context> weakContext;
        LoadCallback callback;

        LoadScreenAsync(Context context, LoadCallback callback) {
            weakContext = new WeakReference<>(context);
            this.callback = callback;
        }

        @Override
        protected Void doInBackground(Void... voids) {
            screenLoader(weakContext.get());
            return null;
        }

        @Override
        protected void onPostExecute(Void aVoid) {
            super.onPostExecute(aVoid);
            callback.onLoaded(cache);
        }
    }

    private static class NewScreenAsync extends AsyncTask<Void, Void, Void> {
        // Weak references will still allow the Activity to be garbage-collected
        final WeakReference<Context> weakContext;
        LoadScreenCallback callback;
        Screen newScreen;

        NewScreenAsync(Context context, LoadScreenCallback callback) {
            weakContext = new WeakReference<>(context);
            this.callback = callback;
        }

        @Override
        protected void onPostExecute(Void aVoid) {
            super.onPostExecute(aVoid);
            callback.onLoaded(newScreen);
        }

        @Override
        protected Void doInBackground(Void... voids) {
            newScreen = new Screen(getUniqueId(cache.size()), weakContext.get());
            newScreen.setBackgroundColor(weakContext.get().getResources().getColor(R.color.default_background));
            cache = null; //invalidate the cache
            //cache.add(newScreen);

            screenSaver(weakContext.get(), newScreen);
            screenLoader(weakContext.get());
            return null;
        }
    }

    private static class ImportScreenAsync extends AsyncTask<Void, Void, Void> {
        // Weak references will still allow the Activity to be garbage-collected
        final WeakReference<Context> weakContext;
        LoadScreenCallback callback;
        IScreen screen;

        ImportScreenAsync(Context context, IScreen screen, LoadScreenCallback callback) {
            weakContext = new WeakReference<>(context);
            this.callback = callback;
            this.screen = screen;
        }

        @Override
        protected void onPostExecute(Void aVoid) {
            super.onPostExecute(aVoid);
        }

        @Override
        protected Void doInBackground(Void... voids) {
            screenLoader(weakContext.get());
            getUniqueName(screen);
            final Screen newScreen = (Screen) screen;
            newScreen.setScreenId(getUniqueId(cache.size()));
            cache = null; //invalidate the cache
            //cache.add(newScreen);
            screenSaver(weakContext.get(), newScreen);

            return null;
        }
    }

    private static class GetScreenAsync extends AsyncTask<Void, Void, Void> {
        // Weak references will still allow the Activity to be garbage-collected
        final WeakReference<Context> weakContext;
        LoadScreenCallback callback;
        int screenId;
        IScreen screen = null;

        GetScreenAsync(Context context, int screenId, LoadScreenCallback callback) {
            weakContext = new WeakReference<>(context);
            this.callback = callback;
            this.screenId = screenId;
        }


        @Override
        protected Void doInBackground(Void... voids) {
            for (int i = 0; i < cache.size(); i++) {
                if (cache.get(i).getScreenId() == screenId)
                    screen = cache.get(i);
            }
            return null;
        }

        @Override
        protected void onPostExecute(Void aVoid) {
            super.onPostExecute(aVoid);
            callback.onLoaded(screen);
        }
    }

    private static class DeleteScreenAsync extends AsyncTask<Void, Void, Void> {
        // Weak references will still allow the Activity to be garbage-collected
        final WeakReference<Context> weakContext;
        LoadScreenCallback callback;
        int screenId;
        IScreen screen = null;

        DeleteScreenAsync(Context context, int screenId, LoadScreenCallback callback) {
            weakContext = new WeakReference<>(context);
            this.callback = callback;
            this.screenId = screenId;
        }


        @Override
        protected Void doInBackground(Void... voids) {
            for (int i = 0; i < cache.size(); i++) {
                if (cache.get(i).getScreenId() == screenId) {
                    screen = cache.get(i);
                    deleteScreen(weakContext.get(), cache.get(i));
                }
            }
            cache = null;
            screenLoader(weakContext.get());
            return null;
        }

        @Override
        protected void onPostExecute(Void aVoid) {
            super.onPostExecute(aVoid);
            callback.onLoaded(screen);
        }
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
