import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/intl/intlScreenEditor.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';
import 'package:gic_flutter/src/views/screenEditor/colorPickerDialog.dart';
import 'package:gic_flutter/src/views/screenEditor/gicEditControl.dart';

enum dimensions { left, top, width, height }

class ImageTab extends StatefulWidget {
  final IntlScreenEditor translation;
  final GicEditControl gicEditControl;

  ImageTab({Key key, this.gicEditControl, this.translation}) : super(key: key);

  @override
  ImageTabState createState() => ImageTabState();
}

class ImageTabState extends State<ImageTab> {
  final List<TextEditingController> textControllers = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          _imageToggle(),
          _imageButton(),
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
                _imageButton(),
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

  Widget _imageButton() {
    return Visibility(
        visible:
            widget.gicEditControl.control.design == ControlDesignType.Image,
        child: ElevatedButton(
            onPressed: () {
              setState(() {});
            },
            child: Text("Image")));
  }

  Widget _colorButton(int index) {
    return Visibility(
        visible: widget.gicEditControl.control.design ==
            ControlDesignType.UpDownGradient,
        child: ElevatedButton(
            onPressed: () {
              _pickBackgroundColor(index);
            },
            child: Text("Color")));
  }

  void _pickBackgroundColor(int index) {
    showDialog(
        context: context,
        builder: (_) => ColorPickerDialog(
            title: "test",
            pickerColor: widget.gicEditControl.control.colors[index],
            onPressedCallback: (Color color) {
              setState(() {
                widget.gicEditControl.control.colors[index] = color;
              });
            }));
  }
}
