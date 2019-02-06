package ca.coffeeshopstudio.gaminginterfaceclient.models;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;

import com.squareup.picasso.Callback;
import com.squareup.picasso.Picasso;

import ca.coffeeshopstudio.gaminginterfaceclient.R;

/**
 * TODO: HEADER COMMENT HERE.
 */
public class ImageAdapter extends BaseAdapter {
    private static final String[] IMAGE_URLS = Constants.IMAGES;
    Context c;
    private LayoutInflater inflater;

    public ImageAdapter(Context context) {
        inflater = LayoutInflater.from(context);
        c = context;

    }

    @Override
    public int getCount() {
        return IMAGE_URLS.length;
    }

    @Override
    public Object getItem(int position) {
        return null;
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        final ViewHolder holder;
        View view = convertView;
        if (view == null) {
            view = inflater.inflate(R.layout.item_grid_image, parent, false);
            holder = new ViewHolder();
            assert view != null;

            holder.imageView = view.findViewById(R.id.image);

            view.setTag(holder);
        } else {
            holder = (ViewHolder) view.getTag();
        }
        Picasso.get().setLoggingEnabled(true);
        if (position == 0) {
            holder.imageView.setImageResource(R.drawable.neon_button);
            holder.imageView.setScaleType(ImageView.ScaleType.FIT_CENTER);
        } else {
            Picasso.get()
                    .load(IMAGE_URLS[position])
                    .placeholder(R.mipmap.ic_launcher)
                    .error(R.mipmap.ic_launcher)
                    .fit()
                    .into(holder.imageView, new Callback() {

                        @Override
                        public void onSuccess() {
                            holder.imageView.setVisibility(View.VISIBLE);
                        }

                        @Override
                        public void onError(Exception e) {
                            holder.imageView.setVisibility(View.INVISIBLE);
                        }
                    });
        }

        return view;
    }
}

class ViewHolder {
    ImageView imageView;
}


class Constants {

    public static final String[] IMAGES = new String[]{
// Heavy images
            "R.drawable.neon_button",
            "file:///sdcard/blue-button-for-web.jpg",
            "file:///sdcard/blue-button-for-web.jpg",
            "file:///sdcard/blue-button-for-web.jpg",
            "file:///sdcard/blue-button-for-web.jpg",
            "https://via.placeholder.com/150",
            "https://via.placeholder.com/150",
            "https://via.placeholder.com/150",
            "https://via.placeholder.com/150",
            "https://via.placeholder.com/150",
            "https://via.placeholder.com/150",
    };


}