package ca.coffeeshopstudio.gaminginterfaceclient.models;

import android.content.Context;
import android.content.SharedPreferences;
import android.widget.Toast;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;

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
    private final String PREFS_NAME = "gicsScreen";
    private GICControl defaultImageControl;
    private GICControl defaultButtonControl;
    private GICControl defaultTextControl;
    private GICControl defaultSwitchControl;

    public ControlDefaults(Context context, int screenId) {
        SharedPreferences prefs = context.getApplicationContext().getSharedPreferences(PREFS_NAME, MODE_PRIVATE);

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
        } else if (control.getViewType() == GICControl.TYPE_BUTTON) {
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
        SharedPreferences prefs = context.getApplicationContext().getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
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
