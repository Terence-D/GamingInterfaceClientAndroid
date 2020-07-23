package ca.coffeeshopstudio.gaminginterfaceclient.models;

import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;
import android.widget.Toast;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.util.Map;

import ca.coffeeshopstudio.gaminginterfaceclient.R;

import static android.content.Context.MODE_PRIVATE;

/**
 * Copyright [2019] [Terence Doerksen]
 * <p>
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * <p>
 * http://www.apache.org/licenses/LICENSE-2.0
 * <p>
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
public class ControlDefaults {
    private final String PREFS_NAME_FLUTTER = "FlutterSharedPreferences";

    private GICControl defaultImageControl;
    private GICControl defaultButtonControl;
    private GICControl defaultTextControl;
    private GICControl defaultSwitchControl;

    //constructor purely for making compatible with flutter
    public ControlDefaults(Context context) {
        final String PREFS_NAME_LEGACY = "gicsScreen";
        final String PREFS_FLUTTER_PREFIX = "flutter.";
        SharedPreferences prefsLegacy = context.getApplicationContext().getSharedPreferences(PREFS_NAME_LEGACY, MODE_PRIVATE);
        SharedPreferences prefsFlutter = context.getApplicationContext().getSharedPreferences(PREFS_NAME_FLUTTER, MODE_PRIVATE);
        SharedPreferences.Editor flutterEditor = prefsFlutter.edit();
        SharedPreferences.Editor legacyEditor = prefsLegacy.edit();

        Map<String, ?> keys = prefsLegacy.getAll();
        for (Map.Entry<String, ?> entry : keys.entrySet()) {
            Log.d("GICS", "cleanupLegacyDefaults: " + entry.getKey());
            if (containsKey(entry.getKey()) ) {
                Log.d("GICS", "cleanupLegacy: " + "converting");
                //we need to convert
                if (entry.getValue() instanceof String)
                    flutterEditor.putString(entry.getKey(), (String) entry.getValue());
                else //gotta be an int
                    flutterEditor.putInt(entry.getKey(), (Integer) entry.getValue());
                //and remove
                legacyEditor.remove(entry.getKey());
            }
        }

        //set resource defaults
        flutterEditor.putInt("default_button_primary", R.drawable.button_blue);
        flutterEditor.putInt("default_button_secondary", R.drawable.button_blue_dark);
        flutterEditor.putInt("default_switch_primary", R.drawable.switch_off);
        flutterEditor.putInt("default_switch_secondary", R.drawable.switch_on);

        legacyEditor.apply();
        flutterEditor.apply();
    }
    private boolean containsKey (String key) {
        return  key.contains("_image_defaults") ||
                key.contains("_button_defaults") ||
                key.contains("_text_defaults") ||
                key.contains("_switch_defaults");
    }


    public ControlDefaults(Context context, int screenId) {
        SharedPreferences prefs = context.getApplicationContext().getSharedPreferences(PREFS_NAME_FLUTTER, MODE_PRIVATE);

        String prefString = screenId + "_image_defaults";
        defaultImageControl = loadControl(context, prefs, prefString);
        prefString = screenId + "_button_defaults";
        defaultButtonControl = loadControl(context, prefs, prefString);
        prefString = screenId + "_text_defaults";
        defaultTextControl = loadControl(context, prefs, prefString);
        prefString = screenId + "_switch_defaults";
        defaultSwitchControl = loadControl(context, prefs, prefString);
    }

    public GICControl getImageDefaults() {
        return defaultImageControl;
    }

    public GICControl getButtonDefaults() {
        return defaultButtonControl;
    }

    public GICControl getTextDefaults() {
        return defaultTextControl;
    }

    public GICControl getSwitchDefaults() {
        return defaultSwitchControl;
    }

    public void saveControl(GICControl control) {
        if (control.getViewType() == GICControl.TYPE_TEXT) {
            defaultTextControl = control;
        } else if (control.getViewType() == GICControl.TYPE_BUTTON || control.getViewType() == GICControl.TYPE_BUTTON_QUICK) {
            defaultButtonControl = control;
        } else if (control.getViewType() == GICControl.TYPE_IMAGE) {
            defaultImageControl = control;
        } else if (control.getViewType() == GICControl.TYPE_SWITCH) {
            defaultSwitchControl = control;
        }
    }

    private GICControl loadControl(Context context, SharedPreferences prefs, String prefString) {
        GICControl defaultControl = new GICControl();
        final ObjectMapper mapper = new ObjectMapper();
        if (prefs.contains(prefString)) {
            String raw = prefs.getString(prefString, "");
            if (raw != null && !raw.isEmpty()) {
                try {
                    defaultControl = mapper.readValue(raw, GICControl.class);
                } catch (IOException e) {
                    e.printStackTrace();
                    Toast.makeText(context, e.getLocalizedMessage(), Toast.LENGTH_LONG).show();
                }
            }
        }
        return defaultControl;
    }

    public void saveDefaults(Context context, int screenId) {
        SharedPreferences prefs = context.getApplicationContext().getSharedPreferences(PREFS_NAME_FLUTTER, MODE_PRIVATE);
        save(context, screenId, prefs);
    }

    //reusable for both saveDefaults and the new upgrade method
    private void save(Context context, int screenId, SharedPreferences prefs) {
        SharedPreferences.Editor prefsEditor = prefs.edit();
        ObjectMapper mapper = new ObjectMapper();
        String json;

        try {
            String prefString = screenId + "_image_defaults";
            json = mapper.writeValueAsString(defaultImageControl);
            prefsEditor.putString(prefString, json);

            prefString = screenId + "_text_defaults";
            json = mapper.writeValueAsString(defaultTextControl);
            prefsEditor.putString(prefString, json);

            prefString = screenId + "_button_defaults";
            json = mapper.writeValueAsString(defaultButtonControl);
            prefsEditor.putString(prefString, json);

            prefString = screenId + "_switch_defaults";
            json = mapper.writeValueAsString(defaultSwitchControl);
            prefsEditor.putString(prefString, json);
        } catch (JsonProcessingException e) {
            e.printStackTrace();
            Toast.makeText(context, e.getLocalizedMessage(), Toast.LENGTH_LONG).show();
        }

        prefsEditor.apply();
    }
}
