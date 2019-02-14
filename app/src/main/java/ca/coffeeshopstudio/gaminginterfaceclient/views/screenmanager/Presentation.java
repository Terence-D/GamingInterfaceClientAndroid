package ca.coffeeshopstudio.gaminginterfaceclient.views.screenmanager;

import android.os.AsyncTask;
import android.os.Environment;
import android.support.annotation.NonNull;
import android.util.SparseArray;

import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.Writer;
import java.lang.ref.WeakReference;
import java.util.List;

import ca.coffeeshopstudio.gaminginterfaceclient.R;
import ca.coffeeshopstudio.gaminginterfaceclient.models.screen.IScreen;
import ca.coffeeshopstudio.gaminginterfaceclient.models.screen.IScreenRepository;
import ca.coffeeshopstudio.gaminginterfaceclient.models.screen.Screen;

/**
 * TODO: HEADER COMMENT HERE.
 */
public class Presentation implements IContract.IViewActionListener, IScreenRepository.LoadCallback, IScreenRepository.LoadScreenListCallback {
    final IContract.IView view;
    final IScreenRepository repository;

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
    public void exportCurrent(int screenId) {
        view.setProgressIndicator(true);
        new ExportTask(this).execute(screenId);
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

    private static class ExportTask extends AsyncTask<Integer, Void, Void> {

        private WeakReference<Presentation> myReference;

        ExportTask(Presentation presentation) {
            myReference = new WeakReference<>(presentation);
        }

        @Override
        protected Void doInBackground(Integer... params) {
            ObjectMapper mapper = new ObjectMapper();
            try {
                Screen screen = (Screen) myReference.get().repository.getScreen(params[0]);
                String json = mapper.writeValueAsString(screen);
                Writer output;
                File file = new File(Environment.getExternalStorageDirectory() + "/test.json");
                output = new BufferedWriter(new FileWriter(file));
                output.write(json);
                output.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
            return null;
        }

        @Override
        protected void onPostExecute(Void results) {
            myReference.get().view.setProgressIndicator(false);
            myReference.get().view.showMessage(R.string.export_complete);
        }
    }

}
