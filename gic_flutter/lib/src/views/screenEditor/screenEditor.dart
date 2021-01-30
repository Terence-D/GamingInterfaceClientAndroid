import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/font.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/screenViewModel.dart';
import 'package:gic_flutter/src/backend/services/screenService.dart';
import 'package:gic_flutter/src/views/screenEditor/gicEditControl.dart';

class ScreenEditor extends StatefulWidget {
  final ScreenViewModel screen;

  ScreenEditor({Key key, @required this.screen}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ScreenEditorState(screen);
  }
}

class ScreenEditorState extends State<ScreenEditor> {
  final List<Widget> widgets = [];
  int gridSize;
  ScreenService _service;
  final ScreenViewModel _screen;

  TapDownDetails _doubleTapDetails;

  ScreenEditorState(this._screen);


  @override
  void initState() {
    super.initState();
    _service = new ScreenService(_screen, context);
    _service.init();
    if (_service.screen != null)
      _service.screen.controls.forEach((element) {
        widgets.add(GicEditControl(control: element, textStyle: _getTextStyle(element.font),));
      }
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: widgets),
    );

    // return GestureDetector(
    //   onDoubleTapDown: _handleDoubleTapDown,
    //   // onDoubleTap: _handleDoubleTap,
    //   child: _setBackground(),
    // );
  }

  Widget _setBackground() {
    if (_service.screen.backgroundPath != null && _service.screen.backgroundPath.isNotEmpty) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(File(_service.screen.backgroundPath)),
              fit: BoxFit.fill,
            ),
          ),
          child: Stack(children: widgets),
        ),
      );
    } else {
      return Material(
        color: _service.screen.backgroundColor,
        child: Stack(children: widgets),
      );
    }
  }

  Widget _buildGicControl(ControlViewModel element) {
    // return Positioned(
    //   left: element.left,
    //   top: element.top,
    //   child: Draggable(
    //       feedback: _dynamicControl(element),
    //       child: _dynamicControl(element),
    //       childWhenDragging: Container(),
    //       onDragEnd: (dragDetails) {
    //         setState(() {
    //           element.left = dragDetails.offset.dx;
    //           // if applicable, don't forget offsets like app/status bar
    //           element.top = dragDetails.offset.dy;// - appBarHeight - statusBarHeight;
    //         });
    //       },
    //   )
    // );
    return Positioned(
        left: element.left,
        top: element.top,
        child: GestureDetector(
          onPanUpdate: (panInfo) {
            setState(() {
              element.left += panInfo.delta.dx;
              // if applicable, don't forget offsets like app/status bar
              element.top += panInfo.delta.dy;// - appBarHeight - statusBarHeight;
            });
          },
          child: _dynamicControl(element)
          // Container(
          //   width: 150,
          //   height: 150,
          //   color: Colors.blue,
          // ),
        )
    );
  }

  Widget _dynamicControl(ControlViewModel element) {
    switch (element.type) {
      case ControlViewModelType.Text:
        return _gicText(element);
      case ControlViewModelType.Image:
        return _gicImage(element);
      default:
        return GicEditControl();
        // return GicEditControl(control: element, textStyle: _getTextStyle(element.font), editor: this);
    }
  }

  Widget _gicImage(ControlViewModel element) {
    return Image.file(File(element.images[0]),
      width: element.width,
      height: element.height,
    );
  }

  Widget _gicText(ControlViewModel element) {
    return new Container(width: element.width, child: Text(element.text, style: _getTextStyle(element.font)));
  }

  TextStyle _getTextStyle(Font font) {
    return TextStyle(color: font.color, fontFamily: font.family, fontSize: font.size);
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  // void _handleDoubleTap() {
  //   print('Double tap on position ${_doubleTapDetails.localPosition}');
  //   _service.addControl(_doubleTapDetails.localPosition, context);
  //   setState(() {
  //
  //   });
  // }
  //
  // void moveControl() {
  //   setState(() {
  //   });
  // }
}
