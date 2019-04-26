package ca.coffeeshopstudio.gaminginterfaceclient.models.screen;

import android.net.Uri;
import android.util.SparseArray;

import java.util.List;

import androidx.annotation.NonNull;
import ca.coffeeshopstudio.gaminginterfaceclient.views.launch.ScreenFragment;

/**
 * TODO: HEADER COMMENT HERE.
 */
public interface IScreenRepository {
    void loadScreens(@NonNull LoadCallback callback);

    void newScreen(@NonNull LoadScreenCallback callback);

    void importScreen(Uri toImport, @NonNull ImportCallback callback);

    void importDefaultScreens(List<ScreenFragment.Model> toImport, @NonNull ImportCallback callback);

    void exportScreen(int screenId, @NonNull ExportCallback callback);

    void save(IScreen screen, @NonNull LoadScreenCallback callback);

    void init(@NonNull LoadCallback callback);

    void getScreen(int id, @NonNull LoadScreenCallback callback);

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

    interface ImportCallback {
        void onFinished(Boolean result, SparseArray<String> screenList);
    }

    interface ExportCallback {
        void onFinished(String zipFile);
    }
}
