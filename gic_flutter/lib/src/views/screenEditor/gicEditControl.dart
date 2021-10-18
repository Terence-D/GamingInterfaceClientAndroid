import 'package:flutter/material.dart';
import 'package:gesture_x_detector/gesture_x_detector.dart';
import 'package:gic_flutter/src/views/baseGicControl.dart';

typedef void SelectedWidgetCallback(int selectedControlIndex);
typedef void DragControl(
    double newLeft, double newTop, int selectedControlIndex);

class GicEditControl extends BaseGicControl {
  final SelectedWidgetCallback onSelected;
  final int controlIndex;
  final GridSize gridSize;

  GicEditControl(
      {Key key,
      this.gridSize,
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
        gridSize: gridSize,
        control: control,
        controlIndex: controlIndex,
        onSelected: onSelected,
        pixelRatio: pixelRatio);
  }
}

class GicEditControlState extends BaseGicControlState {
  final SelectedWidgetCallback onSelected;
  final int controlIndex;
  final GridSize gridSize;

  double _originalWidth;
  double _originalHeight;

  GicEditControlState(
      {this.gridSize,
      @required control,
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
      double adjustedX = _getGridPosition(startPosition: event.position.dx, size: control.width);
      double adjustedY = _getGridPosition(startPosition: event.position.dy, size: control.height);
      control.left = adjustedX;
      control.top = adjustedY;
    });
  }

  sendCommand(String commandUrl, int commandIndex) {
    if (onSelected != null) {
      setState(() {
        onSelected(controlIndex);
      });
    }
  }

  /// Determines where to place something, based on the currently set grid value
  /// startPosition - the raw position, either X or Y based
  /// size - size of the control, on the same axis as startPosition.  -1 ignores
  double _getGridPosition({double startPosition, double size = -1}) {
    double rawPos = startPosition * pixelRatio;
    if (size > -1) {
      rawPos = rawPos - (size / 2);
    }
    int adjustedSize = gridSize.value;
    if (gridSize.value < 1) {
      adjustedSize = 1;
    }
    int gridPos = (rawPos.round() / adjustedSize).round();
    return gridPos * adjustedSize.toDouble();
  }

}

class GridSize {
  int _value = 0;

  int get value {
    return _value;
  }

  void set value(int newValue) {
    _value = newValue;
  }
}