# gesture_x_detector

A widget that detects gestures.

Easy to use, lightweight gesture detector for Flutter apps.

## Features

-   Detect tap gestures (Tap, DoubleTap, Scale(start, update, end), Long press, Move(start, update, end)
-   All callbacks can be used simultaneously
-   Customize: ignore tap event on double tap, change duration time to detect double tap or long-press

## Getting Started

### Installation

Add to pubspec.yaml:

```yaml
dependencies:
    gesture_x_detector:
```

### Example

Checkout the example at https://github.com/taodo2291/xgesture_flutter/tree/master/example/lib/main.dart

```dart
import 'package:flutter/material.dart';
import 'package:gesture_x_detector/gesture_x_detector.dart';

void main() {
  runApp(
    MaterialApp(
      home: XGestureExample(),
    ),
  );
}

class XGestureExample extends StatefulWidget {
  @override
  _XGestureExampleState createState() => _XGestureExampleState();
}

class _XGestureExampleState extends State<XGestureExample> {
  String lastEventName = 'Tap on screen';

  @override
  Widget build(BuildContext context) {
    return XGestureDetector(
      child: Material(
        child: Center(
          child: Text(
            lastEventName,
            style: TextStyle(fontSize: 30),
          ),
        ),
      ),
      doubleTapTimeConsider: 300,
      longPressTimeConsider: 350,
      onTap: onTap,
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

  void onTap(event) {
    setLastEventName('onTap');
    print('onTap - pos: ' + event.localPos.toString());
  }

  void setLastEventName(String eventName) {
    setState(() {
      lastEventName = eventName;
    });
  }
}

```

### Customize

-   Change DoubleTap and Long press detect

```dart
@override
  Widget build(BuildContext context) {
    return XGestureDetector(
      child: child,
      doubleTapTimeConsider: 300,       //customize double tap time
      longPressTimeConsider: 400,       //customize long press time
    );
  }
```

-   Ignore Tap in case Double Tap dectected

```dart
@override
  Widget build(BuildContext context) {
    return XGestureDetector(
      child: child,
      bypassTapEventOnDoubleTap: true,      // default is false
    );
  }
```

-   Allow move event after long press event fired without release pointer

```dart
@override
  Widget build(BuildContext context) {
    return XGestureDetector(
      child: child,
      bypassMoveEventAfterLongPress: false,      // default is true
    );
  }
```

Checkout the Canvas playground example at https://github.com/taodo2291/xgesture_flutter/tree/master/example/lib/canvas_playground.dart


## Author
Viet Nguyen - taodo2291@gmail.com