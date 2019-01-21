package ca.coffeeshopstudio.gaminginterfaceclient;

import android.content.SharedPreferences;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.widget.Button;
import android.widget.FrameLayout;

import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import ca.coffeeshopstudio.gaminginterfaceclient.models.Control;

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
public abstract class AbstractGameActivity extends AppCompatActivity implements View.OnClickListener {
    protected List<View> controls = new ArrayList<>();
    protected int activeControl = -1;

    protected void loadControls() {
        SharedPreferences prefs = getApplicationContext().getSharedPreferences("gicsScreen", MODE_PRIVATE);
        String pref;
        int i = 0;
        final ObjectMapper mapper = new ObjectMapper();
        List<Control> customControls = new ArrayList<>();

        do {
            pref = prefs.getString("control_" + i, "");

            try {
                customControls.add(mapper.readValue(pref, Control.class));
            } catch (IOException e) {
                e.printStackTrace();
            }
            i++;
        } while (!pref.equals(""));

        for (Control control : customControls) {
            Button button = new Button(AbstractGameActivity.this);
            button.setBackgroundResource(R.drawable.button_selector);
            button.setX(control.getLeft());
            button.setY(control.getTop());
            button.setWidth(control.getWidth());
            button.setHeight(control.getHeight());
            button.setTag(control.getCommand());
            button.setText(control.getText());
            button.setOnClickListener(this);
            FrameLayout layout = findViewById(R.id.topLayout);
            FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.WRAP_CONTENT, FrameLayout.LayoutParams.WRAP_CONTENT);
            layout.addView(button, lp);
            controls.add(button);
            button.setId(controls.size()-1);
        }
        activeControl = controls.size()-1;

    }

    @Override
    public void onClick(View view) {

    }
}
