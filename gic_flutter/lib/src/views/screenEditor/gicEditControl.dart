import 'package:flutter/material.dart';
import 'package:gesture_x_detector/gesture_x_detector.dart';
import 'package:gic_flutter/src/views/baseGicControl.dart';

typedef void SelectedWidgetCallback(int selectedControlIndex);
typedef void DragControl(
    double newLeft, double newTop, int selectedControlIndex);

class GicEditControl extends BaseGicControl {
  final SelectedWidgetCallback onSelected;

  final int controlIndex;

  GicEditControl(
      {Key key,
      @required control,
      @required this.controlIndex,
      @required this.onSelected,
      @required pixelRatio})
      : super(key: key, control: control, pixelRatio: pixelRatio);

  @override
  State<StatefulWidget> createState() {
    return GicEditControlState(
        control: control,
        controlIndex: controlIndex,
        onSelected: onSelected,
        pixelRatio: pixelRatio);
  }
}

class GicEditControlState extends BaseGicControlState {
  final SelectedWidgetCallback onSelected;
  final int controlIndex;

  double _originalWidth;
  double _originalHeight;

  GicEditControlState(
      {@required control,
      @required this.controlIndex,
      @required this.onSelected,
      @required pixelRatio})
      : super(control: control, pixelRatio: pixelRatio) {
    _originalWidth = control.width;
    _originalHeight = control.height;
  }

  Widget buildControl() {
    return Positioned(
      top: control.top / pixelRatio,
      left: control.left / pixelRatio,
      child: XGestureDetector(
          doubleTapTimeConsider: 300,
          longPressTimeConsider: 350,
          onMoveUpdate: onMoveUpdate,
          onScaleUpdate: onScaleUpdate,
          bypassTapEventOnDoubleTap: false,
          child: buildControlContainer()),
    );
  }

  void onScaleUpdate(ScaleEvent event) {
    if (event.focalPoint.dx < 0) {
      control.width = _originalWidth / event.scale;
    } else {
      control.width = _originalWidth * event.scale;
    }
    if (event.focalPoint.dy < 0) {
      control.height = _originalHeight / event.scale;
    } else {
      control.height = _originalHeight * event.scale;
    }
  }

  void onMoveUpdate(MoveEvent event) {
    print('onMoveUpdate - pos: ${event.localPos} delta: ${event.delta}');
    control.left = (event.position.dx * pixelRatio) - (control.width / 2);
    control.top = (event.position.dy * pixelRatio) - (control.height / 2);
  }

  sendCommand(String commandUrl, int commandIndex) {
    if (onSelected != null) {
      setState(() {
        onSelected(controlIndex);
      });
    }
  }
}
