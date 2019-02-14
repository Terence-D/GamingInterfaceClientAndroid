package ca.coffeeshopstudio.gaminginterfaceclient.models.screen;

import android.util.SparseArray;

/**
 * TODO: HEADER COMMENT HERE.
 */
public interface IScreenRepository {
    void loadScreens();

    Screen newScreen();

    void save(Screen screen);

    IScreen getScreen(int id);

    SparseArray<String> getScreenList();

    void removeScreen(int id);
}
