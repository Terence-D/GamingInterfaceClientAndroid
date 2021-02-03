import 'package:flutter/material.dart';

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
    return SimpleDialog(
      title: Text('Menu'),
      children: [
        SimpleDialogItem(
          icon: Icons.smart_button,
          color: Colors.orange,
          text: 'Add Button',
          onPressed: () {

          },
        ),
        SimpleDialogItem(
          icon: Icons.toggle_off_outlined,
          color: Colors.green,
          text: 'Add Toggle',
          onPressed: () {

          },
        ),
        SimpleDialogItem(
          icon: Icons.text_fields,
          color: Colors.blue,
          text: 'Add Text',
          onPressed: () {

          },
        ),
        SimpleDialogItem(
          icon: Icons.image,
          color: Colors.red,
          text: 'Add Image',
          onPressed: () {

          },
        ),
        SimpleDialogItem(
          icon: Icons.settings,
          color: Colors.grey,
          text: 'Settings',
          onPressed: () {

          },
        ),
      ],
    );
  }
}