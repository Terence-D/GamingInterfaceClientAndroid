package ca.coffeeshopstudio.gaminginterfaceclient.models.screen;

import android.graphics.drawable.Drawable;
import android.support.annotation.NonNull;
import android.util.SparseArray;

import java.util.List;

/**
 * TODO: HEADER COMMENT HERE.
 */
public interface IScreenRepository {
    void loadScreens(@NonNull final LoadCallback callback);

    Screen newScreen();

    void save(IScreen screen, Drawable drawable);

    IScreen getScreen(int id);

    void getScreenList(@NonNull final LoadScreenListCallback callback);

    void removeScreen(int id);

    interface LoadCallback {
        void onLoaded(List<IScreen> screens);
    }

    interface LoadScreenListCallback {
        void onLoaded(SparseArray<String> screenList);
    }
}
