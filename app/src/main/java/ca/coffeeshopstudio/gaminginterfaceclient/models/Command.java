package ca.coffeeshopstudio.gaminginterfaceclient.models;

import com.google.gson.annotations.SerializedName;

import java.util.ArrayList;
import java.util.List;

/**
 * TODO: HEADER COMMENT HERE.
 */
public class Command {
    @SerializedName("Key")
    private String key = "a";
    @SerializedName("Modifier")
    private List<String> modifiers = new ArrayList<>();

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
}
