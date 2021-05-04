import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gic_flutter/src/backend/models/intl/intlScreenEditor.dart';
import 'package:gic_flutter/src/backend/models/screen/fonts.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';
import 'package:gic_flutter/src/views/screenEditor/gicEditControl.dart';

class TextTab extends StatefulWidget {
  final IntlScreenEditor translation;
  final GicEditControl gicEditControl;

  TextTab({Key key, this.gicEditControl, this.translation})
      : super(key: key);

  @override
  TextTabState createState() => TextTabState();
}

class TextTabState extends State<TextTab> {
  final List<TextEditingController> textControllers = [];
  Color _pickerColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text(widget.translation.text(ScreenEditorText.textTabHeader),
              style: Theme.of(context).textTheme.headline5),
          Text(widget.translation.text(ScreenEditorText.textTabPrimaryDetails)),
          _buildText(),
          Visibility(
            child: Text(
                widget.translation.text(ScreenEditorText.textTabPrimaryToggleDetails)),
            visible: widget.gicEditControl.control.type == ControlViewModelType.Toggle,
          ),
          Visibility(
            child: _buildText(),
            visible: widget.gicEditControl.control.type == ControlViewModelType.Toggle,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                child:
                Text(widget.translation.text(ScreenEditorText.textTabFontColor)),
                onPressed: () {
                  _pickColor(context);
                },
              ),
              ElevatedButton(
                child: Text(widget.translation.text(ScreenEditorText.textTabFont)),
                onPressed: () {
                  _pickFont(context);
                },
              ),
            ],
          ),
          Text(widget.translation.text(ScreenEditorText.textTabFontSize)),
          Row(
            children: [
              Slider(
                min: 8,
                max: 512,
                value: widget.gicEditControl.control.font.size,
                onChanged: (value) {
                  setState(() {
                    widget.gicEditControl.control.font.size = value.roundToDouble();
                  });
                },
              ),
              Flexible(child: _size())
            ],
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    textControllers.forEach((element) => element.dispose());
    super.dispose();
  }

  TextField _size() {
    TextEditingController controller = new TextEditingController();
    textControllers.add(controller);
    controller.text = widget.gicEditControl.control.font.size.toString();
    controller.addListener(() {
      widget.gicEditControl.control.font.size = double.parse(controller.text);
    });

    return TextField(
        controller: controller, keyboardType: TextInputType.number);
  }

  void _changeColor(Color color) {
    _pickerColor = color;
  }

  void _pickColor(BuildContext context) {
    if (widget.gicEditControl.control.font.color != null)
      _pickerColor = widget.gicEditControl.control.font.color;
    else
      _pickerColor = Colors.blue;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(widget.translation.text(ScreenEditorText.backgroundColor)),
        content: SingleChildScrollView(
            child: ColorPicker(
          pickerColor: _pickerColor,
          onColorChanged: _changeColor,
          showLabel: true,
          enableAlpha: false,
        )),
        actions: <Widget>[
          TextButton(
            child: Text(widget.translation.text(ScreenEditorText.ok)),
            onPressed: () {
              Navigator.of(context).pop();
              widget.gicEditControl.control.font.color = _pickerColor;
            },
          ),
        ],
      ),
    );
  }

  void _pickFont(BuildContext context) {
    List<Widget> fontButtons = [];
    Fonts.list().forEach((key, value) {
      fontButtons.add (
        TextButton(
          onPressed: () {
            widget.gicEditControl.control.font.family = key;
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
    TextEditingController controller = new TextEditingController();
    textControllers.add(controller);
    controller.text = widget.gicEditControl.control.text;
    controller.addListener(() {
      widget.gicEditControl.control.text = controller.text;
    });

    return TextField(
      controller: controller,
    );
  }
}
