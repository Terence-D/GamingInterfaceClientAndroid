package ca.coffeeshopstudio.gaminginterfaceclient.models;

import android.content.Context;
import android.content.SharedPreferences;
import android.support.v7.widget.AppCompatTextView;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
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
    private Control defaultImageControl;
    private Control defaultButtonControl;
    private Control defaultTextControl;

    public ControlDefaults(Context context, int screenId) {
        SharedPreferences prefs = context.getApplicationContext().getSharedPreferences(PREFS_NAME, MODE_PRIVATE);

        String prefString = screenId + "_image_defaults";
        defaultImageControl = loadControl(context, prefs, prefString);
        prefString = screenId + "_button_defaults";
        defaultButtonControl = loadControl(context, prefs, prefString);
        prefString = screenId + "_text_defaults";
        defaultTextControl = loadControl(context, prefs, prefString);
    }

    public Control getImageDefaults() {
        return defaultImageControl;
    }

    public Control getButtonDefaults() {
        return defaultButtonControl;
    }

    public Control getTextDefaults() {
        return defaultTextControl;
    }

    public void saveControl(View view) {
        if (view instanceof AppCompatTextView) {
            defaultTextControl.setWidth(view.getWidth());
            defaultTextControl.setHeight(view.getHeight());
            defaultTextControl.setFontColor(((AppCompatTextView) view).getCurrentTextColor());
        } else if (view instanceof Button) {
            defaultButtonControl.setWidth(view.getWidth());
            defaultButtonControl.setHeight(view.getHeight());
            defaultButtonControl.setFontColor(((Button) view).getCurrentTextColor());
            defaultButtonControl.setFontSize((int) ((Button) view).getTextSize());
        } else if (view instanceof ImageView) {
            defaultImageControl.setWidth(view.getWidth());
            defaultImageControl.setHeight(view.getHeight());
        }
    }

    public void saveControl(View view, int primaryColor, int secondaryColor) {
        saveControl(view);
        if (view instanceof Button) {
            defaultButtonControl.setPrimaryColor(primaryColor);
            defaultButtonControl.setSecondaryColor(secondaryColor);
        }
    }

    private Control loadControl(Context context, SharedPreferences prefs, String prefString) {
        Control defaultControl = new Control();
        final ObjectMapper mapper = new ObjectMapper();
        if (prefs.contains(prefString)) {
            String raw = prefs.getString(prefString, "");
            if (raw != null && !raw.isEmpty()) {
                try {
                    defaultControl = mapper.readValue(raw, Control.class);
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
        } catch (JsonProcessingException e) {
            e.printStackTrace();
            Toast.makeText(context, e.getLocalizedMessage(), Toast.LENGTH_LONG).show();
        }

        prefsEditor.apply();
    }
}
