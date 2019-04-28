package ca.coffeeshopstudio.gaminginterfaceclient.views.main;

import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.preference.PreferenceManager;
import android.util.SparseArray;

import java.util.List;

import ca.coffeeshopstudio.gaminginterfaceclient.R;
import ca.coffeeshopstudio.gaminginterfaceclient.models.screen.IScreen;
import ca.coffeeshopstudio.gaminginterfaceclient.models.screen.IScreenRepository;
import ca.coffeeshopstudio.gaminginterfaceclient.models.screen.ScreenRepository;
import ca.coffeeshopstudio.gaminginterfaceclient.network.CommandService;
import ca.coffeeshopstudio.gaminginterfaceclient.network.RestClientInstance;
import ca.coffeeshopstudio.gaminginterfaceclient.utils.CryptoHelper;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

import static android.content.Context.MODE_PRIVATE;

class MainPresentation implements IContract.IPresentation {
    private static final String PREFS_HELP_FIRST_TIME = "seenHelp";
    private static final String PREF_KEY_FIRST_START = "prefSplash";
    private static final String PREFS_CHOSEN_ID = "chosen_id";
    private IContract.IView view;

    MainPresentation(IContract.IView view) {
        this.view = view;
    }

    @Override
    public void checkFirstRun() {
        boolean firstStart = PreferenceManager.getDefaultSharedPreferences(view.getContext())
                .getBoolean(PREF_KEY_FIRST_START, true);

        if (firstStart) {
            view.loadIntro();
        }
    }

    @Override
    public void introResult(boolean isFirstTime) {
        PreferenceManager.getDefaultSharedPreferences(view.getContext()).edit()
                .putBoolean(PREF_KEY_FIRST_START, isFirstTime)
                .apply();
        new ScreenRepository(view.getContext()).init(new IScreenRepository.LoadCallback() {
            @Override
            public void onLoaded(List<IScreen> screens) {

            }
        });
    }

    @Override
    public void saveSettings(String password, String port, String address) {
        if (password.length() < 6) {
            view.showMessage(R.string.password_invalid);
            return;
        }
        if (!isInteger(port)) {
            view.showMessage(R.string.port_invalid);
            return;
        }

        if (address.length() < 7) {
            view.showMessage(R.string.address_invalid);
            return;
        }

        try {
            password = CryptoHelper.encrypt(password);
        } catch (Exception e) {
            e.printStackTrace();
        }

        SharedPreferences prefs = view.getContext().getApplicationContext()
                .getSharedPreferences("gics", MODE_PRIVATE);
        SharedPreferences.Editor prefsEditor = prefs.edit();

        prefsEditor.putString("address", address);
        prefsEditor.putString("port", port);
        prefsEditor.putString("password", password);

        prefsEditor.apply();

        port = port.replaceFirst("\\s++$", "");
        address = address.replaceFirst("\\s++$", "");

        view.getViewModel().setAddress(address);
        view.getViewModel().setPassword(password);
        view.getViewModel().setPort(port);
        view.startApp();
    }

    private static boolean isInteger(String str) {
        if (str == null) {
            return false;
        }
        if (str.isEmpty()) {
            return false;
        }
        int i = 0;
        int length = str.length();

        if (str.charAt(0) == '-') {
            if (length == 1) {
                return false;
            }
            i = 1;
        }
        for (; i < length; i++) {
            char c = str.charAt(i);
            if (c < '0' || c > '9') {
                return false;
            }
        }
        return true;
    }

    @Override
    public void selectScreen(int keyAt) {
        SharedPreferences prefs = view.getContext().getApplicationContext().getSharedPreferences(ScreenRepository.PREFS_NAME, MODE_PRIVATE);
        SharedPreferences.Editor prefsEditor = prefs.edit();
        try {
            prefsEditor.putInt(PREFS_CHOSEN_ID, keyAt);
            prefsEditor.apply();
        } catch (Exception e) {

        }
    }

