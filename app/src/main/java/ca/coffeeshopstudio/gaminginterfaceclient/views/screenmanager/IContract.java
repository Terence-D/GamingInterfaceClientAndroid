package ca.coffeeshopstudio.gaminginterfaceclient.views.screenmanager;

import android.content.Context;
import android.util.SparseArray;

import ca.coffeeshopstudio.gaminginterfaceclient.models.screen.Screen;

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
public interface IContract {
    interface IView {
        /**
         * Our linkage back to the other half of the contract
         *
         * @param listener Action Listener
         */
        void setViewActionListener(IViewActionListener listener);

        /**
         * Display an error message
         *
         * @param errorResource which string resource to display
         */
        void showError(int errorResource);

        /**
         * What message to display to the user
         *
         * @param messageId which string resource to display
         */
        void showMessage(int messageId);

        /**
         * Displays / hides loading window
         *
         * @param show true to show, false to hide
         */
        void setProgressIndicator(boolean show);

        Context getContext();

        void updateSpinner(SparseArray<String> screenList);
    }

    interface IViewActionListener {
        void load();

        void update(int screenId, String newName);

        void delete(Screen toDelete);

        void importNew(Screen toImport);

        void exportCurrent(Screen toExport);

    }
}
