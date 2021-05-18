import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/intl/intlScreenEditor.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';
import 'package:gic_flutter/src/views/screenEditor/colorPickerDialog.dart';
import 'package:gic_flutter/src/views/screenEditor/gicEditControl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

enum dimensions { left, top, width, height }

class DesignTab extends StatefulWidget {
  final IntlScreenEditor translation;
  final GicEditControl gicEditControl;
  final int screenId;

  DesignTab({Key key, this.gicEditControl, this.translation, this.screenId}) : super(key: key);

  @override
  DesignTabState createState() => DesignTabState();
}

class DesignTabState extends State<DesignTab> {
  final List<TextEditingController> textControllers = [];

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
        child: Row(
          children: [
            Text("test"),
            Switch(
              value: (widget.gicEditControl.control.design ==
                  ControlDesignType.Image),
              onChanged: (value) {
                setState(() {
                  if (widget.gicEditControl.control.design ==
                      ControlDesignType.Image)
                    widget.gicEditControl.control.design =
                        ControlDesignType.UpDownGradient;
                  else
                    widget.gicEditControl.control.design =
                        ControlDesignType.Image;
                });
              },
            ),
          ],
        ));
  }

  Widget _imageButton(int index) {
    return Visibility(
        visible:
            widget.gicEditControl.control.design == ControlDesignType.Image,
        child: ElevatedButton(
            onPressed: () async {
                await _pickImage(index);
            },
            child: Text("Image")));
  }

  Widget _colorButton(int index) {
    return Visibility(
        visible: widget.gicEditControl.control.design ==
            ControlDesignType.UpDownGradient,
        child: ElevatedButton(
            onPressed: () {
              _pickColor(index);
            },
            child: Text("Color")));
  }

  void _pickColor(int index) {
    showDialog(
        context: context,
        builder: (_) => ColorPickerDialog(
            title: "test",
            pickerColor: widget.gicEditControl.control.colors[index],
            onPressedCallback: (Color color) {
              setState(() {
                widget.gicEditControl.control.design = ControlDesignType.UpDownGradient;
                widget.gicEditControl.control.colors[index] = color;
              });
            }));
  }

  Future<void> _pickImage(int index) async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'gif'],
    );
    if (result != null) {
      PlatformFile file = result.files.first;
      Directory dest = await getApplicationDocumentsDirectory();
      String filename = path.basename(file.path);
      String destPath = path.join(
          dest.path, "files", widget.screenId.toString(), filename);
      File newFile = File(file.path).copySync(destPath);
      setState(() {
        widget.gicEditControl.control.design = ControlDesignType.Image;
        widget.gicEditControl.control.images[index] = newFile.path;
      });
    }
  }
}
