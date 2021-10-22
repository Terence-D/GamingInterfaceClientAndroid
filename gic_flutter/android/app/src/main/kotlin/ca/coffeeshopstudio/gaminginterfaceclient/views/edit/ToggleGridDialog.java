package ca.coffeeshopstudio.gaminginterfaceclient.views.edit;

import androidx.fragment.app.Fragment;
import ca.coffeeshopstudio.gaminginterfaceclient.models.AbstractAdapter;

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
class ToggleGridDialog extends AbstractGridDialog {

    ToggleGridDialog(Fragment fragment, AbstractAdapter adapter) {
        super(fragment, adapter);
    }

    @Override
    public void init () {
        setImagePrefix("switch");
        setActionRequestCode(EditActivity.OPEN_REQUEST_CODE_IMPORT_SWITCH);
    }
}
