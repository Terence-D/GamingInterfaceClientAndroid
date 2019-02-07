package ca.coffeeshopstudio.gaminginterfaceclient.views;

import android.Manifest;
import android.app.Activity;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.support.annotation.Nullable;
import android.support.v4.app.ActivityCompat;
import android.support.v4.app.DialogFragment;
import android.support.v4.content.ContextCompat;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.Spinner;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;

import com.flask.colorpicker.ColorPickerView;
import com.flask.colorpicker.builder.ColorPickerClickListener;
import com.flask.colorpicker.builder.ColorPickerDialogBuilder;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import ca.coffeeshopstudio.gaminginterfaceclient.R;
import ca.coffeeshopstudio.gaminginterfaceclient.models.AutoItKeyMap;
import ca.coffeeshopstudio.gaminginterfaceclient.models.Command;

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
public class EditTextStyleFragment extends DialogFragment implements AdapterView.OnItemSelectedListener, View.OnClickListener, CompoundButton.OnCheckedChangeListener {

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
    private Button btnNormal;
    private Button btnPressed;

    private boolean imageBased = false;


    // Empty constructor is required for DialogFragment
    // Make sure not to add arguments to the constructor
    // Use `newInstance` instead as shown below
    public EditTextStyleFragment() {
    }

    public static EditTextStyleFragment newInstance(String title, String text, Command command, int primary, int secondary, int font, View view) {
        EditTextStyleFragment frag = new EditTextStyleFragment();
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

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        // Fetch arguments from bundle and set title
        String title;
        if (getArguments() != null) {
            title = getArguments().getString("title", "Enter Name");
        } else
            title = getString(R.string.default_control_text);
        commandName = getArguments().getString("text", "");
        font = getArguments().getInt("font", Color.BLACK);
        primary = getArguments().getInt("primary", Color.GRAY);
        secondary = getArguments().getInt("secondary", Color.WHITE);
        getDialog().setTitle(title);
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
            lAlt.setChecked(false);
            lCtrl.setChecked(false);
            lShift.setChecked(false);
            for (int i = 0; i < commandToLoad.getModifiers().size(); i++) {
                if (commandToLoad.getModifiers().get(i).equals("ALT"))
                    lAlt.setChecked(true);
                if (commandToLoad.getModifiers().get(i).equals("CTRL"))
                    lCtrl.setChecked(true);
                if (commandToLoad.getModifiers().get(i).equals("SHIFT"))
                    lShift.setChecked(true);
            }
        }

        btnFont = view.findViewById(R.id.btnFontColor);
        btnPrimary = view.findViewById(R.id.btnPrimary);
        btnSecondary = view.findViewById(R.id.btnSecondary);
        btnNormal = view.findViewById(R.id.btnNormal);
        btnPressed = view.findViewById(R.id.btnPressed);

        btnFont.setOnClickListener(this);
        btnFont.setTextColor(font);
        btnPrimary.setOnClickListener(this);
        btnPrimary.setTextColor(primary);
        btnSecondary.setOnClickListener(this);
        btnSecondary.setTextColor(secondary);
        btnPressed.setOnClickListener(this);
        btnNormal.setOnClickListener(this);

        view.findViewById(R.id.btnPrimary).setOnClickListener(this);
        view.findViewById(R.id.btnSecondary).setOnClickListener(this);

        view.findViewById(R.id.btnSave).setOnClickListener(this);
        view.findViewById(R.id.btnDelete).setOnClickListener(this);

        ((Switch) view.findViewById(R.id.switchType)).setOnCheckedChangeListener(this);

