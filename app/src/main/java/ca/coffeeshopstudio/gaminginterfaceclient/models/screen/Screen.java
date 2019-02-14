package ca.coffeeshopstudio.gaminginterfaceclient.models.screen;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;

import java.util.ArrayList;
import java.util.List;

import ca.coffeeshopstudio.gaminginterfaceclient.models.GICControl;

/**
 * TODO: HEADER COMMENT HERE.
 */
public class Screen implements IScreen {
    public static final int MAX_CONTROL_SIZE = 800;

    private int screenId;
    private List<GICControl> customControls = new ArrayList<>();
    private Drawable background;
    private int newId = 0;
    private int backgroundColor;
    private String backgroundPath;
    private Context context;
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
