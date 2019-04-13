package ca.coffeeshopstudio.gaminginterfaceclient.views.launch;

import android.content.Context;

import java.util.List;

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

        void showScreenList(String[] screens);

        /**
         * Displays / hides loading window
         *
         * @param show true to show, false to hide
         */
        void setProgressIndicator(boolean show);


        /**
         * What message to display to the user
         *
         * @param messageId which string resource to display
         */
        void showMessage(int messageId);

        Context getContext();
    }

    interface IViewActionListener {
        void loadScreenList();

        void importJson(List<ScreenFragment.Model> toImport);
    }
}
