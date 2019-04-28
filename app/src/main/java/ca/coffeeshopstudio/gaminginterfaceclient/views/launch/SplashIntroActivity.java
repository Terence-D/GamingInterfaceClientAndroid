package ca.coffeeshopstudio.gaminginterfaceclient.views.launch;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;

import com.heinrichreimersoftware.materialintro.app.IntroActivity;
import com.heinrichreimersoftware.materialintro.slide.FragmentSlide;
import com.heinrichreimersoftware.materialintro.slide.SimpleSlide;

import ca.coffeeshopstudio.gaminginterfaceclient.R;

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
public class SplashIntroActivity extends IntroActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setButtonBackVisible(false);

        addSlide(new SimpleSlide.Builder()
                .title(R.string.slideIntroTitle)
                .image(R.drawable.ic_thumb_up_white_192dp)
                .description(R.string.slideIntroDesc)
                .background(R.color.slideBackground)
                .backgroundDark(R.color.colorPrimaryDark)
                .build());

        addSlide(new SimpleSlide.Builder()
                .title(R.string.slideAboutTitle)
                .image(R.drawable.ic_info_outline_white_192dp)
                .description(R.string.slideAboutDesc)
                .background(R.color.slideBackground)
                .backgroundDark(R.color.colorPrimaryDark)
                .build());

        addSlide(new SimpleSlide.Builder()
                .title(R.string.slideServerTitle)
                .image(R.drawable.ic_important_devices_white_192dp)
                .description(R.string.slideServerDesc)
                .background(R.color.slideBackground)
                .backgroundDark(R.color.colorPrimaryDark)
                /* Show/hide button */
                .buttonCtaLabel(R.string.slideSendLink)
                .buttonCtaClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        final Intent emailIntent = new Intent(android.content.Intent.ACTION_SEND);
                        emailIntent.setType("plain/text");
                        emailIntent.putExtra(android.content.Intent.EXTRA_SUBJECT,
                                "Link to GIC Server");
                        emailIntent.putExtra(android.content.Intent.EXTRA_TEXT,
                                "https://github.com/Terence-D/GameInputCommandServer/wiki");
                        startActivity(Intent.createChooser(
                                emailIntent, "Send mail..."));
                    }
                })
                .build());


        addSlide(new FragmentSlide.Builder()
                .fragment(new ScreenFragment())
                .background(R.color.slideBackground)
                .backgroundDark(R.color.colorPrimaryDark)
                .build());

        addSlide(new SimpleSlide.Builder()
                .title(R.string.slideLetsGoTitle)
                .image(R.drawable.ic_help_outline_whilte_192dp)
                .description(R.string.slideLetsGoDesc)
                .background(R.color.slideBackground)
                .backgroundDark(R.color.colorPrimaryDark)
                .build());
    }
}
