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
    if (_service.screen != null) {
      _service.screen.controls.forEach((element) {
        widgets.add(GicEditControl(
          control: element, textStyle: _getTextStyle(element.font),));
      }
      );
    }
    widgets.add(new IconButton(onPressed: null, icon: Icon(Icons.menu) ));

  }

  @override
  Widget build(BuildContext context) {
    return _buildScreen();
  }


  TextStyle _getTextStyle(Font font) {
    return TextStyle(color: font.color, fontFamily: font.family, fontSize: font.size);
  }

  Widget _buildScreen() {
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
