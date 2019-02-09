package ca.coffeeshopstudio.gaminginterfaceclient.models;

import android.graphics.Color;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;

import ca.coffeeshopstudio.gaminginterfaceclient.R;

/**
 * stores our views information for saving / loading the interface
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonPropertyOrder({
        "command",
        "modifiers",
        "text",
        "left",
        "width",
        "top",
        "height",
        "fontColor",
        "primaryColor",
        "secondaryColor",
        "fontSize",
        "viewType",
        "primaryImageResource",
        "secondaryImageResource",
        "primaryImage",
        "secondaryImage"
})

public class GICControl {
    public static final int TYPE_BUTTON = 0;
    public static final int TYPE_TEXT = 1;
    public static final int TYPE_IMAGE = 2;

    @JsonProperty("command")
    private Command command = new Command();
    @JsonProperty("text")
    private String text = "NONE";
    @JsonProperty("left")
    private float left = 140;
    @JsonProperty("width")
    private int width = 320;
    @JsonProperty("top")
    private float top = 200;
    @JsonProperty("height")
    private int height = 240;
    @JsonProperty("fontColor")
    private int fontColor = Color.WHITE;
    @JsonProperty("primaryColor")
    private int primaryColor = -1;
    @JsonProperty("secondaryColor")
    private int secondaryColor = -1;
    @JsonProperty("fontSize")
    private int fontSize = 36;
    @JsonProperty("viewType")
    private int viewType = 0;
    @JsonProperty("primaryImageResource")
    private int primaryImageResource = R.drawable.neon_button;
    @JsonProperty("secondaryImageResource")
    private int secondaryImageResource = R.drawable.neon_button_pressed;
    @JsonProperty("primaryImage")
    private String primaryImage = "";
    @JsonProperty("secondaryImage")
    private String secondaryImage = "";

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

    @JsonProperty("fontColor")
    public int getFontColor() {
        return fontColor;
    }

    @JsonProperty("fontColor")
    public void setFontColor(int fontColor) {
        this.fontColor = fontColor;
    }

    @JsonProperty("primaryColor")
    public int getPrimaryColor() {
        return primaryColor;
    }

    @JsonProperty("primaryColor")
    public void setPrimaryColor(int primaryColor) {
        this.primaryColor = primaryColor;
    }

    @JsonProperty("secondaryColor")
    public int getSecondaryColor() {
        return secondaryColor;
    }

    @JsonProperty("secondaryColor")
    public void setSecondaryColor(int secondaryColor) {
        this.secondaryColor = secondaryColor;
    }

    @JsonProperty("fontSize")
    public int getFontSize() {
        return fontSize;
    }

    @JsonProperty("fontSize")
    public void setFontSize(int fontSize) {
        this.fontSize = fontSize;
    }

    @JsonProperty("viewType")
    public int getViewType() {
        return viewType;
    }

    @JsonProperty("viewType")
    public void setViewType(int viewType) {
        this.viewType = viewType;
    }

    @JsonProperty("primaryImageResource")
    public int getPrimaryImageResource() {
        return primaryImageResource;
    }

    @JsonProperty("primaryImageResource")
    public void setPrimaryImageResource(int primaryImageResource) {
        this.primaryImageResource = primaryImageResource;
    }

    @JsonProperty("secondaryImageResource")
    public int getSecondaryImageResource() {
        return secondaryImageResource;
    }

    @JsonProperty("secondaryImageResource")
    public void setSecondaryImageResource(int secondaryImageResource) {
        this.secondaryImageResource = secondaryImageResource;
    }

    @JsonProperty("primaryImage")
    public String getPrimaryImage() {
        return primaryImage;
    }

    @JsonProperty("primaryImage")
    public void setPrimaryImage(String primaryImage) {
        this.primaryImage = primaryImage;
    }

    @JsonProperty("secondaryImage")
    public String getSecondaryImage() {
        return secondaryImage;
    }

    @JsonProperty("secondaryImage")
    public void setSecondaryImage(String secondaryImage) {
        this.secondaryImage = secondaryImage;
    }
}