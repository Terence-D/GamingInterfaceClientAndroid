import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/intl/intlScreenEditor.dart';
import 'package:gic_flutter/src/backend/models/screen/controlDefaults.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';
import 'package:gic_flutter/src/views/screenEditor/colorPickerDialog.dart';
import 'package:gic_flutter/src/views/screenEditor/controlDialog/baseTab.dart';
import 'package:gic_flutter/src/views/screenEditor/controlDialog/imageDialog.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class DesignTab extends BaseTab {
  final ControlDefaults defaultControls;
  final IntlScreenEditor translation;

  DesignTab({Key key, gicEditControl, this.translation, screenId, this.defaultControls})
      : super(
            key: key,
            defaultControls: defaultControls,
            gicEditControl: gicEditControl,
            translation: translation,
            screenId: screenId);

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

    return SingleChildScrollView(
      child: Container(
        child: LayoutBuilder(
            builder: (BuildContext ctx, BoxConstraints constraints) {
          return Column(
            children: [
              Text(widget.translation.text(ScreenEditorText.designTabHeader),
                  style: Theme.of(context).textTheme.headline5),
              Text(detailsText),
              Visibility(
                  visible: widget.gicEditControl.control.type !=
                      ControlViewModelType.Image,
                  child: Column(children: [
                    _imageToggleAndDefault(),
                    _designButtons(),
                  ])),
              preview(constraints)
            ],
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    textControllers.forEach((element) => element.dispose());
    super.dispose();
  }

  Widget _imageToggleAndDefault() {
    if (widget.gicEditControl.control.design == ControlDesignType.UpDownGradient) {
      switchText = widget.translation.text(ScreenEditorText.designTabColorBased);
    } else {
      switchText =
          widget.translation.text(ScreenEditorText.designTabImageBased);
    }
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
            ElevatedButton(
                onPressed: () {
                  _applyDefault();
                },
                child:
                Text(widget.translation
                    .text(ScreenEditorText.applyDefaults)))
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
        if (value != null)
          widget.gicEditControl.control.images[index] = value;
      });
    });
  }

  Widget _importButton() {
    return ElevatedButton(
        onPressed: () {
          _importImage();
        },
        child:
            Text(widget.translation.text(ScreenEditorText.designTabImport)));
  }

  Future<void> _importImage() async {
    await FilePicker.platform.clearTemporaryFiles();
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
        setState(()  {
          if (widget.gicEditControl.control.images.isEmpty) {
            widget.gicEditControl.control.images.add(newFile.path);
          } else {
            widget.gicEditControl.control.images[0] = newFile.path;
          }
        });
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

  _applyDefault() {
    switch (widget.gicEditControl.control.type) {
      case ControlViewModelType.Button:
        setState(() {
          widget.gicEditControl.control.design = widget.defaultControls.defaultButton.design;
          widget.gicEditControl.control.images.clear();
          for (int i=0; i < widget.defaultControls.defaultButton.images.length; i++)
            widget.gicEditControl.control.images.add(widget.defaultControls.defaultButton.images[i]);
          widget.gicEditControl.control.colors.clear();
          for (int i=0; i < widget.defaultControls.defaultButton.colors.length; i++)
            widget.gicEditControl.control.colors.add(widget.defaultControls.defaultButton.colors[i]);
        });
        break;
      case ControlViewModelType.Text:
        // TODO: Handle this case.
        break;
      case ControlViewModelType.Image:
        // TODO: Handle this case.
        break;
      case ControlViewModelType.Toggle:
        // TODO: Handle this case.
        break;
      case ControlViewModelType.QuickButton:
        // TODO: Handle this case.
        break;
    }
  }

  _designButtons() {
    List<Widget> buttons = [];
    if (widget.gicEditControl.control.design == ControlDesignType.Image) {
      buttons.add(_imageButton(0));
      buttons.add(_imageButton(1));
    } else {
      buttons.add(_colorButton(0));
      buttons.add(_colorButton(1));
    }

    if ( widget.gicEditControl.control.type !=
            ControlViewModelType.Text)
        buttons.add(_importButton());

    Orientation orientation = MediaQuery.of(context).orientation;
    if (orientation == Orientation.portrait) {
      return Column(children:buttons, mainAxisAlignment: MainAxisAlignment.spaceEvenly);
    } else {
      return Row(children:buttons, mainAxisAlignment: MainAxisAlignment.spaceEvenly);
    }
  }
}