        if (incomingView != null && !(incomingView instanceof Button)) {
            view.findViewById(R.id.btnSecondary).setVisibility(View.INVISIBLE);
            view.findViewById(R.id.btnPrimary).setVisibility(View.INVISIBLE);
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
            case R.id.btnPrimary:
                displayColorPicker(view);
                break;
            case R.id.btnSecondary:
                displayColorPicker(view);
                break;
            case R.id.btnFontColor:
                displayColorPicker(view);
                break;
            case R.id.btnPressed:
            case R.id.btnNormal:
                displayImageLoader();
                break;
            default:
                break;
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
        switch (requestCode) {
            case 1337: {
                // If request is cancelled, the result arrays are empty.
                if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    displayImageLoader();
                }
            }
            break;
        }
    }

    private void displayImageLoader() {
        if (ContextCompat.checkSelfPermission(getActivity(), Manifest.permission.READ_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
            // Permission is not granted
            // Should we show an explanation?
            if (ActivityCompat.shouldShowRequestPermissionRationale(getActivity(), Manifest.permission.READ_EXTERNAL_STORAGE)) {
                // Show an explanation to the user *asynchronously* -- don't block
                // this thread waiting for the user's response! After the user
                // sees the explanation, try again to request the permission.
                Toast.makeText(getActivity(), "test", Toast.LENGTH_SHORT).show();
            } else {
                // No explanation needed, we can request the permission.
                ActivityCompat.requestPermissions(getActivity(),
                        new String[]{Manifest.permission.READ_EXTERNAL_STORAGE}, 1337);
            }
        } else {
            ImageGridDialog gridView = new ImageGridDialog(this);
            gridView.show();
//            AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
            //builder.setTitle("Select an icon");

//            GridView gridView = new GridView(getActivity());
//            gridView.setAdapter(new ImageAdapter(getContext()));
//
//            gridView.setNumColumns(2);               // Number of columns
//            gridView.setChoiceMode(GridView.CHOICE_MODE_SINGLE);       // Choice mode
//            gridView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
//                @Override
//                public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
//                    // do something here
//                    Toast.makeText(getActivity(), "Position: " + position, Toast.LENGTH_SHORT).show();
//                    dimiss();
//                }
//            });
//            builder.setView(gridView);
//            builder.create().show();
        }
    }

    private void displayColorPicker(final View view) {
        ColorPickerDialogBuilder
                .with(getContext())
                .setTitle(getString(R.string.color_picker_title))
                .initialColor(((Button) view).getCurrentTextColor())
                .wheelType(ColorPickerView.WHEEL_TYPE.FLOWER)
                .density(12)
                .setPositiveButton(getString(android.R.string.ok), new ColorPickerClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int selectedColor, Integer[] allColors) {
                        ((Button) view).setTextColor(selectedColor);
                    }
                })
                .setNegativeButton(getString(android.R.string.cancel), new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                    }
                })
                .build()
                .show();
    }

    @Override
    public void onCheckedChanged(CompoundButton compoundButton, boolean checked) {
        imageBased = checked;
        if (checked) {
            btnSecondary.setVisibility(View.INVISIBLE);
            btnPrimary.setVisibility(View.INVISIBLE);
            btnNormal.setVisibility(View.VISIBLE);
            btnPressed.setVisibility(View.VISIBLE);
        } else {
            btnSecondary.setVisibility(View.VISIBLE);
            btnPrimary.setVisibility(View.VISIBLE);
            btnNormal.setVisibility(View.INVISIBLE);
            btnPressed.setVisibility(View.INVISIBLE);
        }
    }

    public interface EditDialogListener {
        void onFinishEditDialog(Command command, String text, int primaryColor, int secondaryColor, int fontColor);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, @Nullable Intent resultData) {
        super.onActivityResult(requestCode, resultCode, resultData);
        if (resultCode == Activity.RESULT_OK) {
            if (requestCode == EditActivity.OPEN_REQUEST_CODE_IMPORT_BUTTON) {
                if (resultData != null) {
                    Uri currentUri = resultData.getData();
                    if (currentUri != null) {
                        try {
                            Bitmap bitmap = MediaStore.Images.Media.getBitmap(getActivity().getContentResolver(), currentUri);
                            File file = null;
                            for (int i = 0; i < Integer.MAX_VALUE; i++) {
                                file = new File(getContext().getFilesDir(), "button_" + i + ".png");
                                if (!file.exists())
                                    break;
                            }
                            FileOutputStream out = new FileOutputStream(file);
                            bitmap.compress(Bitmap.CompressFormat.PNG, 90, out);
                            out.flush();
                            out.close();
                        } catch (IOException e) {
                            Toast.makeText(getActivity(), e.getLocalizedMessage(), Toast.LENGTH_LONG).show();
                        }
                    }
                }
            }
        }
//                            try {
//                                FileOutputStream out = new FileOutputStream(file);
//                                image.compress(Bitmap.CompressFormat.PNG, 90, out);
//                                out.flush();
//                                out.close();
//                                return true;
//                            } catch (Exception e) {
//                                e.printStackTrace();
//                                return false;
//                            }

        /*
         */
    }

}