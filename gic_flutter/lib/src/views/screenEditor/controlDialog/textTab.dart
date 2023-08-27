import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/intl/intlScreenEditor.dart';
import 'package:gic_flutter/src/backend/models/screen/controlDefaults.dart';
import 'package:gic_flutter/src/backend/models/screen/fonts.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';
import 'package:gic_flutter/src/views/screenEditor/colorPickerDialog.dart';
import 'package:gic_flutter/src/views/screenEditor/controlDialog/baseTab.dart';
import 'package:gic_flutter/src/views/screenEditor/gicEditControl.dart';

class TextTab extends BaseTab {
  final IntlScreenEditor translation;
  final ControlDefaults defaultControls;
  final GicEditControl gicEditControl;

  TextTab({Key? key, required this.gicEditControl, required this.translation, screenId, required this.defaultControls})
      : super(
      key: key,
      defaultControls: defaultControls,
      gicEditControl: gicEditControl,
      translation: translation,
      screenId: screenId);

  @override
  TextTabState createState() => TextTabState();
}

class TextTabState extends BaseTabState {
  final List<TextEditingController> textControllers = [];

  @override
  Widget build(BuildContext context) {
    pixelRatio = MediaQuery.of(context).devicePixelRatio;
    return SingleChildScrollView(
      child: Container(
        child: LayoutBuilder(
            builder: (BuildContext ctx, BoxConstraints constraints) {
          return Column(
            children: [
              Text(widget.translation.text(ScreenEditorText.textTabHeader),
                  style: Theme.of(context).textTheme.headline5),
              Text(widget.translation
                  .text(ScreenEditorText.textTabPrimaryDetails)),
              Row(
                children: [
                  Flexible(child: _buildText()),
                  ElevatedButton(
                      onPressed: () {
                        _applyDefault();
                      },
                      child:
                      Text(widget.translation
                          .text(ScreenEditorText.applyDefaults)))

                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    child: Text(widget.translation
                        .text(ScreenEditorText.textTabFontColor)),
                    onPressed: () {
                      _pickColor();
                    },
                  ),
                  ElevatedButton(
                    child: Text(
                        widget.translation.text(ScreenEditorText.textTabFont)),
                    onPressed: () {
                      _pickFont(context);
                    },
                  ),
                ],
              ),
              Text(widget.translation.text(ScreenEditorText.textTabFontSize),
                  style: Theme.of(context).textTheme.headline5),
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Slider(
                      min: 8,
                      max: 512,
                      value: widget.gicEditControl.control.font.size,
                      onChanged: (value) {
                        setState(() {
                          widget.gicEditControl.control.font.size =
                              value.roundToDouble();
                        });
                      },
                    ),
                  ),
                  Expanded(
                      flex: 1,
                      child: _size())
                ],
              ),
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

  TextField _size() {
    TextEditingController controller = TextEditingController();
    textControllers.add(controller);
    controller.text = widget.gicEditControl.control.font.size.toInt().toString();
    controller.addListener(() {
      widget.gicEditControl.control.font.size = double.parse(controller.text);
    });

    return TextField(
        controller: controller, keyboardType: TextInputType.number);
  }

  void _pickedColor(Color color) {
    setState(() {
      widget.gicEditControl.control.font.color = color;
    });
  }

  void _pickColor() {
    showDialog(
        context: context,
        builder: (_) => ColorPickerDialog(
              title: widget.translation.text(ScreenEditorText.backgroundColor),
              pickerColor: widget.gicEditControl.control.font.color,
              onPressedCallback: _pickedColor,
            ));
  }

  void _pickFont(BuildContext context) {
    List<Widget> fontButtons = [];
    Fonts.list().forEach((key, value) {
      fontButtons.add(
        TextButton(
          onPressed: () {
            setState(() {
              widget.gicEditControl.control.font.family = key;
            });
            Navigator.pop(context);
          },
          child: Text(
            value,
            style: TextStyle(fontFamily: key, fontSize: 36),
          ),
        ),
      );
    });

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              height: 300,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: fontButtons,
                ),
              ),
            ),
          );
        });
  }

  //show text editing widget for the supplied index
  TextField _buildText() {
    TextEditingController controller = TextEditingController();
    textControllers.add(controller);
    controller.text = widget.gicEditControl.control.text;
    controller.addListener(() {
      widget.gicEditControl.control.text = controller.text;
    });

    return TextField(
      controller: controller,
    );
  }

  _applyDefault() {
    switch (widget.gicEditControl.control.type) {
      case ControlViewModelType.Button:
      case ControlViewModelType.QuickButton:
        setState(() {
          widget.gicEditControl.control.font.color = widget.defaultControls!.defaultButton.font.color;
          widget.gicEditControl.control.font.family = widget.defaultControls!.defaultButton.font.family;
          widget.gicEditControl.control.font.size = widget.defaultControls!.defaultButton.font.size;
        });
        break;
      case ControlViewModelType.Text:
        setState(() {
          widget.gicEditControl.control.font.color = widget.defaultControls!.defaultText.font.color;
          widget.gicEditControl.control.font.family = widget.defaultControls!.defaultText.font.family;
          widget.gicEditControl.control.font.size = widget.defaultControls!.defaultText.font.size;
        });
        break;
      case ControlViewModelType.Toggle:
        setState(() {
          widget.gicEditControl.control.font.color = widget.defaultControls!.defaultToggle.font.color;
          widget.gicEditControl.control.font.family = widget.defaultControls!.defaultToggle.font.family;
          widget.gicEditControl.control.font.size = widget.defaultControls!.defaultToggle.font.size;
        });
        break;
      case ControlViewModelType.Image:
        break;
    }
  }

}
