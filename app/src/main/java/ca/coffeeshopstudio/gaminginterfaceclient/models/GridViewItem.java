package ca.coffeeshopstudio.gaminginterfaceclient.models;

/**
 * TODO: HEADER COMMENT HERE.
 */
public class GridViewItem {
    public final int icon;       // the drawable id for the ListView item ImageView

    public GridViewItem(int icon) {
        this.icon = icon;
    }

    public int getIcon() {
        return this.icon;
    }
}
