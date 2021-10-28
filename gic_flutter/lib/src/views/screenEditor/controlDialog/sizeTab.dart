import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/intl/intlScreenEditor.dart';
import 'package:gic_flutter/src/backend/models/screen/controlDefaults.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';
import 'package:gic_flutter/src/views/screenEditor/controlDialog/baseTab.dart';
import 'package:gic_flutter/src/views/screenEditor/gicEditControl.dart';

enum dimensions { left, top, width, height }

class SizeTab extends BaseTab {
  final IntlScreenEditor translation;
  final ControlDefaults defaultControls;
  final GicEditControl gicEditControl;

  SizeTab({Key key, this.gicEditControl, this.translation, screenId, this.defaultControls})
      : super(
      key: key,
      defaultControls: defaultControls,
      gicEditControl: gicEditControl,
      translation: translation,
      screenId: screenId);


  @override
  SizeTabState createState() => SizeTabState();
}

class SizeTabState extends BaseTabState {
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
              Text(widget.translation.text(ScreenEditorText.sizeTabHeader),
                  style: Theme.of(context).textTheme.headline5),
              Text(widget.translation.text(ScreenEditorText.sizeTabDetails)),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                    onPressed: () {
                      _applyDefault();
                    },
                    child:
                    Text(widget.translation
                        .text(ScreenEditorText.applyDefaults))),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _size(dimensions.left),
                  _size(dimensions.top),
                  _size(dimensions.width),
                  _size(dimensions.height),
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

  Widget _size(dimensions dimension) {
    String text = "";
    TextEditingController controller = TextEditingController();
    textControllers.add(controller);
    Icon icon;
    Slider slider;
    switch (dimension) {
      case dimensions.left:
        if (widget.gicEditControl.control.left < 8) widget.gicEditControl.control.left = 8;
        controller.text =
            widget.gicEditControl.control.left.toInt().toString();
        text = widget.translation.text(ScreenEditorText.sizeTabLeft);
        controller.addListener(() {
          widget.gicEditControl.control.left = double.parse(controller.text);
        });
        icon = Icon(Icons.west, size: 26.0);
        slider = Slider(
          min: 8,
          max: 1024,
          value: widget.gicEditControl.control.left,
          onChanged: (value) {
            setState(() {
              widget.gicEditControl.control.left =
                  value.roundToDouble();
            });
          },
        );
        break;
      case dimensions.top:
        if (widget.gicEditControl.control.top < 8) widget.gicEditControl.control.top = 8;
        controller.text =
            widget.gicEditControl.control.top.toInt().toString();
        text = widget.translation.text(ScreenEditorText.sizeTabTop);
        controller.addListener(() {
          widget.gicEditControl.control.top = double.parse(controller.text);
        });
        icon = Icon(Icons.north, size: 26.0);
        slider = Slider(
          min: 8,
          max: 1024,
          value: widget.gicEditControl.control.top,
          onChanged: (value) {
            setState(() {
              widget.gicEditControl.control.top =
                  value.roundToDouble();
            });
          },
        );
        break;
      case dimensions.width:
        if (widget.gicEditControl.control.width < 8) widget.gicEditControl.control.width = 8;
        controller.text = widget.gicEditControl.control.width.toInt().toString();
        text = widget.translation.text(ScreenEditorText.sizeTabWidth);
        controller.addListener(() {
          widget.gicEditControl.control.width = double.parse(controller.text);
        });
        icon = Icon(Icons.east, size: 26.0);
        slider = Slider(
          min: 8,
          max: 1024,
          value: widget.gicEditControl.control.width,
          onChanged: (value) {
            setState(() {
              widget.gicEditControl.control.width =
                  value.roundToDouble();
            });
          },
        );
        break;
      case dimensions.height:
        if (widget.gicEditControl.control.height < 8) widget.gicEditControl.control.height = 8;
        controller.text = widget.gicEditControl.control.height.toInt().toString();
        text = widget.translation.text(ScreenEditorText.sizeTabHeight);
        controller.addListener(() {
          widget.gicEditControl.control.height = double.parse(controller.text);
        });
        icon = Icon(Icons.south, size: 26.0);
        slider = Slider(
          min: 8,
          max: 1024,
          value: widget.gicEditControl.control.height,
          onChanged: (value) {
            setState(() {
              widget.gicEditControl.control.height =
                  value.roundToDouble();
            });
          },
        );
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(flex: 1, child: icon),
          Expanded(flex: 1, child: Text(text)),
          Expanded(
            flex: 1,
            child: TextField(
                controller: controller, keyboardType: TextInputType.number),
          ),
          Expanded(
            flex: 3,
            child: slider,
          )      ],
      ),
    );
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
}
