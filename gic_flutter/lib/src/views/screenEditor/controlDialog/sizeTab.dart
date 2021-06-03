import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/intl/intlScreenEditor.dart';
import 'package:gic_flutter/src/views/screenEditor/controlDialog/baseTab.dart';
import 'package:gic_flutter/src/views/screenEditor/gicEditControl.dart';

enum dimensions { left, top, width, height }

class SizeTab extends BaseTab {
  final IntlScreenEditor translation;
  final GicEditControl gicEditControl;

  SizeTab({Key key, this.gicEditControl, this.translation}) : super(key: key);

  @override
  SizeTabState createState() => SizeTabState();
}

class SizeTabState extends BaseTabState {
  final List<TextEditingController> textControllers = [];

  @override
  Widget build(BuildContext context) {
    pixelRatio = MediaQuery.of(context).devicePixelRatio;
    return Container(
      child: Column(
        children: [
          Text(widget.translation.text(ScreenEditorText.sizeTabHeader),
              style: Theme.of(context).textTheme.headline5),
          Text(widget.translation.text(ScreenEditorText.sizeTabDetails)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _size(dimensions.left),
              _size(dimensions.top),
              _size(dimensions.width),
              _size(dimensions.height),
            ],
          ),
          preview()
        ],
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
    switch (dimension) {
      case dimensions.left:
        controller.text =
            widget.gicEditControl.control.left.roundToDouble().toString();
        text = widget.translation.text(ScreenEditorText.sizeTabLeft);
        controller.addListener(() {
          widget.gicEditControl.control.left = double.parse(controller.text);
        });
        icon = Icon(Icons.west, size: 26.0);
        break;
      case dimensions.top:
        controller.text =
            widget.gicEditControl.control.top.roundToDouble().toString();
        text = widget.translation.text(ScreenEditorText.sizeTabTop);
        controller.addListener(() {
          widget.gicEditControl.control.top = double.parse(controller.text);
        });
        icon = Icon(Icons.north, size: 26.0);
        break;
      case dimensions.width:
        controller.text = widget.gicEditControl.control.width.toString();
        text = widget.translation.text(ScreenEditorText.sizeTabWidth);
        controller.addListener(() {
          widget.gicEditControl.control.width = double.parse(controller.text);
        });
        icon = Icon(Icons.east, size: 26.0);
        break;
      case dimensions.height:
        controller.text = widget.gicEditControl.control.height.toString();
        text = widget.translation.text(ScreenEditorText.sizeTabHeight);
        controller.addListener(() {
          widget.gicEditControl.control.height = double.parse(controller.text);
        });
        icon = Icon(Icons.south, size: 26.0);
        break;
    }

    return Row(
      children: [
        icon,
        SizedBox(
          width: 20,
        ),
        Flexible(flex: 2, child: Text(text)),
        SizedBox(
          width: 20,
        ),
        Flexible(
          flex: 1,
          child: TextField(
              controller: controller, keyboardType: TextInputType.number),
        ),
      ],
    );
  }
}
