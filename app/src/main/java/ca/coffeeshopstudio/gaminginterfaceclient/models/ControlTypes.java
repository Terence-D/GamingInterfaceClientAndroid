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
}
