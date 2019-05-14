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
public abstract class AbstractAdapter extends BaseAdapter {
    private int customCount;
    private Context context;
    private LayoutInflater inflater;
    private String imagePrefix;

    AbstractAdapter(Context context) {
        inflater = LayoutInflater.from(context);
        this.context = context;
    }

    int getCustomCount() {
        return customCount;
    }

    public void setCustomCount(int customCount) {
        this.customCount = customCount;
    }

    void setImagePrefix(String prefix) {
        imagePrefix = prefix;
    }

    public abstract int[] getBuiltInResources();

    @Override
    public int getCount() {
        return getBuiltInResources().length + 2 + getCustomCount();
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


        if (position == 0 || position == 1) {
            holder.textView.setVisibility(View.VISIBLE);
            holder.imageView.setVisibility(View.GONE);
            if (position == 0)
                holder.textView.setText(R.string.item_grid_text);
            else
                holder.textView.setText(R.string.item_grid_text_image);
            //show "add" item
        } else if (position <= getCustomCount()) {
            holder.textView.setVisibility(View.GONE);
            String path = context.getFilesDir() + "/" + imagePrefix + "_" + (position - 2) + ".png";
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
        } else if (position - getCustomCount() <= getBuiltInResources().length + 2) {
            holder.textView.setVisibility(View.GONE);
            holder.imageView.setVisibility(View.VISIBLE);
            holder.imageView.setImageResource(getBuiltInResources()[position - getCustomCount() - 2]);
            holder.imageView.setScaleType(ImageView.ScaleType.FIT_CENTER);
        }

        return view;
    }

    class ViewHolder {
        ImageView imageView;
        TextView textView;
    }
}



