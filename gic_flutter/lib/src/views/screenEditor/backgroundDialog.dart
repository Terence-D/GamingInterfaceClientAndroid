import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/intl/intlScreenEditor.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/screenViewModel.dart';
import 'package:gic_flutter/src/views/screenEditor/colorPickerDialog.dart';
import 'package:gic_flutter/src/views/screenEditor/settingsDialog/dialogButton.dart';
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
  IntlScreenEditor translation;
  ScreenViewModel screenViewModel;

  _BackgroundDialogState(this.translation, this.screenViewModel);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(translation.text(ScreenEditorText.backgroundMenu)),
      children: [
        DialogButton(
            icon: Icons.image,
            color: Colors.blue,
            text: translation.text(ScreenEditorText.backgroundImage),
            onPressed: () {
              _pickBackgroundImage();
            }),
        DialogButton(
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
      String destPath = path.join(
          dest.path, "screens", screenViewModel.screenId.toString(), path.basename(file.path));
      File(screenViewModel.backgroundPath).deleteSync();
      File newFile = File(file.path).copySync(destPath);
      setState(() {
        screenViewModel.backgroundPath = newFile.path;

        Navigator.pop(context, true);
      });
    }
  }

  void _pickedColor(Color color) {
    screenViewModel.backgroundColor = color.withAlpha(255);
    screenViewModel.backgroundPath = null;
    Navigator.pop(context);
  }

  void _pickBackgroundColor() {
    showDialog(
        context: context,
        builder: (_) => ColorPickerDialog(
              title: translation.text(ScreenEditorText.backgroundColor),
              pickerColor: screenViewModel.backgroundColor,
              onPressedCallback: _pickedColor,
            ));
  }
}
