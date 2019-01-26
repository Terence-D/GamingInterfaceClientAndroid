package ca.coffeeshopstudio.gaminginterfaceclient.views;

import android.graphics.Color;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.DialogFragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.Spinner;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import ca.coffeeshopstudio.gaminginterfaceclient.R;
import ca.coffeeshopstudio.gaminginterfaceclient.models.AutoItKeyMap;
import ca.coffeeshopstudio.gaminginterfaceclient.models.Command;
import top.defaults.colorpicker.ColorPickerPopup;

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
public class EditFragment extends DialogFragment implements AdapterView.OnItemSelectedListener, View.OnClickListener {

    private AutoItKeyMap map = new AutoItKeyMap();
    private View incomingView;
    private Spinner spinner;
    private Command commandToLoad = null;
    private String commandName;
    private int font;
    private int primary;
    private int secondary;
    private CheckBox lShift;
    //private CheckBox rShift;
    private CheckBox lCtrl;
    //private CheckBox rCtrl;
    private CheckBox lAlt;
    //private CheckBox rAlt;
    private TextView text;

    private Button btnFont;
    private Button btnPrimary;
    private Button btnSecondary;


    public static EditFragment newInstance(String title, String text, Command command, int primary, int secondary, int font, View view) {
        EditFragment frag = new EditFragment();
        Bundle args = new Bundle();
        args.putString("title", title);
        args.putString("text", text);
        args.putInt("font", font);
        args.putInt("primary", primary);
        args.putInt("secondary", secondary);
        frag.setArguments(args);
        if (command != null)
            frag.loadCommand(command);
        if (view != null)
            frag.loadView(view);
        return frag;
    }

