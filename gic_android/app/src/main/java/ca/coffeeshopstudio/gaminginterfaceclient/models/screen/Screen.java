package ca.coffeeshopstudio.gaminginterfaceclient.models.screen;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;

import com.fasterxml.jackson.annotation.JsonCreator;
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
        "newControlId"
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
    @JsonProperty("newControlId")
    private int newId = 0;
    @JsonProperty("backgroundColor")
    private int backgroundColor;
    @JsonProperty("backgroundPath")
    private String backgroundPath;
    @JsonIgnore
    private Context context;
    @JsonProperty("name")
    private String name;

    @JsonCreator
    public Screen(@JsonProperty("screenId") int screenId,
                  @JsonProperty("controls") List<GICControl> controls,
                  @JsonProperty("backgroundColor") int backgroundColor,
                  @JsonProperty("backgroundPath") String backgroundPath,
                  @JsonProperty("newControlId") int newId,
                  @JsonProperty("name") String name) {
        this.screenId = screenId;
        this.customControls = controls;
        this.backgroundColor = backgroundColor;
        this.backgroundPath = backgroundPath;
        this.name = name;
        this.newId = newId;
    }

    public Screen(int screenId, Context context) {
        this.screenId = screenId;
        this.context = context;
    }

    @Override
    public Drawable getBackground() {
        if (backgroundPath.isEmpty()) {
            //load a color
            ColorDrawable color = new ColorDrawable();
            color.setColor(backgroundColor);
            background = color;
        } else {
            //load an image
            Bitmap bitmap = BitmapFactory.decodeFile(backgroundPath);
            if (bitmap == null) {
                background = new ColorDrawable(Color.BLACK);
            } else {
                Drawable bitmapDrawable = new BitmapDrawable(context.getResources(), bitmap);
                background = bitmapDrawable;
            }
        }

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
    public int getBackgroundColor() {
        return backgroundColor;
    }

    @Override
    public void setBackgroundFile(String backgroundPath) {
        this.backgroundPath = backgroundPath;
    }

    @Override
    public String getBackgroundFile() {
        return backgroundPath;
    }

    @Override
    public Drawable getImage(String fileName) {
//        if (fileName.contains(screenId + "_control")) {
            Bitmap bitmap = BitmapFactory.decodeFile(fileName);
            Drawable bitmapDrawable = new BitmapDrawable(context.getResources(), bitmap);
            return bitmapDrawable;
//        }
        //return null;
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
    public void setScreenId(int newId) {
        this.screenId = newId;
    }

    @Override
    public void removeControl(GICControl control) {
        customControls.remove(control);
    }
}
