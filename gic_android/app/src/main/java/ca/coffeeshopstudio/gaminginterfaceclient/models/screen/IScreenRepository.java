package ca.coffeeshopstudio.gaminginterfaceclient.models.screen;

import android.net.Uri;
import android.os.ParcelFileDescriptor;
import android.util.SparseArray;

import java.util.List;

import androidx.annotation.NonNull;
import ca.coffeeshopstudio.gaminginterfaceclient.views.launch.ScreenFragment;

/**
 Copyright [2019] [Terence Doerksen]

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
public interface IScreenRepository {
    void loadScreens(@NonNull LoadCallback callback);

    void newScreen(@NonNull LoadScreenCallback callback);

    void importScreen(Uri toImport, @NonNull ImportCallback callback);

    void importDefaultScreens(List<ScreenFragment.Model> toImport, @NonNull ImportCallback callback);

    void exportScreen(ParcelFileDescriptor pfd, int screenId, @NonNull ExportCallback callback);

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
