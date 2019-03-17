package ca.coffeeshopstudio.gaminginterfaceclient.views.screenmanager;

import android.net.Uri;
import android.os.AsyncTask;
import android.os.Environment;
import android.support.annotation.NonNull;
import android.util.SparseArray;

import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.Writer;
import java.lang.ref.WeakReference;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import ca.coffeeshopstudio.gaminginterfaceclient.R;
import ca.coffeeshopstudio.gaminginterfaceclient.models.GICControl;
import ca.coffeeshopstudio.gaminginterfaceclient.models.screen.IScreen;
import ca.coffeeshopstudio.gaminginterfaceclient.models.screen.IScreenRepository;
import ca.coffeeshopstudio.gaminginterfaceclient.models.screen.Screen;
import ca.coffeeshopstudio.gaminginterfaceclient.utils.ZipHelper;

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
        view.setProgressIndicator(true);
        UpdateTask task = new UpdateTask(view, repository, screenId, newName);
        task.execute();
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
                    DeleteTask task = new DeleteTask(repository, view, toDelete);
                    task.execute();
                }
            }
        });
    }

    @Override
    public void importNew(Uri toImport) {
        view.setProgressIndicator(true);
        new ImportTask(this).execute(toImport);
    }

    @Override
    public void exportCurrent(int screenId) {
        view.setProgressIndicator(true);
        new ExportTask(this).execute(screenId);
    }

    @Override
    public void create() {
        view.setProgressIndicator(true);
        CreateTask task = new CreateTask(repository, this);
        task.execute();
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

    private static class CreateTask extends AsyncTask<Void, Void, Void> {
        private final IScreenRepository repository;
        private final Presentation presentation;

        public CreateTask(IScreenRepository repository, Presentation presentation) {
            this.repository = repository;
            this.presentation = presentation;
        }

        @Override
        protected Void doInBackground(Void... values) {
            repository.newScreen();
            return null;
        }

        @Override
        protected void onPostExecute(Void results) {
            repository.getScreenList(new IScreenRepository.LoadScreenListCallback() {
                @Override
                public void onLoaded(SparseArray<String> screenList) {
                    presentation.view.updateSpinner(screenList);
                    presentation.view.setProgressIndicator(false);
                    presentation.view.setSpinnerSelection(screenList.size() - 1);
                }
            });
        }
    }

    private static class DeleteTask extends AsyncTask<Void, Void, Void> {
        private final IScreenRepository repository;
        private final IContract.IView view;
        private final int screenId;

        public DeleteTask(IScreenRepository repository, IContract.IView view, int screenId) {
            this.repository = repository;
            this.view = view;
            this.screenId = screenId;
        }

        @Override
        protected Void doInBackground(Void... values) {
            repository.removeScreen(screenId);
            return null;
        }

        @Override
        protected void onPostExecute(Void results) {
            repository.getScreenList(new IScreenRepository.LoadScreenListCallback() {
                @Override
                public void onLoaded(SparseArray<String> screenList) {
                    view.updateSpinner(screenList);
                    view.setProgressIndicator(false);
                    view.setSpinnerSelection(0);
                }
            });
        }
    }

    private static class ImportTask extends AsyncTask<Uri, Void, String> {
        private WeakReference<Presentation> presentationWeakReference;

        ImportTask(Presentation presentation) {
            presentationWeakReference = new WeakReference<>(presentation);
        }

        @Override
        protected String doInBackground(Uri... params) {
            try {
                Uri toImport = params[0];
                InputStream stream = presentationWeakReference.get().view.getContext().getContentResolver().openInputStream(toImport);
                //get a profile name
                String path = toImport.getLastPathSegment();
                path = path.replace("primary:", "");
                path = path.replace(".zip", "");
                boolean valid = ZipHelper.unzip(stream, Environment.getExternalStorageDirectory() + "/GIC-Screens/" + path);

                //now read the json values
                if (valid)
                    parseJson(Environment.getExternalStorageDirectory() + "/GIC-Screens/" + path + "/");
                else
                    return presentationWeakReference.get().view.getContext().getString(R.string.invalid_zip);
            } catch (IOException e) {
                return e.getMessage();
            }
            return presentationWeakReference.get().view.getContext().getString(R.string.import_successful);
        }

        @Override
        protected void onPostExecute(final String results) {
            presentationWeakReference.get().repository.getScreenList(new IScreenRepository.LoadScreenListCallback() {
                @Override
                public void onLoaded(SparseArray<String> screenList) {
                    presentationWeakReference.get().view.updateSpinner(screenList);
                    presentationWeakReference.get().view.setProgressIndicator(false);
                    presentationWeakReference.get().view.showMessage(results);
                }
            });
        }

        private void parseJson(String fullPath) {
            ObjectMapper objectMapper = new ObjectMapper();
            File file = new File(fullPath + "data.json");
            try {
                Screen screen = objectMapper.readValue(file, Screen.class);
                //update any filenames to point to the local folder now
                if (!screen.getBackgroundFile().isEmpty()) {
                    int index = screen.getBackgroundFile().lastIndexOf("/");
                    screen.setBackgroundFile(fullPath + screen.getBackgroundFile().substring(index + 1));
                }
                for (GICControl control : screen.getControls()) {
                    if (!control.getPrimaryImage().isEmpty()) {
                        int index = control.getPrimaryImage().lastIndexOf("/");
                        control.setPrimaryImage(fullPath + control.getPrimaryImage().substring(index + 1));
                    }
                    if (!control.getSecondaryImage().isEmpty()) {
                        int index = control.getSecondaryImage().lastIndexOf("/");
                        control.setSecondaryImage(fullPath + control.getSecondaryImage().substring(index + 1));
                    }
                }
                presentationWeakReference.get().repository.importScreen(screen);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
    private static class ExportTask extends AsyncTask<Integer, Void, String> {
        private WeakReference<Presentation> presentationWeakReference;
        ExportTask(Presentation presentation) {
            presentationWeakReference = new WeakReference<>(presentation);
        }
        @Override
        protected String doInBackground(Integer... params) {
            ObjectMapper mapper = new ObjectMapper();
            try {
                Set<String> filesToZip = new HashSet<>();

                Screen screen = (Screen) presentationWeakReference.get().repository.getScreen(params[0]);
                String json = mapper.writeValueAsString(screen);
                Writer output;
                File cacheDir = new File(presentationWeakReference.get().view.getContext().getCacheDir().getAbsolutePath());

                //store the json dat in the directory
                File jsonData = new File(cacheDir.getAbsolutePath() + "/data.json");
                output = new BufferedWriter(new FileWriter(jsonData));
                output.write(json);
                output.close();

                filesToZip.add(jsonData.getAbsolutePath());

                //look for any files inside the screen that we need to add
                if (screen.getBackgroundFile() != null && !screen.getBackgroundFile().isEmpty()) {
                    filesToZip.add(screen.getBackgroundFile());
                }
                for (GICControl control : screen.getControls()) {
                    if (!control.getPrimaryImage().isEmpty()) {
                        filesToZip.add(control.getPrimaryImage());
                    }
                    if (!control.getSecondaryImage().isEmpty()) {
                        filesToZip.add(control.getSecondaryImage());
                    }
                }

                String[] zipArray = new String[filesToZip.size()];
                zipArray = filesToZip.toArray(zipArray);
                String invalidCharRemoved = screen.getName().replaceAll("[\\\\/:*?\"<>|]", "_");
                String zipName = "GIC-" + invalidCharRemoved + ".zip";
                String destination = Environment.getExternalStorageDirectory().getAbsolutePath() + "/" + zipName;
                ZipHelper.zip(zipArray, destination);

                String message = presentationWeakReference.get().view.getContext().getString(R.string.zip_successful);
                return message + zipName;
            } catch (Exception e) {
                e.printStackTrace();
                return e.getMessage();
            }
        }

        @Override
        protected void onPostExecute(String results) {
            presentationWeakReference.get().view.setProgressIndicator(false);
            presentationWeakReference.get().view.showMessage(results);
        }
    }

    private static class UpdateTask extends AsyncTask<Void, Void, Void> {
        IScreenRepository repository;
        int screenId;
        String newName;
        IContract.IView view;

        public UpdateTask(IContract.IView view, IScreenRepository repository, int screenId, String newName) {
            this.repository = repository;
            this.screenId = screenId;
            this.newName = newName;
            this.view = view;
        }

        @Override
        protected Void doInBackground(Void... voids) {
            IScreen screen = repository.getScreen(screenId);
            screen.setName(newName);
            repository.save(screen);
            return null;
        }

        @Override
        protected void onPostExecute(Void aVoid) {
            super.onPostExecute(aVoid);
            repository.getScreenList(new IScreenRepository.LoadScreenListCallback() {
                @Override
                public void onLoaded(SparseArray<String> screenList) {
                    view.updateSpinner(screenList);
                    view.setSpinnerSelection(screenId);
                    view.setProgressIndicator(false);
                }
            });
        }
    }
}
