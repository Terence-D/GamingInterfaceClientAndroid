import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/intl/intlScreenEditor.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';
import 'package:gic_flutter/src/views/screenEditor/dialogItem.dart';
import 'package:gic_flutter/src/views/screenEditor/screenEditor.dart';

class SettingsDialog {
  static Widget display(
      BuildContext context, ScreenEditorState screenEditorState) {
    IntlScreenEditor translation = IntlScreenEditor(context);

    return SimpleDialog(
      title: Text(translation.text(ScreenEditorText.menu)),
      children: [
        DialogItem(
          icon: Icons.smart_button,
          color: Colors.orange,
          text: translation.text(ScreenEditorText.addButton),
          onPressed: () {
            screenEditorState.addControl(ControlViewModelType.Button);
            Navigator.pop(context, true);
          },
        ),
        DialogItem(
          icon: Icons.toggle_off_outlined,
          color: Colors.green,
          text: translation.text(ScreenEditorText.addToggle),
          onPressed: () {
            screenEditorState.addControl(ControlViewModelType.Toggle);
            Navigator.pop(context, true);
          },
        ),
        DialogItem(
          icon: Icons.text_fields,
          color: Colors.blue,
          text: translation.text(ScreenEditorText.addText),
          onPressed: () {
            screenEditorState.addControl(ControlViewModelType.Text);
            Navigator.pop(context, true);
          },
        ),
        DialogItem(
          icon: Icons.image,
          color: Colors.red,
          text: translation.text(ScreenEditorText.addImage),
          onPressed: () {
            screenEditorState.addControl(ControlViewModelType.Image);
            Navigator.pop(context, true);
          },
        ),
        DialogItem(
          icon: Icons.color_lens,
          color: Colors.yellow,
          text: translation.text(ScreenEditorText.setBackground),
          onPressed: () {
            screenEditorState.showBackgroundDialog();
          },
        ),
        DialogItem(
          icon: Icons.grid_on,
          color: Colors.grey,
          text: translation.text(ScreenEditorText.setGrid),
          onPressed: () {},
        ),
        DialogItem(
          icon: Icons.save,
          color: Colors.deepPurple,
          text: translation.text(ScreenEditorText.save),
          onPressed: () {
            screenEditorState.tapSave();
            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }
}