    // Empty constructor is required for DialogFragment
    // Make sure not to add arguments to the constructor
    // Use `newInstance` instead as shown below
    public EditFragment() {
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        // Fetch arguments from bundle and set title
        String title = null;
        if (getArguments() != null) {
            title = getArguments().getString("title", "Enter Name");
        } else
            title = getString(R.string.default_control_text);
        commandName = getArguments().getString("text", "");
        font = getArguments().getInt("font", Color.BLACK);
        primary = getArguments().getInt("primary", Color.GRAY);
        secondary = getArguments().getInt("secondary", Color.WHITE);
        getDialog().setTitle(title);
        // Show soft keyboard automatically and request focus to field
        getDialog().getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_VISIBLE);
        setupControls(view);
    }

    public void loadCommand(Command command) {
        commandToLoad = command;
    }

    public void loadView(View view) {
        incomingView = view;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_edit_control, container);
    }

    private void setupControls(View view) {
        text = view.findViewById(R.id.txtText);
        lShift = view.findViewById(R.id.chkLShift);
        //rShift = view.findViewById(R.id.chkRShift);
        lCtrl = view.findViewById(R.id.chkLCtrl);
        //rCtrl = view.findViewById(R.id.chkRCtrl);
        lAlt = view.findViewById(R.id.chkLAlt);
        //rAlt = view.findViewById(R.id.chkRAlt);

        buildCommandSpinner(view);

        text.setText(commandName);
        //load in any data we brought in
        if (commandToLoad != null) {
            for (int i = 0; i < commandToLoad.getModifiers().size(); i++) {
                if (commandToLoad.getModifiers().get(i).equals("ALT"))
                    lAlt.setChecked(true);
                else
                    lAlt.setChecked(false);
                if (commandToLoad.getModifiers().get(i).equals("CTRL"))
                    lCtrl.setChecked(true);
                else
                    lCtrl.setChecked(false);
                if (commandToLoad.getModifiers().get(i).equals("SHIFT"))
                    lShift.setChecked(true);
                else
                    lShift.setChecked(false);
            }
        }

        btnFont = view.findViewById(R.id.btnFontColor);
        btnPrimary = view.findViewById(R.id.btnButtonColor1);
        btnSecondary = view.findViewById(R.id.btnButtonColor2);

        btnFont.setOnClickListener(this);
        btnFont.setTextColor(font);
        btnPrimary.setOnClickListener(this);
        btnPrimary.setTextColor(primary);
        btnSecondary.setOnClickListener(this);
        btnSecondary.setTextColor(secondary);

        view.findViewById(R.id.btnButtonColor1).setOnClickListener(this);
        view.findViewById(R.id.btnButtonColor2).setOnClickListener(this);

        view.findViewById(R.id.btnSave).setOnClickListener(this);
        view.findViewById(R.id.btnDelete).setOnClickListener(this);

        if (incomingView != null && !(incomingView instanceof Button)) {
            view.findViewById(R.id.btnButtonColor2).setVisibility(View.INVISIBLE);
            view.findViewById(R.id.btnButtonColor1).setVisibility(View.INVISIBLE);
            view.findViewById(R.id.lblInstructions).setVisibility(View.INVISIBLE);
            view.findViewById(R.id.spinner).setVisibility(View.INVISIBLE);
            view.findViewById(R.id.chkLShift).setVisibility(View.INVISIBLE);
            view.findViewById(R.id.chkLAlt).setVisibility(View.INVISIBLE);
            view.findViewById(R.id.chkLCtrl).setVisibility(View.INVISIBLE);
        }
    }

    private void buildCommandSpinner(View view) {
        spinner = view.findViewById(R.id.spinner);
        spinner.setOnItemSelectedListener(this);

        Collection<String> values = map.getKeys().values();
        String[] spinnerArray = values.toArray(new String[values.size()]);
        ArrayAdapter<CharSequence> dataAdapter = new ArrayAdapter<CharSequence>(getActivity(), android.R.layout.simple_spinner_dropdown_item, spinnerArray);

        dataAdapter.setDropDownViewResource(android.R.layout.simple_dropdown_item_1line);
        spinner.setAdapter(dataAdapter);

        if (commandToLoad != null) {
            String key = commandToLoad.getKey();
            List<String> keys = new ArrayList<>(map.getKeys().keySet());

            for (int i = 0; i < keys.size(); i++) {
                if (keys.get(i).equals(key)) {
                    spinner.setSelection(i);
                    return;
                }
            }
        }
    }

    @Override
    public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {

    }

    @Override
    public void onNothingSelected(AdapterView<?> adapterView) {

    }

    @Override
    public void onClick(View view) {
        EditDialogListener listener = (EditDialogListener) getActivity();
        Command savedCommand = null;
        String title;
        switch (view.getId()) {
            case R.id.btnSave:
                savedCommand = new Command();
                List<String> keys = new ArrayList<>(map.getKeys().keySet());
                savedCommand.setKey(keys.get(spinner.getSelectedItemPosition()));

                title = text.getText().toString();

                if (lShift.isChecked()) {
                    savedCommand.addModifier("SHIFT");
                }
                if (lCtrl.isChecked()) {
                    savedCommand.addModifier("CTRL");
                }
                if (lAlt.isChecked()) {
                    savedCommand.addModifier("ALT");
                }
                //for now disabling "right" handed modifiers.  AutoIt seems to have a bug
                //where it won't properly release them.
//                if (rShift.isChecked()) {
//                    savedCommand.addModifier("SHIFT");
//                }
//                if (rCtrl.isChecked()) {
//                    savedCommand.addModifier("CTRL");
//                }
//                if (rAlt.isChecked()) {
//                    savedCommand.addModifier("ALT");
//                }
                listener.onFinishEditDialog(savedCommand, title, btnPrimary.getTextColors().getDefaultColor(), btnSecondary.getTextColors().getDefaultColor(), btnFont.getTextColors().getDefaultColor());
                dismiss();
                break;
            case R.id.btnDelete:
                title = "DELETE";
                listener.onFinishEditDialog(savedCommand, title, btnPrimary.getTextColors().getDefaultColor(), btnSecondary.getTextColors().getDefaultColor(), btnFont.getTextColors().getDefaultColor());
                dismiss();
                break;
            case R.id.btnButtonColor1:
                displayColorPicker(view);
                break;
            case R.id.btnButtonColor2:
                displayColorPicker(view);
                break;
            case R.id.btnFontColor:
                displayColorPicker(view);
                break;
            default:
                break;
        }
    }

    private void displayColorPicker(final View view) {
        int color = ((Button) view).getTextColors().getDefaultColor();
        new ColorPickerPopup.Builder(getActivity())
                .initialColor(color) // Set initial color
                .enableBrightness(true) // Enable brightness slider or not
                //.enableAlpha(true) // Enable alpha slider or not
                .okTitle(getString(R.string.color_picker_title))
                .cancelTitle(getString(android.R.string.cancel))
                .showIndicator(true)
                .showValue(true)
                .build()
                .show(view, new ColorPickerPopup.ColorPickerObserver() {
                    @Override
                    public void onColorPicked(int color) {
                        ((Button) view).setTextColor(color);
                    }
                });
    }


    public interface EditDialogListener {
        void onFinishEditDialog(Command command, String text, int primaryColor, int secondaryColor, int fontColor);
    }

}