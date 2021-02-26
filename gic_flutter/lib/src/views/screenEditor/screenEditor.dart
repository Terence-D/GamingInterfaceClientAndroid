import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';
import 'package:gic_flutter/src/backend/services/screenService.dart';
import 'package:gic_flutter/src/views/screenEditor/gicEditControl.dart';

import 'settingsDialog.dart';

class ScreenEditor extends StatefulWidget {
  final int screenId;

  ScreenEditor({Key key, @required this.screenId}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ScreenEditorState(screenId);
  }
}

class ScreenEditorState extends State<ScreenEditor> {
  int controlId = -1;
  int gridSize;
  ScreenService _service;
  final double highlightBorder = 2.0;
  final double minSize = 16.0;
  final int screenId;
  double pixelRatio;

  double selectedLeft = 0;
  double selectedTop = 0;
  double selectedWidth = 0;
  double selectedHeight = 0;
  bool selectedVisible = false;

  bool _loaded = false;

  TapDownDetails _doubleTapDetails;

  ScreenEditorState(this.screenId);

  @override
  void initState() {
    super.initState();

    _buildService().then((value) {
      setState(() {

      });
    });
  }

  Future<void> _buildService() async {
    _service = new ScreenService();
    await _service.loadScreens();
    _loaded = _service.setActiveScreen(screenId);
    await _service.initDefaults();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    if (!_loaded)
      return Scaffold();
    pixelRatio = MediaQuery.of(context).devicePixelRatio;
    int n = 0;
    List<Widget> widgets = [];
    widgets.add(_highlightSelection());
    if (_service.activeScreenViewModel != null) {
      _service.activeScreenViewModel.controls.forEach((element) {
        widgets.add(GicEditControl(
          pixelRatio: pixelRatio,
          control: element,
          controlIndex: n,
          onSelected: (int id) {
            _onSelected(id);
          },
          onDrag: (double newLeft, double newTop, int selectedControlIndex) {_onDrag(newLeft, newTop, selectedControlIndex);},
        ));
        n++;
      });
    }

    Container screen;
    if (_service.activeScreenViewModel.backgroundPath != null &&
        _service.activeScreenViewModel.backgroundPath.isNotEmpty) {
      screen = Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(File(_service.activeScreenViewModel.backgroundPath)),
              fit: BoxFit.fill,
            ),
          ),
          child: Container(child: Stack(children: widgets)));
    } else {
      screen = Container(
          color: _service.activeScreenViewModel.backgroundColor,
          child: Stack(children: widgets));
    }

    return GestureDetector(
      onDoubleTapDown: _handleDoubleTapDown,
      onDoubleTap: _handleDoubleTap,
      onPanUpdate: (details) {
        _handleSwipe(details);
      },
      child: Scaffold(body: screen),
    );
  }

  //user tapped save in the settings menu
  void tapSave() {
    _service.activeScreenViewModel.save();
  }

  //add the chosen control
  void addControl(ControlViewModelType controlType) {
    ControlViewModel newControl = new ControlViewModel();
    switch (controlType) {
      case ControlViewModelType.QuickButton:
      case ControlViewModelType.Button:
        newControl = _service.defaultControls.defaultButton;
        break;
      case ControlViewModelType.Text:
        newControl = _service.defaultControls.defaultText;
        break;
      case ControlViewModelType.Image:
        newControl = _service.defaultControls.defaultImage;
        break;
      case ControlViewModelType.Toggle:
        newControl = _service.defaultControls.defaultToggle;
        break;
    }
    newControl.left = (_doubleTapDetails.localPosition.dx * pixelRatio) - (newControl.width / 2);
    newControl.top = (_doubleTapDetails.localPosition.dy * pixelRatio) - (newControl.height / 2);
    setState(() {
      _service.activeScreenViewModel.controls.add(newControl);
    });
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
          return SettingsDialog.display(context, this);
        });
  }

  void _onSelected(int selectedControlIndex) {
    setState(() {
      controlId = selectedControlIndex;
      selectedLeft =
          _service.activeScreenViewModel.controls[selectedControlIndex].left - highlightBorder;
      selectedTop =
          _service.activeScreenViewModel.controls[selectedControlIndex].top - highlightBorder;
      selectedWidth = _service.activeScreenViewModel.controls[selectedControlIndex].width +
          (highlightBorder * 2);
      selectedHeight = _service.activeScreenViewModel.controls[selectedControlIndex].height +
          (highlightBorder * 2);
      selectedVisible = true;
    });
  }

  void _onDrag(double newLeft, double newTop, int selectedControlIndex) {
    setState(() {
      _service.activeScreenViewModel.controls[selectedControlIndex].left = newLeft;
      _service.activeScreenViewModel.controls[selectedControlIndex].top = newTop;
    });
  }

  _handleSwipe(details) {
    if (controlId > -1) {
      setState(() {
        _service.activeScreenViewModel.controls[controlId].width += details.delta.dx;
        _service.activeScreenViewModel.controls[controlId].height += details.delta.dy;
        if (_service.activeScreenViewModel.controls[controlId].width < minSize)
          _service.activeScreenViewModel.controls[controlId].width = minSize;
        if (_service.activeScreenViewModel.controls[controlId].height < minSize)
          _service.activeScreenViewModel.controls[controlId].height = minSize;
      });
    }
  }
}
