## [0.0.1] - TODO: Add release date.

## [0.0.2] - TODO: Update API document and example.

## [0.0.3] - TODO: dartfmt

## [0.0.4] 

## [0.0.5]
BREAKING
* add new flag: bypassMoveEventAfterLongPress

        by default it is true, means after receive long press event without release pointer (finger still touch on screen the move event will be ignore.

        set it to false in case you expect move event will be fire after long press event

* using parameter object instead of naked parameters

        old version
        ```dart
        @override
        Widget build(BuildContext context) {
            return XGestureDetector(
            child: Text("data"),
            onTap: (pointer, localPos, position) => print("localPos: $localPos, pointer: $pointer"),
            onScaleUpdate: (changedFocusPoint, scale, rotationAngle) =>
                print("focalPoint: $changedFocusPoint, scale: $scale"),
            );
        }
        ```

        new version
        ```
        Widget build(BuildContext context) {
            return XGestureDetector(
            child: Text("data"),
            onTap: (event) =>
                print("localPos: ${event.localPos}, pointer: ${event.pointer}"),
            onScaleUpdate: (event) =>
                print("focalPoint: ${event.focalPoint}, scale: ${event.scale}"),
            );
        }
        ```
## [1.0.0-nullsafety.0]
    BREAKING: opt into null safety
    feat!: upgrade Dart SDK constraints to >=2.12.0-0 <3.0.0

## [1.0.0-nullsafety.1]
    Support onLongPressEnd

## [1.0.0]
    sound null safety