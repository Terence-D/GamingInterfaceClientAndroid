package ca.coffeeshopstudio.gaminginterfaceclient.models;

import android.content.Context;
import android.graphics.Typeface;
import android.support.annotation.NonNull;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import ca.coffeeshopstudio.gaminginterfaceclient.R;

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
public class FontAdapter extends ArrayAdapter<String> {
    private Context context;
    private LayoutInflater inflater;

    public FontAdapter(Context context, int resource) {
        super(context, resource);
        inflater = LayoutInflater.from(context);
        this.context = context;
    }

    @Override
    public View getView(int position, View convertView, @NonNull ViewGroup parent)
    {
        final FontViewHolder holder;
        View view = convertView;
        if (view == null) {
            view = inflater.inflate(R.layout.item_font, parent, false);
            holder = new FontViewHolder();
            assert view != null;
            holder.textView = view.findViewById(R.id.text);
            view.setTag(holder);
        } else {
            holder = (FontViewHolder) view.getTag();
        }

        switch (position) {
            case 0:
//                holder.textView.setText(R.string.item_text_import);
//                holder.textView.setTypeface(Typeface.DEFAULT);
//                break;
//            case 1:
                holder.textView.setText(R.string.item_text_default);
                holder.textView.setTypeface(Typeface.DEFAULT);
                break;
            default:
                holder.textView.setText(holder.getFontName(position - 2));
                holder.textView.setTypeface(holder.getFont(position - 2, context));
                break;
        }

        return view;
    }

    @Override
    public int getCount() {
        return FontCache.getFontListSize() + 2;
    }

    @Override
    public String getItem(int position) {
        return null;
    }

    @Override
    public long getItemId(int position) {
        return position;
    }
}

class FontViewHolder {
    TextView textView;

    Typeface getFont(int pos, Context context){
        return FontCache.get(FontCache.getFontName(pos), context);
    }
    String getFontName(int pos){
        return FontCache.getFontName(pos);
    }

}
