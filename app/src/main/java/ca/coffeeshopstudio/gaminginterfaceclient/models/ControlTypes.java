package ca.coffeeshopstudio.gaminginterfaceclient.models;

import android.content.Context;

import java.util.ArrayList;
import java.util.List;

import ca.coffeeshopstudio.gaminginterfaceclient.R;

/**
 * Copyright [2019] [Terence Doerksen]
 * <p>
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * <p>
 * http://www.apache.org/licenses/LICENSE-2.0
 * <p>
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
public class ControlTypes {
    private List<String> controls = new ArrayList<>();

    public ControlTypes(Context context) {
        controls.add(context.getString(R.string.control_type_button));
        controls.add(context.getString(R.string.control_type_text));
        controls.add(context.getString(R.string.control_type_image));
        controls.add(context.getString(R.string.control_type_switch));
    }

    public String[] getStringValues() {
        String[] array = new String[controls.size()];
        return controls.toArray(array);
    }

    public String getValue(int index) {
        if (index < controls.size() && index >= 0)
            return controls.get(index);
        else
            return "";
    }

    static final int[] Buttons = new int[]{
            R.drawable.button_neon,
            R.drawable.button_neon_dark,
            R.drawable.button_blue,
            R.drawable.button_blue_dark,
            R.drawable.button_green,
            R.drawable.button_green_dark,
            R.drawable.button_green2,
            R.drawable.button_green2_dark,
            R.drawable.button_purple,
            R.drawable.button_purple_dark,
            R.drawable.button_red,
            R.drawable.button_red_dark,
            R.drawable.button_yellow,
            R.drawable.button_yellow_dark,
            R.drawable.button_black,
            R.drawable.button_black_dark,
            R.drawable.button_black2,
            R.drawable.button_black2_dark,
            R.drawable.button_blue2,
            R.drawable.button_blue2_dark,
            R.drawable.button_grey,
            R.drawable.button_grey_dark,
            R.drawable.button_grey2,
            R.drawable.button_grey2_dark,
            R.drawable.button_red2,
            R.drawable.button_red2_dark,
            R.drawable.button_white,
            R.drawable.button_white_dark,
    };
    static final int[] Toggles = new int[]{
            R.drawable.switch_off,
            R.drawable.switch_on,
            R.drawable.toggle_off,
            R.drawable.toggle_on
    };

    public static int GetSwitchDrawableId(int resourceId, boolean primary) {
        switch (resourceId) {
            case 0:
                return R.drawable.switch_off;
            case 1:
                return R.drawable.switch_on;
            case 2:
                return R.drawable.toggle_off;
            case 3:
                return R.drawable.toggle_on;
            default:
                if (primary)
                    return R.drawable.toggle_off;
                else
                    return R.drawable.toggle_on;
        }
    }

    public static int GetSwitchByResourceId(int resourceId) {
        switch (resourceId) {
            case R.drawable.switch_off:
                return 0;
            case R.drawable.switch_on:
                return 1;
            case R.drawable.toggle_off:
                return 2;
            case R.drawable.toggle_on:
                return 3;
        }
        return 0;
    }

    public static int GetButtonDrawableId(int index, boolean primary) {
        switch (index) {
            case 0:
                return R.drawable.button_neon;
            case 1:
                return R.drawable.button_neon_dark;
            case 2:
                return R.drawable.button_blue;
            case 3:
                return R.drawable.button_blue_dark;
            case 4:
                return R.drawable.button_green;
            case 5:
                return R.drawable.button_green_dark;
            case 6:
                return R.drawable.button_green2;
            case 7:
                return R.drawable.button_green2_dark;
            case 8:
                return R.drawable.button_purple;
            case 9:
                return R.drawable.button_purple_dark;
            case 10:
                return R.drawable.button_red;
            case 11:
                return R.drawable.button_red_dark;
            case 12:
                return R.drawable.button_yellow;
            case 13:
                return R.drawable.button_yellow_dark;
            case 14:
                return R.drawable.button_black;
            case 15:
                return R.drawable.button_black_dark;
            case 16:
                return R.drawable.button_black2;
            case 17:
                return R.drawable.button_black2_dark;
            case 18:
                return R.drawable.button_blue2;
            case 19:
                return R.drawable.button_blue2_dark;
            case 20:
                return R.drawable.button_grey;
            case 21:
                return R.drawable.button_grey_dark;
            case 22:
                return R.drawable.button_grey2;
            case 23:
                return R.drawable.button_grey2_dark;
            case 24:
                return R.drawable.button_red2;
            case 25:
                return R.drawable.button_red2_dark;
            case 26:
                return R.drawable.button_white;
            case 27:
                return R.drawable.button_white_dark;
            default:
                if (primary)
                    return R.drawable.button_blue;
                else
                    return R.drawable.button_blue_dark;
        }
    }

    public static int GetButtonByResourceId(int index) {
        switch (index) {
            case R.drawable.button_neon:
                return 0;
            case R.drawable.button_neon_dark:
                return 1;
            case R.drawable.button_blue:
                return 2;
            case R.drawable.button_blue_dark:
                return 3;
            case R.drawable.button_green:
                return 4;
            case R.drawable.button_green_dark:
                return 5;
            case R.drawable.button_green2:
                return 6;
            case R.drawable.button_green2_dark:
                return 7;
            case R.drawable.button_purple:
                return 8;
            case R.drawable.button_purple_dark:
                return 9;
            case R.drawable.button_red:
                return 10;
            case R.drawable.button_red_dark:
                return 11;
            case R.drawable.button_yellow:
                return 12;
            case R.drawable.button_yellow_dark:
                return 13;
            case R.drawable.button_black:
                return 14;
            case R.drawable.button_black_dark:
                return 15;
            case R.drawable.button_black2:
                return 16;
            case R.drawable.button_black2_dark:
                return 17;
            case R.drawable.button_blue2:
                return 18;
            case R.drawable.button_blue2_dark:
                return 19;
            case R.drawable.button_grey:
                return 20;
            case R.drawable.button_grey_dark:
                return 21;
            case R.drawable.button_grey2:
                return 22;
            case R.drawable.button_grey2_dark:
                return 23;
            case R.drawable.button_red2:
                return 24;
            case R.drawable.button_red2_dark:
                return 25;
            case R.drawable.button_white:
                return 26;
            case R.drawable.button_white_dark:
                return 27;
            default:
                return 0;
        }
    }
}