import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gic_flutter/src/backend/models/intl/intlScreenEditor.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/screenViewModel.dart';
import 'package:gic_flutter/src/views/screenEditor/dialogItem.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class BackgroundDialog extends StatefulWidget {
  final IntlScreenEditor translation;
  final ScreenViewModel screenViewModel;

  const BackgroundDialog({Key key, this.translation, this.screenViewModel})
      : super(key: key);

  @override
  _BackgroundDialogState createState() =>
      _BackgroundDialogState(translation, screenViewModel);
}

class _BackgroundDialogState extends State<BackgroundDialog> {
  Color _pickerColor = Color(0xff443a49);
  IntlScreenEditor translation;
  ScreenViewModel screenViewModel;

  _BackgroundDialogState(this.translation, this.screenViewModel);

  @override
  Widget build(BuildContext context) {
    _pickerColor = screenViewModel.backgroundColor;
    return SimpleDialog(
      title: Text(translation.text(ScreenEditorText.backgroundMenu)),
      children: [
        DialogItem(
            icon: Icons.image,
            color: Colors.blue,
            text: translation.text(ScreenEditorText.backgroundImage),
            onPressed: () {
              _pickBackgroundImage();
            }),
        DialogItem(
          icon: Icons.color_lens,
          color: Colors.green,
          text: translation.text(ScreenEditorText.backgroundColor),
          onPressed: () {
            _pickBackgroundColor();
          },
        ),
      ],
    );
  }

  void _pickBackgroundImage() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'gif'],
    );
    if (result != null) {
      PlatformFile file = result.files.first;
      Directory dest = await getApplicationDocumentsDirectory();
      String filename = path.basename(file.path);
      String destPath = path.join(
          dest.path, "screens", screenViewModel.screenId.toString(), filename);
      File newFile = File(file.path).copySync(destPath);
      setState(() {
        screenViewModel.backgroundPath = newFile.path;
        Navigator.pop(context, true);
      });
    }
  }

  _changeColor(Color color) {
    setState(() => _pickerColor = color);
  }

  void _pickBackgroundColor() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(translation.text(ScreenEditorText.backgroundColor)),
        content: SingleChildScrollView(
            child: ColorPicker(
          pickerColor: _pickerColor,
          onColorChanged: _changeColor,
          showLabel: true,
          enableAlpha: false,
        )),
        actions: <Widget>[
          TextButton(
            child: Text(translation.text(ScreenEditorText.ok)),
            onPressed: () {
              setState(() {
                screenViewModel.backgroundColor = _pickerColor;
                screenViewModel.backgroundPath = null;
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
