package ca.coffeeshopstudio.gaminginterfaceclient.views.screenmanager;

import android.net.Uri;
import android.util.SparseArray;

import java.util.List;

import androidx.annotation.NonNull;
import ca.coffeeshopstudio.gaminginterfaceclient.R;
import ca.coffeeshopstudio.gaminginterfaceclient.models.screen.IScreen;
import ca.coffeeshopstudio.gaminginterfaceclient.models.screen.IScreenRepository;

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
public class ScreenManagerPresentation implements IContract.IPresentation {
    final IContract.IView view;
    final IScreenRepository repository;

    /**
     * Public constructor to link up our repository and our view via this presenter
     *
     * @param repository Repository to connect to
     * @param detailView view to connect to
     */
    public ScreenManagerPresentation(@NonNull IScreenRepository repository,
                                     @NonNull IContract.IView detailView) {
        this.repository = repository;//checkNotNull(repository, "repository cannot be null!");
        this.view = detailView;// checkNotNull(detailView, "detail view cannot be null!");
    }


    @Override
    public void load() {
        view.setProgressIndicator(true);
        repository.loadScreens(new IScreenRepository.LoadCallback() {
            @Override
            public void onLoaded(List<IScreen> screens) {
                repository.getScreenList(new IScreenRepository.LoadScreenListCallback() {
                    @Override
                    public void onLoaded(SparseArray<String> screenList) {
                        view.updateSpinner(screenList);
                        view.setProgressIndicator(false);
                    }
                });
            }
        });
    }

    @Override
    public void update(final int screenId, final String newName) {
        view.setProgressIndicator(true);

        repository.getScreen(screenId, new IScreenRepository.LoadScreenCallback() {
            @Override
            public void onLoaded(IScreen screen) {
                screen.setName(newName);
                repository.save(screen, new IScreenRepository.LoadScreenCallback() {
                    @Override
                    public void onLoaded(IScreen screen) {
                        repository.getScreenList(new IScreenRepository.LoadScreenListCallback() {
                            @Override
                            public void onLoaded(SparseArray<String> screenList) {
                                view.updateSpinner(screenList);
                                view.setSpinnerSelection(screenId);
                                view.setProgressIndicator(false);
                            }
                        });
                    }
                });
            }
        });
    }

    @Override
    public void delete(final int toDelete) {
        final IContract.IView view = this.view;
        repository.getScreenList(new IScreenRepository.LoadScreenListCallback() {
            @Override
            public void onLoaded(SparseArray<String> screenList) {
                if (screenList.size() <= 1) {
                    view.showError(R.string.cannot_delete_last_item);
                } else {
                    view.setProgressIndicator(true);
                    repository.removeScreen(toDelete, new IScreenRepository.LoadScreenCallback() {
                        @Override
                        public void onLoaded(IScreen screen) {
                            repository.getScreenList(new IScreenRepository.LoadScreenListCallback() {
                                @Override
                                public void onLoaded(SparseArray<String> screenList) {
                                    view.updateSpinner(screenList);
                                    view.setProgressIndicator(false);
                                    view.setSpinnerSelection(0);
                                }
                            });
                        }
                    });
                }
            }
        });
    }

    @Override
    public void importNew(Uri toImport) {
        view.setProgressIndicator(true);
        repository.importScreen(toImport, new IScreenRepository.ImportCallback() {
            @Override
            public void onFinished(Boolean result, SparseArray<String> screenList) {
                view.updateSpinner(screenList);
                view.setProgressIndicator(false);
                if (result)
                    view.showMessage(R.string.import_successful);
                else
                    view.showError(R.string.invalid_zip);
            }
        });
    }

    @Override
    public void exportCurrent(int screenId) {
        view.setProgressIndicator(true);
        repository.exportScreen(screenId, new IScreenRepository.ExportCallback() {
            @Override
            public void onFinished(String message) {
                view.setProgressIndicator(false);
                view.showMessage(message);
            }
        });
    }

    @Override
    public void create() {
        view.setProgressIndicator(true);
        repository.newScreen(new IScreenRepository.LoadScreenCallback() {
            @Override
            public void onLoaded(IScreen screen) {
                repository.getScreenList(new IScreenRepository.LoadScreenListCallback() {
                    @Override
                    public void onLoaded(SparseArray<String> screenList) {
                        view.updateSpinner(screenList);
                        view.setProgressIndicator(false);
                        view.setSpinnerSelection(screenList.size() - 1);
                }
            });
            }
        });
    }
}
