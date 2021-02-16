import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/intl/intlScreenEditor.dart';

class SimpleDialogItem extends StatelessWidget {
  const SimpleDialogItem(
      {Key key, this.icon, this.color, this.text, this.onPressed})
      : super(key: key);

  final IconData icon;
  final Color color;
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 36.0, color: color),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 16.0),
            child: Text(text),
          ),
        ],
      ),
    );
  }
}

class SettingsDialog {
  static Widget display(BuildContext context) {
    IntlScreenEditor translation = new IntlScreenEditor(context);

    return SimpleDialog(
      title: Text('Menu'),
      children: [
        SimpleDialogItem(
          icon: Icons.smart_button,
          color: Colors.orange,
          text: translation.text(ScreenEditorText.addButton),
          onPressed: () {

          },
        ),
        SimpleDialogItem(
          icon: Icons.toggle_off_outlined,
          color: Colors.green,
          text: translation.text(ScreenEditorText.addToggle),
          onPressed: () {

          },
        ),
        SimpleDialogItem(
          icon: Icons.text_fields,
          color: Colors.blue,
          text: translation.text(ScreenEditorText.addText),
          onPressed: () {

          },
        ),
        SimpleDialogItem(
          icon: Icons.image,
          color: Colors.red,
          text: translation.text(ScreenEditorText.addImage),
          onPressed: () {

          },
        ),
        SimpleDialogItem(
          icon: Icons.color_lens,
          color: Colors.yellow,
          text: translation.text(ScreenEditorText.setBackground),
          onPressed: () {

          },
        ),
        SimpleDialogItem(
          icon: Icons.grid_on,
          color: Colors.grey,
          text: translation.text(ScreenEditorText.setGrid),
          onPressed: () {

          },
        ),
        SimpleDialogItem(
          icon: Icons.save,
          color: Colors.deepPurple,
          text: translation.text(ScreenEditorText.save),
          onPressed: () {

          },
        ),
      ],
    );
  }
}