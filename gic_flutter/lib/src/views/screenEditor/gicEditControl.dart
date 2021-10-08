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
      : super(
            key: key,
            control: control,
            pixelRatio: pixelRatio,
            constraints: null);

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
          longPressTimeConsider: 200,
          onLongPress: onLongPress,
          onMoveUpdate: onMoveUpdate,
          onScaleUpdate: onScaleUpdate,
          onScaleEnd: onScaleEnd,
          bypassTapEventOnDoubleTap: false,
          child: buildControlContainer()),
    );
  }

  void onLongPress(event) {
    onSelected(controlIndex);
  }

  void onScaleUpdate(ScaleEvent event) {
    setState(() {
      if (event.focalPoint.dx < 0) {
        control.width = (_originalWidth / event.scale).roundToDouble();
      } else {
        control.width = (_originalWidth * event.scale).roundToDouble();
      }
      if (event.focalPoint.dy < 0) {
        control.height = (_originalHeight / event.scale).roundToDouble();
      } else {
        control.height = (_originalHeight * event.scale).roundToDouble();
      }
    });
  }

  void onScaleEnd() {
    _originalHeight = control.height;
    _originalWidth = control.width;
  }

  void onMoveUpdate(MoveEvent event) {
    setState(() {
      control.left = ((event.position.dx * pixelRatio) - (control.width / 2))
          .roundToDouble();
      control.top = ((event.position.dy * pixelRatio) - (control.height / 2))
          .roundToDouble();
    });
  }

  sendCommand(String commandUrl, int commandIndex) {
    if (onSelected != null) {
      setState(() {
        onSelected(controlIndex);
      });
    }
  }
}
