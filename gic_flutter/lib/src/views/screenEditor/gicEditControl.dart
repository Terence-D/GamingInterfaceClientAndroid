import 'package:flutter/material.dart';
import 'package:gic_flutter/src/views/baseGicControl.dart';

typedef void SelectedWidgetCallback(int selectedControlIndex);
typedef void DragControl(
    double newLeft, double newTop, int selectedControlIndex);

class GicEditControl extends BaseGicControl {
  final SelectedWidgetCallback onSelected;
  final DragControl onDrag;

  final int controlIndex;

  GicEditControl(
      {Key key,
      @required control,
      @required this.controlIndex,
      @required this.onSelected,
      @required this.onDrag,
      @required pixelRatio})
      : super(key: key, control: control, pixelRatio: pixelRatio);

  @override
  State<StatefulWidget> createState() {
    return GicEditControlState(
        control: control,
        controlIndex: controlIndex,
        onSelected: onSelected,
        onDrag: onDrag,
        pixelRatio: pixelRatio);
  }
}

class GicEditControlState extends BaseGicControlState {
  final SelectedWidgetCallback onSelected;
  final DragControl onDrag;

  final int controlIndex;

  GicEditControlState(
      {@required control,
      @required this.controlIndex,
      @required this.onSelected,
      @required this.onDrag,
      @required pixelRatio})
      : super(control: control, pixelRatio: pixelRatio);

  GestureDetector buildControl() {
    return GestureDetector(
        onTapDown: (TapDownDetails details) => onTap(),
        //onTapUp: (TapUpDetails details) => onTapUp(),
        onPanUpdate: (tapInfo) {
          setState(() {
            control.left += tapInfo.delta.dx;
            control.top += tapInfo.delta.dy;
            if (onDrag != null) onDrag(control.left, control.top, controlIndex);
          });
        },
        child: buildControlContainer());
  }

  sendCommand(String commandUrl, int commandIndex) {
    if (onSelected != null)
      setState(() {
        onSelected(controlIndex);
      });
  }
}
