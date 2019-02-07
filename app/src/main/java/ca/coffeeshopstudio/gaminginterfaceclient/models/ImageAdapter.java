package ca.coffeeshopstudio.gaminginterfaceclient.models;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.squareup.picasso.Callback;
import com.squareup.picasso.Picasso;

import java.io.File;

import ca.coffeeshopstudio.gaminginterfaceclient.R;

/**
 * TODO: HEADER COMMENT HERE.
 */
public class ImageAdapter extends BaseAdapter {
    private static final int[] builtIn = Constants.buttons;
    private int customButtonCount = 0;
    private Context context;
    private LayoutInflater inflater;

    public ImageAdapter(Context context, int customButtonCount) {
        inflater = LayoutInflater.from(context);
        this.customButtonCount = customButtonCount;
        this.context = context;
    }

    @Override
    public int getCount() {
        return builtIn.length + 1 + customButtonCount;
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
        //build / retrieve a cell in the grid
        if (view == null) {
            view = inflater.inflate(R.layout.item_grid_image, parent, false);
            holder = new ViewHolder();
            assert view != null;

            holder.textView = view.findViewById(R.id.text);
            holder.imageView = view.findViewById(R.id.image);

            view.setTag(holder);
        } else {
            holder = (ViewHolder) view.getTag();
        }


        if (position == 0) {
            holder.textView.setVisibility(View.VISIBLE);
            holder.imageView.setVisibility(View.GONE);
            //show "add" item
        } else if (position <= customButtonCount) {
            holder.textView.setVisibility(View.GONE);
            String path = context.getFilesDir() + "/button_" + (position - 1) + ".png";
            Picasso.get().setLoggingEnabled(true);
            Picasso.get()
                    .load(new File(path))
                    .error(R.mipmap.ic_launcher)
                    .fit().centerInside()
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
        } else if (position - customButtonCount <= builtIn.length) {
            holder.textView.setVisibility(View.GONE);
            holder.imageView.setVisibility(View.VISIBLE);
            holder.imageView.setImageResource(builtIn[position - customButtonCount - 1]);
            holder.imageView.setScaleType(ImageView.ScaleType.FIT_CENTER);
        }

        return view;
//            Picasso.get()
//                    .load(builtIn[position])
//                    .placeholder(R.mipmap.ic_launcher)
//                    .error(R.mipmap.ic_launcher)
//                    .fit()
//                    .into(holder.imageView, new Callback() {
//
//                        @Override
//                        public void onSuccess() {
//                            holder.imageView.setVisibility(View.VISIBLE);
//                        }
//
//                        @Override
//                        public void onError(Exception e) {
//                            holder.imageView.setVisibility(View.INVISIBLE);
//                        }
//                    });
//        }
    }
}

class ViewHolder {
    ImageView imageView;
    TextView textView;
}


class Constants {

    static final int[] buttons = new int[]{
        R.drawable.neon_button,
    };


}