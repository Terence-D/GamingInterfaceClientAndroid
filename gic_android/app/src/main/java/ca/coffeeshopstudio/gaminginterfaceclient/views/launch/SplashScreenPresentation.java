package ca.coffeeshopstudio.gaminginterfaceclient.views.launch;

import android.util.SparseArray;

import java.util.List;

import androidx.annotation.NonNull;
import ca.coffeeshopstudio.gaminginterfaceclient.R;
import ca.coffeeshopstudio.gaminginterfaceclient.models.screen.IScreenRepository;

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
public class SplashScreenPresentation implements IContract.IPresentation {
    IContract.IView view;
    IScreenRepository repository;

    SplashScreenPresentation(IContract.IView view,
                             @NonNull IScreenRepository repository) {
        this.view = view;
        this.repository = repository;
    }

    @Override
    public void loadScreenList() {
        String[] screenList = view.getContext().getResources().getStringArray(R.array.defaultScreens);
        view.showScreenList(screenList);
    }

    @Override
    public void importJson(List<ScreenFragment.Model> toImport) {
        view.setProgressIndicator(true);
        repository.importDefaultScreens(toImport, new IScreenRepository.ImportCallback() {
            @Override
            public void onFinished(Boolean result, SparseArray<String> screenList) {
                if (result) {
                    view.showMessage(R.string.slideScreenSuccess);
                }
                view.setProgressIndicator(false);
            }
        });
    }
}
