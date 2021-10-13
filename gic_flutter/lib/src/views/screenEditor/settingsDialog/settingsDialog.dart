import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/intl/intlScreenEditor.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';
import 'package:gic_flutter/src/views/screenEditor/screenEditor.dart';
import 'package:gic_flutter/src/views/screenEditor/settingsDialog/dialogButton.dart';
import 'package:gic_flutter/src/views/screenEditor/settingsDialog/dialogSlider.dart';

class SettingsDialog {
  static Widget display(
      BuildContext context, ScreenEditorState screenEditorState) {
    IntlScreenEditor translation = IntlScreenEditor(context);

    return SimpleDialog(
      title: Text(translation.text(ScreenEditorText.menu)),
      elevation: 5,
      children: [
        DialogButton(
          icon: Icons.smart_button,
          color: Colors.orange,
          text: translation.text(ScreenEditorText.addButton),
          onPressed: () {
            screenEditorState.addControl(ControlViewModelType.Button);
            Navigator.pop(context, true);
          },
        ),
        DialogButton(
          icon: Icons.toggle_off_outlined,
          color: Colors.green,
          text: translation.text(ScreenEditorText.addToggle),
          onPressed: () {
            screenEditorState.addControl(ControlViewModelType.Toggle);
            Navigator.pop(context, true);
          },
        ),
        DialogButton(
          icon: Icons.text_fields,
          color: Colors.blue,
          text: translation.text(ScreenEditorText.addText),
          onPressed: () {
            screenEditorState.addControl(ControlViewModelType.Text);
            Navigator.pop(context, true);
          },
        ),
        DialogButton(
          icon: Icons.image,
          color: Colors.red,
          text: translation.text(ScreenEditorText.addImage),
          onPressed: () {
            screenEditorState.addControl(ControlViewModelType.Image);
            Navigator.pop(context, true);
          },
        ),
        Divider(
          height: 10,
          thickness: 5,
          indent: 20,
          endIndent: 20,
        ),
        DialogButton(
          icon: Icons.color_lens,
          color: Colors.yellow,
          text: translation.text(ScreenEditorText.setBackground),
          onPressed: () {
            screenEditorState.showBackgroundDialog();
          },
        ),
        DialogSlider(
          icon: Icons.grid_on,
          color: Colors.grey,
          text: translation.text(ScreenEditorText.setGrid),
          originalValue: screenEditorState.gridSize,
          onChanged: (double newValue) {
            screenEditorState.gridChangeListener(newValue);
          },
        ),
        Divider(
          height: 10,
          thickness: 5,
          indent: 20,
          endIndent: 20,
        ),
        DialogButton(
          icon: Icons.save,
          color: Colors.tealAccent,
          text: translation.text(ScreenEditorText.save),
          onPressed: () {
            screenEditorState.tapSave();
            Navigator.pop(context, true);
          },
        ),
        DialogButton(
          icon: Icons.help,
          color: Colors.amber,
          text: translation.text(ScreenEditorText.helpDialogTitle),
          onPressed: () {
            screenEditorState.tapHelp();
          },
        ),
      ],
    );
  }
}
