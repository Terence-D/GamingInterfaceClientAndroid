package ca.coffeeshopstudio.gaminginterfaceclient.views.launch;

import android.graphics.Color;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.List;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import ca.coffeeshopstudio.gaminginterfaceclient.R;
import ca.coffeeshopstudio.gaminginterfaceclient.models.screen.ScreenRepository;

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
public class ScreenFragment extends Fragment implements IContract.IView {
    private IContract.IPresentation actionListener;
    private RecyclerView recyclerView;
    private List<Model> screenList;
    private ProgressBar progressBar;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {

        View view = inflater.inflate(R.layout.fragment_screen_select, container, false);

        progressBar = view.findViewById(R.id.progressBar);
        recyclerView = view.findViewById(R.id.recyclerView);
        LinearLayoutManager manager = new LinearLayoutManager(getContext());
        recyclerView.setHasFixedSize(true);
        recyclerView.setLayoutManager(manager);

        view.findViewById(R.id.btnImport).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                actionListener.importJson(screenList);
            }
        });

        setPresentation(new SplashScreenPresentation(this, new ScreenRepository(getContext())));
        actionListener.loadScreenList();

        return view;
    }

    @Override
    public void setPresentation(IContract.IPresentation listener) {
        this.actionListener = listener;
    }

    @Override
    public void showScreenList(String[] screens) {
        screenList = new ArrayList<>();
        for (int i = 0; i < screens.length; i++) {
            screenList.add(new Model(screens[i]));
        }

        RecyclerView.Adapter adapter = new RecyclerViewAdapter(screenList);
        recyclerView.setAdapter(adapter);
    }

    @Override
    public void showMessage(int messageId) {
        Toast.makeText(getContext(), messageId, Toast.LENGTH_SHORT).show();
    }

    @Override
    public void setProgressIndicator(boolean show) {
        if (show)
            progressBar.setVisibility(View.VISIBLE);
        else
            progressBar.setVisibility(View.GONE);
    }

    public class Model {
        private String text;
        private boolean isSelected = false;

        Model(String text) {
            this.text = text;
        }

        public String getText() {
            return text;
        }

        public boolean isSelected() {
            return isSelected;
        }

        void setSelected(boolean selected) {
            isSelected = selected;
        }
    }

    class RecyclerViewAdapter extends RecyclerView.Adapter<RecyclerViewAdapter.ScreenViewHolder> {

        private List<Model> screenList;

        RecyclerViewAdapter(List<Model> modelList) {
            screenList = modelList;
        }

        @NonNull
        @Override
        public ScreenViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.row_screen_select, parent, false);
            return new ScreenViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull final ScreenViewHolder holder, int position) {
            final Model model = screenList.get(position);
            holder.textView.setText(model.text);
            holder.view.setBackgroundColor(model.isSelected() ? Color.BLUE : Color.WHITE);
            holder.textView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    model.setSelected(!model.isSelected());
                    holder.view.setBackgroundColor(model.isSelected() ? Color.BLUE : Color.WHITE);
                }
            });
        }

        @Override
        public int getItemCount() {
            return screenList == null ? 0 : screenList.size();
        }

        class ScreenViewHolder extends RecyclerView.ViewHolder {

            private View view;
            private TextView textView;

            private ScreenViewHolder(View itemView) {
                super(itemView);
                view = itemView;
                textView = itemView.findViewById(R.id.txtName);
            }
        }
    }
}