    @Override
    public void toggleTheme() {
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(view.getContext());
        SharedPreferences.Editor prefsEditor = prefs.edit();
        prefsEditor.putBoolean("NIGHT_MODE", !prefs.getBoolean("NIGHT_MODE", true));
        prefsEditor.apply();
    }

    @Override
    public void checkServerVersion(String address, String port) {
        String url = "http://" + address + ":" + port + "/";

        CommandService routeMap = RestClientInstance.getRetrofitInstance(url).create(CommandService.class);
        Call<String> version = routeMap.getVersion();
        version.enqueue(new Callback<String>() {
            @Override
            public void onResponse(Call<String> call, Response<String> response) {
                view.setProgressIndicator(false);
                if (response.isSuccessful()) {
                    assert response.body() != null;
                    if (response.body().equals("1.3.0.0")) {
                        view.startGameApp();
                        return;
                    }
                    view.displayUpgradeWarning();
                } else {
                    view.showMessage(response.message());
                }
            }

            @Override
            public void onFailure(Call<String> call, Throwable t) {
                view.setProgressIndicator(false);
                view.showMessage(t.getLocalizedMessage());
            }
        });
    }

    @Override
    public void setSeenHelp() {
        SharedPreferences prefs = view.getContext().getApplicationContext().getSharedPreferences("gics", MODE_PRIVATE);
        SharedPreferences.Editor prefsEditor = prefs.edit();
        prefsEditor.putBoolean(PREFS_HELP_FIRST_TIME, true).apply();
    }

    @Override
    public void loadSettings() {
        view.setProgressIndicator(true);
        LoadSettingsAsync asyncTask = new LoadSettingsAsync(view);
        asyncTask.execute();
    }

    private static class LoadSettingsAsync extends AsyncTask<Void, Void, Void> {
        private IContract.IView view;
        private String password;
        private String address;
        private String port;
        private boolean seenHelp;

        LoadSettingsAsync(IContract.IView view) {
            this.view = view;
        }

        @Override
        protected Void doInBackground(Void... voids) {
            SharedPreferences prefs = view.getContext().getApplicationContext().getSharedPreferences("gics", MODE_PRIVATE);

            password = prefs.getString("password", "");
            try {
                password = CryptoHelper.decrypt(password);
            } catch (Exception e) {
                e.printStackTrace();
            }

            address = prefs.getString("address", "");
            port = prefs.getString("port", "8091");
            seenHelp = prefs.getBoolean(PREFS_HELP_FIRST_TIME, false);
            return null;
        }

        @Override
        protected void onPostExecute(Void aVoid) {

            view.getViewModel().setPort(port);
            view.getViewModel().setPassword(password);
            view.getViewModel().setAddress(address);

            ScreenRepository screenRepository = new ScreenRepository(view.getContext().getApplicationContext());
            screenRepository.getScreenList(new IScreenRepository.LoadScreenListCallback() {
                @Override
                public void onLoaded(SparseArray<String> screenList) {
                    String[] spinnerArray = new String[screenList.size()];
                    SharedPreferences prefs = view.getContext().getApplicationContext().getSharedPreferences(ScreenRepository.PREFS_NAME, MODE_PRIVATE);
                    int chosenId = prefs.getInt(PREFS_CHOSEN_ID, 0);
                    int chosenIndex = 0;

                    for (int i = 0; i < screenList.size(); i++) {
                        spinnerArray[i] = screenList.valueAt(i);
                        if (screenList.keyAt(i) == chosenId)
                            chosenIndex = i;
                    }

                    view.getViewModel().setScreenArray(spinnerArray);
                    view.getViewModel().setScreenList(screenList);
                    view.getViewModel().SetStartingScreenIndex(chosenIndex);
                    view.setProgressIndicator(false);
                    if (!seenHelp)
                        view.showHelpMenuIcon();
                    view.updateView();
                }
            });
            view.setProgressIndicator(true);
        }
    }
}
