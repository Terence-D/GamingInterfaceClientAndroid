package ca.coffeeshopstudio.gaminginterfaceclient.models.screen;

import android.util.SparseArray;

import java.util.List;

import androidx.annotation.NonNull;

/**
 * TODO: HEADER COMMENT HERE.
 */
public interface IScreenRepository {
    void loadScreens(@NonNull final LoadCallback callback);

    void loadScreens();

    Screen newScreen();

    void importScreen(IScreen screen);

    void save(IScreen screen);

    IScreen getScreen(int id);

    //this is used by the main screen
    //IScreen getScreenByPosition(int index);

    void getScreenList(@NonNull final LoadScreenListCallback callback);

    void removeScreen(int id);


    interface LoadCallback {
        void onLoaded(List<IScreen> screens);
    }

    interface LoadScreenListCallback {
        void onLoaded(SparseArray<String> screenList);
    }
}
