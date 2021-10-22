package ca.coffeeshopstudio.gaminginterfaceclient.models.screen;

import android.graphics.drawable.Drawable;

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
public interface IScreen {
    String getName();

    void setName(String newName);

    int getScreenId();

    String getBackgroundFile();

    Drawable getImage(String filename);

    void addControl(GICControl control);

    int getNewControlId();

    List<GICControl> getControls();

    void setScreenId(int newId);

    void removeControl(GICControl control);

    Drawable getBackground();

    void setBackground(Drawable background);

    void setBackgroundColor(int backgroundColor);

    int getBackgroundColor();

    void setBackgroundFile(String backgroundPath);

}
