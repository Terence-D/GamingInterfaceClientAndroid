package ca.coffeeshopstudio.gaminginterfaceclient.models;

import android.content.Context;
import android.graphics.Typeface;

import java.util.Hashtable;

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
public class FontCache {

    private static Hashtable<String, Typeface> fontCache = new Hashtable<>();

    private static String[] fontList = new String[] {
            "Cabin-Regular",
            "Nunito-Regular",
            "Righteous-Regular",
            "ShareTech-Regular"
    };

    static String getFontName(int i) {
        return fontList[i];
    }

    static int getFontListSize() {
        return fontList.length;
    }

    public static void buildCache(Context context) {
        for (String font : fontList) {
            get (font, context);
        }
    }

    static Typeface get(String name, Context context) {
        Typeface tf = fontCache.get(name);
        if(tf == null) {
            try {
                tf = Typeface.createFromAsset(context.getAssets(), "fonts/" + name + ".ttf");
            }
            catch (Exception e) {
                return null;
            }
            fontCache.put(name, tf);
        }
        return tf;
    }
}
