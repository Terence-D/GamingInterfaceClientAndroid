package ca.coffeeshopstudio.gaminginterfaceclient.views;

import android.content.Intent;
import android.os.Bundle;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Button;
import android.widget.Toast;
import android.widget.ToggleButton;

import java.util.List;

import ca.coffeeshopstudio.gaminginterfaceclient.R;
import ca.coffeeshopstudio.gaminginterfaceclient.models.Command;
import ca.coffeeshopstudio.gaminginterfaceclient.models.GICControl;
import ca.coffeeshopstudio.gaminginterfaceclient.models.Result;
import ca.coffeeshopstudio.gaminginterfaceclient.network.CommandService;
import ca.coffeeshopstudio.gaminginterfaceclient.network.RestClientInstance;
import okhttp3.Credentials;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

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
public class GameActivity extends AbstractGameActivity implements View.OnTouchListener {
    private String password;
    private String port;
    private String address;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_game_interface);

        Intent intent = getIntent();
        password = intent.getStringExtra("password"); //if it's a string you stored.
        port = intent.getStringExtra("port"); //if it's a string you stored.
        address = intent.getStringExtra("address"); //if it's a string you stored.

        setupFullScreen();
        loadScreen();
    }

    @Override
    protected void setClick(View button) {
        button.setOnTouchListener(this);
    }

    private void makeCall(Command command) {
        String url = "http://" + address + ":" + port + "/";

        CommandService routeMap = RestClientInstance.getRetrofitInstance(url).create(CommandService.class);

        String auth = Credentials.basic("gic", password);

        Call<List<Result>> call = routeMap.postComplexCommand(auth, command);

        call.enqueue(new Callback<List<Result>>() {
            @Override
            public void onResponse(Call<List<Result>> call, Response<List<Result>> response) {
                if (!response.isSuccessful())
                    Toast.makeText(GameActivity.this, "Something went wrong...Please try later! " + response.message(), Toast.LENGTH_LONG).show();
            }

            @Override
            public void onFailure(Call<List<Result>> call, Throwable t) {
                Toast.makeText(GameActivity.this, "Something went wrong...Please try later! " + t.getLocalizedMessage(), Toast.LENGTH_LONG).show();
            }
        });
    }

    @Override
    public boolean onTouch(View view, MotionEvent motionEvent) {
        if (view instanceof ToggleButton) {
            return toggleAction(view, motionEvent);
        } else if (view instanceof Button) {
            GICControl control = (GICControl) view.getTag();
            switch (motionEvent.getAction()) {
                case MotionEvent.ACTION_DOWN:
                    control.getCommand().setActivatorType(Command.KEY_DOWN);
                    makeCall(control.getCommand());
                    view.performClick();
                    break;
                case MotionEvent.ACTION_UP:
                    control.getCommand().setActivatorType(Command.KEY_UP);
                    makeCall(control.getCommand());
                    break;
            }
        }
        return false;
    }

    private boolean toggleAction(View view, MotionEvent motionEvent) {
        GICControl control = (GICControl) view.getTag();
        switch (motionEvent.getAction()) {
            case MotionEvent.ACTION_DOWN:
                if (control.stage == 0) {
                    control.getCommand().setActivatorType(Command.KEY_DOWN);
                    makeCall(control.getCommand());
                    view.performClick();
                    control.stage++;
                } else if (control.stage == 2) {
                    control.getCommandSecondary().setActivatorType(Command.KEY_DOWN);
                    makeCall(control.getCommandSecondary());
                    view.performClick();
                    control.stage++;
                }
            case MotionEvent.ACTION_UP:
                if (control.stage == 1) {
                    control.getCommand().setActivatorType(Command.KEY_UP);
                    makeCall(control.getCommand());
                    control.stage++;
                } else if (control.stage == 3) {
                    control.getCommandSecondary().setActivatorType(Command.KEY_UP);
                    makeCall(control.getCommandSecondary());
                    control.stage = 0;
                }
                return true;
        }
        return false;
    }
}
