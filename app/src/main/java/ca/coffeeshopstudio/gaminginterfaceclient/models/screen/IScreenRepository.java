package ca.coffeeshopstudio.gaminginterfaceclient.models.screen;

import android.util.SparseArray;

import java.util.List;

import androidx.annotation.NonNull;

/**
 * TODO: HEADER COMMENT HERE.
 */
public interface IScreenRepository {
    void loadScreens(@NonNull LoadCallback callback);

    void newScreen(@NonNull LoadScreenCallback callback);

    void importScreen(IScreen screen, @NonNull LoadScreenCallback callback);

    void importScreenSync(IScreen screen);

    void save(IScreen screen, @NonNull LoadScreenCallback callback);

    void init(@NonNull LoadCallback callback);

    void getScreen(int id, @NonNull LoadScreenCallback callback);

    IScreen getScreenSync(int id);

    void getScreenList(@NonNull final LoadScreenListCallback callback);

    void removeScreen(int id, @NonNull LoadScreenCallback callback);


    interface LoadCallback {
        void onLoaded(List<IScreen> screens);
    }

    interface LoadScreenCallback {
        void onLoaded(IScreen screen);
    }

    interface LoadScreenListCallback {
        void onLoaded(SparseArray<String> screenList);
    }
}
