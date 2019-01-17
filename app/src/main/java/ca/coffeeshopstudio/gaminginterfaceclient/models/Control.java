package ca.coffeeshopstudio.gaminginterfaceclient.models;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;

/**
 * stores our controls information for saving / loading the interface
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonPropertyOrder({
        "command",
        "modifiers",
        "text",
        "left",
        "width",
        "top",
        "height"
})
public class Control {
    @JsonProperty("command")
    private String command;
    @JsonProperty("modifiers")
    private String modifiers;
    @JsonProperty("text")
    private String text;
    @JsonProperty("left")
    private float left;
    @JsonProperty("width")
    private int width;
    @JsonProperty("top")
    private float top;
    @JsonProperty("height")
    private int height;

    @JsonProperty("command")
    public void setCommand(String command) {
        this.command = command;
    }

    @JsonProperty("command")
    public String getCommand() {
        return command;
    }

    @JsonProperty("modifiers")
    public void setModifiers(String modifiers) {
        this.modifiers = modifiers;
    }

    @JsonProperty("modifiers")
    public String getModifers() {
        return modifiers;

    }

    @JsonProperty("text")
    public void setText(String text) {
        this.text = text;
    }

    @JsonProperty("text")
    public String getText() {
        return text;

    }

    @JsonProperty("left")
    public void setLeft(float left) {
        this.left = left;
    }

    @JsonProperty("left")
    public float getLeft() {
        return left;

    }

    @JsonProperty("width")
    public void setWidth(int width) {
        this.width = width;
    }

    @JsonProperty("width")
    public int getWidth() {
        return width;

    }

    @JsonProperty("top")
    public void setTop(float top) {
        this.top = top;
    }

    @JsonProperty("top")
    public float getTop() {
        return top;

    }

    @JsonProperty("height")
    public void setHeight(int height) {
        this.height = height;
    }

    @JsonProperty("height")
    public int getHeight() {
        return height;
    }
}