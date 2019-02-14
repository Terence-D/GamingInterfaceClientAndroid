package ca.coffeeshopstudio.gaminginterfaceclient.views.screenmanager;

import android.support.annotation.NonNull;
import android.util.SparseArray;

import java.util.List;

import ca.coffeeshopstudio.gaminginterfaceclient.models.screen.IScreen;
import ca.coffeeshopstudio.gaminginterfaceclient.models.screen.IScreenRepository;
import ca.coffeeshopstudio.gaminginterfaceclient.models.screen.Screen;

/**
 * TODO: HEADER COMMENT HERE.
 */
public class Presentation implements IContract.IViewActionListener, IScreenRepository.LoadCallback, IScreenRepository.LoadScreenListCallback {
    private final IContract.IView view;
    private final IScreenRepository repository;

    /**
     * Public constructor to link up our repository and our view via this presenter
     *
     * @param repository Repository to connect to
     * @param detailView view to connect to
     */
    public Presentation(@NonNull IScreenRepository repository,
                        @NonNull IContract.IView detailView) {
        this.repository = repository;//checkNotNull(repository, "repository cannot be null!");
        this.view = detailView;// checkNotNull(detailView, "detail view cannot be null!");
    }


    @Override
    public void load() {
        view.setProgressIndicator(true);
        repository.loadScreens(this);
    }

    @Override
    public void update(int screenId, String newName) {
        repository.getScreen(screenId).setName(newName);
        repository.save(repository.getScreen(screenId));
    }

    @Override
    public void delete(Screen toDelete) {

    }

    @Override
    public void importNew(Screen toImport) {

    }

    @Override
    public void exportCurrent(Screen toExport) {

    }

    @Override
    public void onLoaded(List<IScreen> screens) {
        repository.getScreenList(this);
    }

    @Override
    public void onLoaded(SparseArray<String> screenList) {
        view.updateSpinner(screenList);
        view.setProgressIndicator(false);
    }
}
