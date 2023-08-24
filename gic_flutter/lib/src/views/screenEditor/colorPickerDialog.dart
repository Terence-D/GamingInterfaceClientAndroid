import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorDialog {
  static Color? pickerColor;

  static show(BuildContext context, changeColorCallback, onPressedCallback) {
    return showDialog(
      context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Pick a color!'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: pickerColor!,
                onColorChanged: changeColorCallback,
                showLabel: true,
                pickerAreaHeightPercent: 0.8,
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Got it'),
                onPressed: onPressedCallback,
              ),
            ],
          );
        },
    );
  }
}

class ColorPickerDialog extends StatefulWidget {
  final Function(Color color)? onPressedCallback;
  final String? title;
  final Color? pickerColor;

  const ColorPickerDialog(
      {Key? key, this.title, this.onPressedCallback, this.pickerColor})
      : super(key: key);

  @override
  _ColorPickerDialogState createState() => _ColorPickerDialogState(pickerColor!);
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  Color pickerColor;

  _ColorPickerDialogState(this.pickerColor) {
    if (pickerColor == null) {
      pickerColor = Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title!),
      content: SingleChildScrollView(
          child: ColorPicker(
        pickerColor: pickerColor,
        onColorChanged: (Color color) {
          setState(() => pickerColor = color);
        },
        showLabel: true,
        enableAlpha: false,
      )),
      actions: <Widget>[
        TextButton(
            child: Text("OK"),
            onPressed: () {
              widget.onPressedCallback!(pickerColor);
              Navigator.pop(context);
            }),
      ],
    );
  }
}
