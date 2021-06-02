import 'dart:io';

import 'package:gic_flutter/src/views/screenEditor/controlDialog/baseTab.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/intl/intlScreenEditor.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';
import 'package:gic_flutter/src/views/screenEditor/colorPickerDialog.dart';
import 'package:gic_flutter/src/views/screenEditor/controlDialog/imageDialog.dart';
import 'package:path_provider/path_provider.dart';

class DesignTab extends BaseTab {
  DesignTab({Key key, gicEditControl, translation, screenId})
      : super(key: key, gicEditControl: gicEditControl, translation: translation, screenId: screenId);

  @override
  DesignTabState createState() => DesignTabState();
}

class DesignTabState extends BaseTabState {
  String switchText;
  final List<TextEditingController> textControllers = [];

  @override
  void initState() {
    super.initState();
    switchText = widget.translation.text(ScreenEditorText.designTabColorBased);
  }

  @override
  Widget build(BuildContext context) {
    pixelRatio = MediaQuery.of(context).devicePixelRatio;
    String detailsText =
        widget.translation.text(ScreenEditorText.designTabDetails);
    if (widget.gicEditControl.control.type == ControlViewModelType.Image) {
      detailsText =
          widget.translation.text(ScreenEditorText.designTabImageDetails);
    }

    return Container(
      child: Column(
        children: [
          Text(widget.translation.text(ScreenEditorText.designTabHeader),
              style: Theme.of(context).textTheme.headline5),
          Text(detailsText),
          Visibility(
              visible: widget.gicEditControl.control.type !=
                  ControlViewModelType.Image,
              child: Column(children: [
                _imageToggle(),
                _imageButton(0),
                _imageButton(1),
              ])),
          Visibility(
              visible: widget.gicEditControl.control.type !=
                      ControlViewModelType.Image &&
                  widget.gicEditControl.control.design ==
                      ControlDesignType.UpDownGradient,
              child: Column(children: [
                _colorButton(0),
                _colorButton(1),
              ])),
          Visibility(
              visible: widget.gicEditControl.control.type !=
                  ControlViewModelType.Text,
              child: Column(children: [_importButton()])),
          preview(),
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
    return Column(
      children: [
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
    );
  }

  Widget _imageButton(int index) {
    String textToDisplay;
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
      visible: widget.gicEditControl.control.design == ControlDesignType.Image,
      child: ElevatedButton(
          onPressed: () async {
            await _pickImage(index);
          },
          child: Text(textToDisplay)),
    );
  }

  Widget _colorButton(int index) {
    String textToDisplay = widget.translation
        .text(ScreenEditorText.designTabPrimaryColor); //default to image
    if (index > 0) {
      textToDisplay = widget.translation
          .text(ScreenEditorText.designTabSecondaryColor); //default to image
    }
    return Column(
      children: [
        ElevatedButton(
            onPressed: () {
              _pickColor(index);
            },
            child: Text(textToDisplay)),
      ],
    );
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
        }).then((value) {
      setState(() {
        widget.gicEditControl.control.images[index] = value;
      });
    });
  }

  Widget _importButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
          onPressed: () {
            _importImage();
          },
          child:
              Text(widget.translation.text(ScreenEditorText.designTabImport))),
    );
  }

  Future<void> _importImage() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'gif'],
    );
    if (result != null) {
      File sourceFile = File(result.files.single.path);
      File newFile;
      if (widget.gicEditControl.control.type == ControlViewModelType.Image) {
        newFile = await _getDestinationName(
            result, "${widget.screenId.toString()}_control_");
        if (widget.gicEditControl.control.images.isEmpty) {
          widget.gicEditControl.control.images.add(newFile.path);
        } else {
          widget.gicEditControl.control.images[0] = newFile.path;
        }
      } else {
        newFile = await _getDestinationName(result, "button_");
      }
      sourceFile.copySync(newFile.path);
    }
  }

  Future<File> _getDestinationName(
      FilePickerResult result, String filePrefix) async {
    Directory filesDir = await getApplicationSupportDirectory();
    File newFile;
    String destPath;
    for (int i = 0; i < 1000; i++) {
      String filename =
          "$filePrefix${i.toString()}.${result.files.first.extension}";
      destPath = path.join(filesDir.path, filename);
      newFile = File(destPath);
      if (!newFile.existsSync()) {
        break;
      }
    }
    return newFile;
  }
}
