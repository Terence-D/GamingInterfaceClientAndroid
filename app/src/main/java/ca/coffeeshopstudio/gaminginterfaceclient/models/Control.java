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
    private Command command;
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
    public Command getCommand() {
        return command;
    }

    @JsonProperty("command")
    public void setCommand(Command command) {
        this.command = command;
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