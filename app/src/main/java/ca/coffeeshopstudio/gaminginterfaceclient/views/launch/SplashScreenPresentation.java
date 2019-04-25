package ca.coffeeshopstudio.gaminginterfaceclient.views.launch;

import android.content.Context;
import android.os.AsyncTask;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.List;

import androidx.annotation.NonNull;
import ca.coffeeshopstudio.gaminginterfaceclient.R;
import ca.coffeeshopstudio.gaminginterfaceclient.models.screen.IScreenRepository;
import ca.coffeeshopstudio.gaminginterfaceclient.models.screen.Screen;

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
        ImportTask task = new ImportTask(repository, view, toImport);
        task.execute();
    }


    private static class ImportTask extends AsyncTask<Void, Void, Boolean> {
        private final IScreenRepository repository;
        private final IContract.IView view;
        private List<ScreenFragment.Model> models;

        ImportTask(IScreenRepository repository, IContract.IView view, List<ScreenFragment.Model> models) {
            this.repository = repository;
            this.view = view;
            this.models = models;
        }

        @Override
        protected Boolean doInBackground(Void... values) {
            ObjectMapper objectMapper = new ObjectMapper();
            boolean anythingDone = false;
            for (ScreenFragment.Model model : models) {
                if (model.isSelected()) {
                    String json = loadJSONFromAsset(view.getContext(), model.getText());
                    try {
                        Screen screen = objectMapper.readValue(json, Screen.class);
                        repository.importScreenSync(screen);
                        anythingDone = true;
                    } catch (JsonParseException e) {
                        e.printStackTrace();
                    } catch (JsonMappingException e) {
                        e.printStackTrace();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }

            return anythingDone;
        }

        @Override
        protected void onPostExecute(Boolean anythingDone) {
            if (anythingDone) {
                view.showMessage(R.string.slideScreenSuccess);
            }
            view.setProgressIndicator(false);
        }


        private String loadJSONFromAsset(Context context, String filename) {
            String json;
            try {
                InputStream is = context.getAssets().open("screens/" + filename + ".json");
                int size = is.available();
                byte[] buffer = new byte[size];
                is.read(buffer);
                is.close();
                json = new String(buffer, StandardCharsets.UTF_8);
            } catch (IOException ex) {
                ex.printStackTrace();
                return null;
            }
            return json;
        }
    }
}
