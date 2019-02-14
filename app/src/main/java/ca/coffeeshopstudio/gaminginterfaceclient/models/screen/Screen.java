package ca.coffeeshopstudio.gaminginterfaceclient.models.screen;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import com.fasterxml.jackson.annotation.JsonUnwrapped;

import java.util.ArrayList;
import java.util.List;

import ca.coffeeshopstudio.gaminginterfaceclient.models.GICControl;

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
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonPropertyOrder({
        "screenId",
        "name",
        "controls",
        "backgroundColor",
        "backgroundPath",
})
public class Screen implements IScreen {
    public static final int MAX_CONTROL_SIZE = 800;

    @JsonProperty("screenId")
    private int screenId;
    @JsonProperty("controls")
    @JsonUnwrapped
    private List<GICControl> customControls = new ArrayList<>();
    @JsonIgnore
    private Drawable background;
    private int newId = 0;
    @JsonProperty("backgroundColor")
    private int backgroundColor;
    @JsonProperty("backgroundPath")
    private String backgroundPath;
    @JsonIgnore
    private Context context;
    @JsonProperty("name")
    private String name;

    public Screen(int screenId, Context context) {
        this.screenId = screenId;
        this.context = context;
    }

    @Override
    public Drawable getBackground() {
        loadBackground();
        return background;
    }

    @Override
    public void setBackground(Drawable background) {
        if (background != null)
            this.background = background;
    }

    @Override
    public void setBackgroundColor(int backgroundColor) {
        this.backgroundColor = backgroundColor;
    }

    @Override
    public void setBackgroundFile(String backgroundPath) {
        this.backgroundPath = backgroundPath;
    }

    @Override
    public Drawable getImage(String fileName) {
        if (fileName.startsWith(screenId + "_control")) {
            Bitmap bitmap = BitmapFactory.decodeFile(context.getFilesDir() + "/" + fileName);
            Drawable bitmapDrawable = new BitmapDrawable(context.getResources(), bitmap);
            return bitmapDrawable;
        }
        return null;
    }

    @Override
    public void addControl(GICControl control) {
        customControls.add(control);
    }

    @Override
    public int getNewControlId() {
        newId++;
        return newId - 1;
    }

    @Override
    public List<GICControl> getControls() {
        return customControls;
    }

    @Override
    public String getName() {
        if (name == null)
            return "Screen" + getScreenId();
        return name;
    }

    @Override
    public void setName(String newName) {
        name = newName;
    }

    @Override
    public int getScreenId() {
        return screenId;
    }

    @Override
    public void removeControl(GICControl control) {
        customControls.remove(control);
    }

    private void loadBackground() {
        if (backgroundColor == -1) {
            Bitmap bitmap = BitmapFactory.decodeFile(context.getFilesDir() + "/" + backgroundPath);
            Drawable bitmapDrawable = new BitmapDrawable(context.getResources(), bitmap);
            background = bitmapDrawable;
        } else {
            ColorDrawable color = new ColorDrawable();
            color.setColor(backgroundColor);
            background = color;
        }

    }
}
