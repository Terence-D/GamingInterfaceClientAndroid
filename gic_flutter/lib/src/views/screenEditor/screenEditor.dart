import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gic_flutter/src/backend/models/intl/intlScreenEditor.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';
import 'package:gic_flutter/src/backend/services/screenService.dart';
import 'package:gic_flutter/src/views/screenEditor/backgroundDialog.dart';
import 'package:gic_flutter/src/views/screenEditor/controlDialog/controlDialog.dart';
import 'package:gic_flutter/src/views/screenEditor/gicEditControl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settingsDialog/settingsDialog.dart';

class ScreenEditor extends StatefulWidget {
  final int screenId;

  ScreenEditor({Key key, @required this.screenId}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ScreenEditorState(screenId);
  }
}

class ScreenEditorState extends State<ScreenEditor> {
  IntlScreenEditor translation;
  int controlId = -1;
  int gridSize;
  ScreenService _service;
  final double highlightBorder = 2.0;
  final double minSize = 16.0;
  final int screenId;
  final String prefKeyGridSize = "prefGridSize";

  ControlViewModel deletedWidget;

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
      setState(() {});
    });
  }

  Future<void> _buildService() async {
    _service = ScreenService();
    await _service.loadScreens();
    _loaded = _service.setActiveScreen(screenId);
    await _service.initDefaults();

    //retrieve our settings for grid
    SharedPreferences prefs = await SharedPreferences.getInstance();
    gridSize = 64; //default size
    if (prefs.containsKey(prefKeyGridSize)) {
      gridSize = prefs.getInt(prefKeyGridSize);
    }
  }

  @override
  Widget build(BuildContext context) {
    translation = IntlScreenEditor(context);
    SystemChrome.setEnabledSystemUIOverlays([]);
    if (!_loaded) return Scaffold();
    pixelRatio = MediaQuery.of(context).devicePixelRatio;
    int n = 0;
    List<Widget> widgets = [];
    if (_service.activeScreenViewModel != null) {
      _service.activeScreenViewModel.controls.forEach((element) {
        widgets.add(Positioned(
            top: element.top / pixelRatio,
            left: element.left / pixelRatio,
            child: GicEditControl(
              pixelRatio: pixelRatio,
              control: element,
              controlIndex: n,
              onSelected: (int id) {
                _onSelected(id);
              },
              onDrag:
                  (double newLeft, double newTop, int selectedControlIndex) {
                _onDrag(newLeft, newTop, selectedControlIndex);
              },
            )));
        n++;
      });
    }

    Container screen;
    if (_service.activeScreenViewModel.backgroundPath != null &&
        _service.activeScreenViewModel.backgroundPath.isNotEmpty) {
      screen = Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(
                  File(_service.activeScreenViewModel.backgroundPath)),
              fit: BoxFit.fill,
            ),
          ),
          child: Container(child: Stack(children: widgets)));
    } else {
      screen = Container(
          color: _service.activeScreenViewModel.backgroundColor,
          child: Stack(children: widgets));
    }

    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);

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
    _service.defaultControls.saveDefaults(screenId);
    _service.activeScreenViewModel.save();
  }

  //add the chosen control
  void addControl(ControlViewModelType controlType) {
    ControlViewModel newControl = ControlViewModel();
    switch (controlType) {
      case ControlViewModelType.QuickButton:
      case ControlViewModelType.Button:
        newControl = _service.defaultControls.defaultButton.clone();
        break;
      case ControlViewModelType.Text:
        newControl = _service.defaultControls.defaultText.clone();
        break;
      case ControlViewModelType.Image:
        newControl = _service.defaultControls.defaultImage.clone();
        break;
      case ControlViewModelType.Toggle:
        newControl = _service.defaultControls.defaultToggle.clone();
        break;
    }

    newControl.left = _getGridPosition(
        startPosition: _doubleTapDetails.localPosition.dx,
        size: newControl.width);
    newControl.top = _getGridPosition(
        startPosition: _doubleTapDetails.localPosition.dy,
        size: newControl.height);

    setState(() {
      _service.activeScreenViewModel.controls.add(newControl);
    });
  }

  void gridChangeListener(double newValue) {
    setState(() {
      gridSize = newValue.toInt();
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt(prefKeyGridSize, newValue.toInt());
    });
  }

  /// Determines where to place something, based on the currently set grid value
  /// startPosition - the raw position, either X or Y based
  /// size - size of the control, on the same axis as startPosition.  -1 ignores
  double _getGridPosition({double startPosition, double size = -1}) {
    double rawPos = startPosition * pixelRatio;
    if (size > -1) {
      rawPos = rawPos - (size / 2);
    }
    int adjustedSize = gridSize;
    if (gridSize < 1) {
      adjustedSize = 1;
    }
    int gridPos = (rawPos.round() / adjustedSize).round();
    return gridPos * adjustedSize.toDouble();
  }

  void showPopupDialog(Widget dialog) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  void showBackgroundDialog() {
    Navigator.pop(context, true);
    showPopupDialog(BackgroundDialog(
        translation: translation,
        screenViewModel: _service.activeScreenViewModel));
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    setState(() {
      selectedVisible = false;
      showPopupDialog(SettingsDialog.display(context, this));
    });
  }

  Future<void> _onSelected(int selectedControlIndex) async {
    controlId = selectedControlIndex;
    bool deleteWidget = false;
    deleteWidget = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return ControlDialog(
              translation: translation,
              screenId: _service.activeScreenViewModel.screenId,
              gicEditControl: GicEditControl(
                  pixelRatio: pixelRatio,
                  control: _service
                      .activeScreenViewModel.controls[selectedControlIndex],
                  controlIndex: selectedControlIndex,
                  onSelected: null,
                  onDrag: null));
        });
    setState(() {
      if (deleteWidget != null && deleteWidget) {
        selectedVisible = false;
        deletedWidget =
            _service.activeScreenViewModel.controls[selectedControlIndex];
        _service.activeScreenViewModel.controls.removeAt(selectedControlIndex);
        _showDeleteToast();
      }
    });
  }

  void _onDrag(double newLeft, double newTop, int selectedControlIndex) {
    _service.activeScreenViewModel.controls[selectedControlIndex].left +=
        // newLeft;
        _getGridPosition(startPosition: newLeft * pixelRatio);
    _service.activeScreenViewModel.controls[selectedControlIndex].top +=
        // newTop;
        _getGridPosition(startPosition: newTop * pixelRatio);
    setState(() {});
  }

  _handleSwipe(details) {
    if (controlId > -1) {
      setState(() {
        _service.activeScreenViewModel.controls[controlId].width +=
            details.delta.dx;
        _service.activeScreenViewModel.controls[controlId].height +=
            details.delta.dy;
        if (_service.activeScreenViewModel.controls[controlId].width <
            minSize) {
          _service.activeScreenViewModel.controls[controlId].width = minSize;
        }
        if (_service.activeScreenViewModel.controls[controlId].height <
            minSize) {
          _service.activeScreenViewModel.controls[controlId].height = minSize;
        }
      });
    }
  }

  void _showDeleteToast() {
    final snackBar = SnackBar(
      content: Text(translation.text(ScreenEditorText.widgetDeleted)),
      action: SnackBarAction(
        label: translation.text(ScreenEditorText.undo),
        onPressed: () {
          setState(() {
            _service.activeScreenViewModel.controls.add(deletedWidget);
          });
        },
      ),
    );

    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
