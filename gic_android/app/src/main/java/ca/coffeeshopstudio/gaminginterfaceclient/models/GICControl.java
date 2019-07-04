package ca.coffeeshopstudio.gaminginterfaceclient.models;

import android.graphics.Color;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;

import ca.coffeeshopstudio.gaminginterfaceclient.R;

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
        "command",
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
        "secondaryImage",
        "commandSecondary"
})

public class GICControl {
    public static final int TYPE_BUTTON = 0;
    public static final int TYPE_TEXT = 1;
    public static final int TYPE_IMAGE = 2;
    public static final int TYPE_SWITCH = 3;
    public static final int TYPE_BUTTON_QUICK = 4;

    //this is required for the toggle button, there are 4 stages to track:
    //0 - switched off ready for mouse down
    //1 - switched off, ready for mouse up
    //2 - switched on, ready for mouse down,
    //3 - switched on, ready for mouse up
    //after 3, we reset back to 0
    public int stage = 0;

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
    private int height = 120;
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
    private int primaryImageResource = R.drawable.button_blue;
    @JsonProperty("secondaryImageResource")
    private int secondaryImageResource = R.drawable.button_blue_dark;
    @JsonProperty("primaryImage")
    private String primaryImage = "";
    @JsonProperty("secondaryImage")
    private String secondaryImage = "";
    @JsonProperty("fontName")
    private String fontName = "";
    @JsonProperty("fontType")
    private int fontType = 0;
    @JsonProperty("commandSecondary")
    private Command commandSecondary = new Command();

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

    @JsonProperty("fontName")
    public String getFontName() {
        return fontName;
    }

    @JsonProperty("fontName")
    public void setFontName(String fontName) {
        this.fontName = fontName;
    }

    @JsonProperty("fontType")
    public int getFontType() {
        return fontType;
    }

    @JsonProperty("fontType")
    public void setFontType(int fontType) {
        this.fontType = fontType;
    }

    @JsonProperty("commandSecondary")
    public Command getCommandSecondary() {
        return commandSecondary;
    }

    @JsonProperty("commandSecondary")
    public void setCommandSecondary(Command commandSecondary) {
        this.commandSecondary = commandSecondary;
    }

}