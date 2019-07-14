package ca.coffeeshopstudio.gaminginterfaceclient.models;

import com.google.gson.annotations.SerializedName;

import java.util.ArrayList;
import java.util.List;

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
