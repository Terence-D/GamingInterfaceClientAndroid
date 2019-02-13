package ca.coffeeshopstudio.gaminginterfaceclient.models;

import com.google.gson.annotations.SerializedName;

import java.util.ArrayList;
import java.util.List;

/**
 * TODO: HEADER COMMENT HERE.
 */
public class Command {
    public static final int KEY_DOWN = 0;
    public static final int KEY_UP = 1;
    @SerializedName("Key")
    private String key = "a";
    @SerializedName("Modifier")
    private List<String> modifiers = new ArrayList<>();
    @SerializedName("ActivatorType")
    private int activatorType; //key down, key up, etc

    public void addModifier(String modifier) {
        modifiers.add(modifier);
    }

    public String getKey() {
        return key;
    }

    public void setKey(String key) {
        this.key = key;
    }

    public List<String> getModifiers() {
        return modifiers;
    }

    public int getActivatorType() {
        return activatorType;
    }

    public void setActivatorType(int activatorType) {
        this.activatorType = activatorType;
    }

    public void removeAllModifiers() {
        modifiers = new ArrayList<>();
    }
}
