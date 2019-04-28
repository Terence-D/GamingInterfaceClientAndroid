package ca.coffeeshopstudio.gaminginterfaceclient.views.main;

import android.content.Context;
import android.util.SparseArray;

import androidx.lifecycle.ViewModel;

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
        void setPresentation(IPresentation listener);

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

        void loadIntro();

        void startApp();

        MainViewModel getViewModel();

        void updateView();

        void startGameApp();

        void displayUpgradeWarning();

        void showMessage(String message);

        void showHelpMenuIcon();
    }

    interface IPresentation {

        void checkFirstRun();

        void introResult(boolean isFirstTime);

        void saveSettings(String password, String port, String address);

        void loadSettings();

        void selectScreen(int keyAt);

        void toggleTheme();

        void checkServerVersion(String address, String port);

        void setSeenHelp();
    }
    
    class MainViewModel extends ViewModel {
        private String address;
        private String port;
        private String password;
        private SparseArray<String> screenList;
        private int startingSelectedScreen;
        private String[] screenArray;
        private boolean helpMenuIcon;

        String getAddress() {
            return address;
        }

        void setAddress(String address) {
            this.address = address;
        }

        String getPort() {
            return port;
        }

        void setPort(String port) {
            this.port = port;
        }

        String getPassword() {
            return password;
        }

        void setPassword(String password) {
            this.password = password;
        }

        SparseArray<String> getScreenList() {
            return screenList;
        }

        void setScreenList(SparseArray<String> screenList) {
            this.screenList = screenList;
        }

        void SetStartingScreenIndex(int chosenIndex) {
            this.startingSelectedScreen = chosenIndex;
        }

        int getStartingScreenIndex() {
            return startingSelectedScreen;
        }

        String[] getScreenArray() {
            return screenArray;
        }

        void setScreenArray(String[] spinnerArray) {
            this.screenArray = spinnerArray;
        }

        boolean isHelpMenuIcon() {
            return helpMenuIcon;
        }

        void setHelpMenuIcon(boolean helpMenuIcon) {
            this.helpMenuIcon = helpMenuIcon;
        }
    }
}
