import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/font.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/screenViewModel.dart';
import 'package:gic_flutter/src/backend/services/screenService.dart';
import 'package:gic_flutter/src/views/screenEditor/gicEditControl.dart';

import 'settingsDialog.dart';

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
  int id = -1;
  int gridSize;
  ScreenService _service;
  final ScreenViewModel _screen;
  final double highlightBorder = 2.0;

  double selectedLeft = 0;
  double selectedTop = 0;
  double selectedWidth = 0;
  double selectedHeight = 0;
  bool selectedVisible = false;

  TapDownDetails _doubleTapDetails;

  ScreenEditorState(this._screen);

  @override
  void initState() {
    super.initState();

    _service = new ScreenService(_screen);
    _service.init();
    int n = 0;
    if (_service.screen != null) {
      _service.screen.controls.forEach((element) {
        widgets.add(GicEditControl(
          control: element,
          textStyle: _getTextStyle(element.font), id: n, onSelected: (int id) {
          onSelected(id);
        },
        ));
        n++;
      }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return _buildScreen();
  }

  TextStyle _getTextStyle(Font font) {
    return TextStyle(
        color: font.color, fontFamily: font.family, fontSize: font.size);
  }

  Widget _buildScreen() {
    List<Widget> toDraw = new List();
    toDraw.add(_highlightSelection());
    widgets.forEach((element) {
      toDraw.add(element);
    });

    Container screen;
    if (_service.screen.backgroundPath != null &&
        _service.screen.backgroundPath.isNotEmpty) {
      screen = Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(File(_service.screen.backgroundPath)),
              fit: BoxFit.fill,
            ),
          ),
          child: Container(
              child: Stack(children: toDraw)));
    } else {
      screen = Container(
          color: _service.screen.backgroundColor,
          child: Stack(children: toDraw));
    }

    return GestureDetector(
      onDoubleTapDown: _handleDoubleTapDown,
      onDoubleTap: _handleDoubleTap,
      child: Scaffold(body: screen),
    );
  }

  Positioned _highlightSelection() {
    return Positioned(
        left: selectedLeft,
        top: selectedTop,
        child: Visibility(
            visible: selectedVisible,
            child: Container(
                width: selectedWidth,
                height: selectedHeight,
                color: Colors.yellow)));
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    print('Double tap on position ${_doubleTapDetails.localPosition}');
    setState(() {
      selectedVisible = false;
      _showSettingsDialog();
    });
  }

  void _showSettingsDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SettingsDialog.display(context);
        });
  }

  void onSelected(int id) {
    setState(() {
      selectedLeft = _service.screen.controls[id].left - highlightBorder;
      selectedTop = _service.screen.controls[id].top - highlightBorder;
      selectedWidth =
          _service.screen.controls[id].width + (highlightBorder * 2);
      selectedHeight =
          _service.screen.controls[id].height + (highlightBorder * 2);
      selectedVisible = true;
    });
  }
}