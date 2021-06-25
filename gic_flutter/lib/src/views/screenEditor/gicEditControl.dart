import 'package:flutter/material.dart';
import 'package:gesture_x_detector/gesture_x_detector.dart';
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

  double _scaleFactor = 1.0;
  double _baseScaleFactor = 1.0;
  String lastEventName = 'Tap on screen';
  double width;
  double height;

  GicEditControlState(
      {@required control,
      @required this.controlIndex,
      @required this.onSelected,
      @required this.onDrag,
      @required pixelRatio})
      : super(control: control, pixelRatio: pixelRatio) {
    width = control.width;
    height = control.height;
  }

  Widget buildControl() {
    return Positioned(
      top: control.top / pixelRatio,
      left: control.left / pixelRatio,
      child: XGestureDetector(
          //onTapDown: (TapDownDetails details) => null,
          doubleTapTimeConsider: 300,
          longPressTimeConsider: 350,
          onTap: _onTap,
          onDoubleTap: onDoubleTap,
          onLongPress: onLongPress,
          onLongPressEnd: onLongPressEnd,
          onMoveStart: onMoveStart,
          onMoveEnd: onMoveEnd,
          onMoveUpdate: onMoveUpdate,
          onScaleStart: onScaleStart,
          onScaleUpdate: onScaleUpdate,
          onScaleEnd: onScaleEnd,
          bypassTapEventOnDoubleTap: false,

          // onScaleStart: (details) {
          //   _baseScaleFactor = _scaleFactor;
          // },
          // onScaleUpdate: (details) {
          //   setState(() {
          //     _scaleFactor = _baseScaleFactor * details.scale;
          //     control.width = control.width * _scaleFactor;
          //     control.height = control.height * _scaleFactor;
          //     print ("moving from ${control.left} to ${details.focalPoint.dx} and scale factor is $_scaleFactor");
          //     // control.left = details.focalPoint.dx;
          //     // control.top = details.focalPoint.dy;
          //     // if (_scaleFactor.toInt() == 1) {
          //     //   //onDrag(control.left, control.top, controlIndex);
          //     // }
          //   });
          // },
          child: buildControlContainer()),
    );
  }

  void onLongPressEnd() {
    setLastEventName('onLongPressEnd');
    print('onLongPressEnd');
  }

  void onScaleEnd() {
    setLastEventName('onScaleEnd');
    print('onScaleEnd');
  }

  void onScaleUpdate(ScaleEvent event) {
    setLastEventName('onScaleUpdate');
    if (event.focalPoint.dx < 0) {
      control.width = width / event.scale;
    } else {
      control.width = width * event.scale;
    }
    if (event.focalPoint.dy < 0) {
      control.height = height / event.scale;
    } else {
      control.height = height * event.scale;
    }
    print(
        'onScaleUpdate - changedFocusPoint:  ${event.focalPoint} ; scale: ${event.scale} ;Rotation: ${event.rotationAngle}');
  }

  void onScaleStart(initialFocusPoint) {
    setLastEventName('onScaleStart');
    print('onScaleStart - initialFocusPoint: $initialFocusPoint');
  }

  void onMoveUpdate(MoveEvent event) {
    setLastEventName('onMoveUpdate');
    print('onMoveUpdate - pos: ${event.localPos} delta: ${event.delta}');
        control.left = event.position.dx * pixelRatio;
        control.top = event.position.dy * pixelRatio;

  }

  void onMoveEnd(localPos) {
    setLastEventName('onMoveEnd');
    print('onMoveEnd - pos: $localPos');
  }

  void onMoveStart(localPos) {
    setLastEventName('onMoveStart');
    print('onMoveStart - pos: $localPos');
  }

  void onLongPress(TapEvent event) {
    setLastEventName('onLongPress');
    print('onLongPress - pos: ${event.localPos}');
  }

  void onDoubleTap(event) {
    setLastEventName('onDoubleTap');
    print('onDoubleTap - pos: ' + event.localPos.toString());
  }

  void _onTap(event) {
    setLastEventName('onTap');
    print('onTap - pos: ' + event.localPos.toString());
  }

  void setLastEventName(String eventName) {
    setState(() {
      lastEventName = eventName;
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
