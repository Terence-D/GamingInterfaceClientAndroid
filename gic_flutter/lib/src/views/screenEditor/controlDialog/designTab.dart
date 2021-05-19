import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/intl/intlScreenEditor.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';
import 'package:gic_flutter/src/views/screenEditor/colorPickerDialog.dart';
import 'package:gic_flutter/src/views/screenEditor/controlDialog/imageDialog.dart';
import 'package:gic_flutter/src/views/screenEditor/gicEditControl.dart';
import 'package:path_provider/path_provider.dart';

enum dimensions { left, top, width, height }

class DesignTab extends StatefulWidget {
  final IntlScreenEditor translation;
  final GicEditControl gicEditControl;
  final int screenId;

  DesignTab({Key key, this.gicEditControl, this.translation, this.screenId})
      : super(key: key);

  @override
  DesignTabState createState() => DesignTabState();
}

class DesignTabState extends State<DesignTab> {
  String switchText;
  final List<TextEditingController> textControllers = [];

  @override
  void initState() {
    super.initState();
    switchText = widget.translation.text(ScreenEditorText.designTabColorBased);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          _imageToggle(),
          _imageButton(0),
          _colorButton(0),
          Visibility(
            visible: widget.gicEditControl.control.type ==
                    ControlViewModelType.Button ||
                widget.gicEditControl.control.type ==
                    ControlViewModelType.QuickButton ||
                widget.gicEditControl.control.type ==
                    ControlViewModelType.Toggle,
            child: Column(
              children: [
                _imageButton(1),
                _colorButton(1),
              ],
            ),
          ),
          _importButton()
        ],
      ),
    );
  }

  @override
  void dispose() {
    textControllers.forEach((element) => element.dispose());
    super.dispose();
  }

  Widget _imageToggle() {
    return Visibility(
        visible: widget.gicEditControl.control.type ==
                ControlViewModelType.Button ||
            widget.gicEditControl.control.type ==
                ControlViewModelType.QuickButton ||
            widget.gicEditControl.control.type == ControlViewModelType.Toggle,
        child: Column(
          children: [
            Text(widget.translation.text(ScreenEditorText.designTabDetails)),
            Row(
              children: [
                Text(switchText),
                Switch(
                  value: (widget.gicEditControl.control.design ==
                      ControlDesignType.Image),
                  onChanged: (value) {
                    setState(() {
                      if (widget.gicEditControl.control.design ==
                          ControlDesignType.Image) {
                        widget.gicEditControl.control.design =
                            ControlDesignType.UpDownGradient;
                        switchText = widget.translation
                            .text(ScreenEditorText.designTabColorBased);
                      } else {
                        widget.gicEditControl.control.design =
                            ControlDesignType.Image;
                        switchText = widget.translation
                            .text(ScreenEditorText.designTabImageBased);
                      }
                    });
                  },
                ),
              ],
            ),
          ],
        ));
  }

  Widget _imageButton(int index) {
    String textToDisplay = widget.translation
        .text(ScreenEditorText.designTabChooseImage); //default to image
    if (index > 0) {
      //we know its a button or a toggle
      if (widget.gicEditControl.control.type == ControlViewModelType.Toggle) {
        textToDisplay =
            widget.translation.text(ScreenEditorText.designTabToggleOnImage);
      } else {
        textToDisplay =
            widget.translation.text(ScreenEditorText.designTabPressedImage);
      }
    } else {
      if (widget.gicEditControl.control.type == ControlViewModelType.Toggle) {
        textToDisplay =
            widget.translation.text(ScreenEditorText.designTabToggleOffImage);
      } else {
        textToDisplay =
            widget.translation.text(ScreenEditorText.designTabUnpressedImage);
      }
    }
    return Visibility(
        visible: widget.gicEditControl.control.design ==
                ControlDesignType.Image ||
            widget.gicEditControl.control.type == ControlViewModelType.Image,
        child: ElevatedButton(
            onPressed: () async {
              await _pickImage(index);
            },
            child: Text(textToDisplay)));
  }

  Widget _colorButton(int index) {
    String textToDisplay = widget.translation
        .text(ScreenEditorText.designTabPrimaryColor); //default to image
    if (index > 0) {
      textToDisplay = widget.translation
          .text(ScreenEditorText.designTabSecondaryColor); //default to image
    }
    return Visibility(
        visible: widget.gicEditControl.control.design ==
            ControlDesignType.UpDownGradient,
        child: Column(
          children: [
            ElevatedButton(
                onPressed: () {
                  _pickColor(index);
                },
                child: Text(textToDisplay)),
          ],
        ));
  }

  void _pickColor(int index) {
    showDialog(
        context: context,
        builder: (_) => ColorPickerDialog(
            title: widget.translation.text(ScreenEditorText.designTabPickColor),
            pickerColor: widget.gicEditControl.control.colors[index],
            onPressedCallback: (Color color) {
              setState(() {
                widget.gicEditControl.control.design =
                    ControlDesignType.UpDownGradient;
                widget.gicEditControl.control.colors[index] = color;
              });
            }));
  }

  Future<void> _pickImage(int index) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return ImageDialog();
        }).then((value) =>
        widget.gicEditControl.control.images[index] = value
    );

    //
    // FilePickerResult result = await FilePicker.platform.pickFiles(
    //   type: FileType.custom,
    //   allowedExtensions: ['jpg', 'png', 'gif'],
    // );
    // if (result != null) {
    //   File sourceFile = File(result.files.single.path);
    //   // Directory dest = await getApplicationDocumentsDirectory();
    //   // File newFile;
    //   // String destPath;
    //   // for (int i=0; i < 1000; i++) {
    //   //   String filename = "control_${i.toString()}.${result.files.first.extension}";
    //   //   destPath = path.join(
    //   //       dest.path, "screens", widget.screenId.toString(), filename);
    //   //   newFile = File(destPath);
    //   //   if (!newFile.existsSync())
    //   //     break;
    //   // }
    //
    //   setState(() {
    //     widget.gicEditControl.control.design = ControlDesignType.Image;
    //     widget.gicEditControl.control.images[index] = sourceFile.path;
    //   });

    // }
  }

  Widget _importButton() {
    return Visibility(
      visible: widget.gicEditControl.control.design == ControlDesignType.Image,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
            onPressed: () {
              _importImage();
            },
            child: Text(widget.translation.text(ScreenEditorText.designTabImport))),
      ),
    );
  }

  Future<void> _importImage() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'gif'],
    );
    if (result != null) {
      File sourceFile = File(result.files.single.path);
      Directory filesDir = await getApplicationSupportDirectory();
      File newFile;
      String destPath;
      for (int i=0; i < 1000; i++) {
        String filename = "button_${i.toString()}.${result.files.first.extension}";
        destPath = path.join(
            filesDir.path, filename);
        newFile = File(destPath);
        if (!newFile.existsSync()) {
          break;
        }
      }
      sourceFile.copySync(newFile.path);
    }
  }
}
