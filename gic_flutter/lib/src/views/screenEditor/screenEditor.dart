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

import 'helpDialog/helpDialog.dart';
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
  GridSize gridSize = GridSize();
  ScreenService _service;
  final double highlightBorder = 2.0;
  final double minSize = 16.0;
  final int screenId;
  final String prefKeyGridSize = "prefGridSize";
  final String prefHelpKey = "-screenEditorHelp";

  ControlViewModel deletedWidget;

  double pixelRatio;

  double selectedLeft = 0;
  double selectedTop = 0;
  double selectedWidth = 0;
  double selectedHeight = 0;

  bool _firstVisit = true;
  bool _loaded = false;

  TapDownDetails _doubleTapDetails;

  ScreenEditorState(this.screenId);

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
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
    gridSize.value = 64; //default size
    if (prefs.containsKey(prefKeyGridSize)) {
      gridSize.value = prefs.getInt(prefKeyGridSize);
    }
    if (prefs.containsKey("$screenId$prefHelpKey")) {
      _firstVisit = prefs.getBool("$screenId$prefHelpKey");
    }
  }

  @override
  void dispose() {
    super.dispose();
    // Exit full screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    translation = IntlScreenEditor(context);
    if (!_loaded) return Scaffold();
    pixelRatio = MediaQuery.of(context).devicePixelRatio;

    List<Widget> widgets = [];
    if (_service.activeScreenViewModel != null) {

      for(int i=0; i < _service.activeScreenViewModel.controls.length; i++) {
        widgets.add(GicEditControl(
          gridSize: gridSize,
          pixelRatio: pixelRatio,
          control: _service.activeScreenViewModel.controls[i],
          controlIndex: i,
          onSelected: (int i) {
            _onSelected(i);
          },
        )
        );
      }

      if (_firstVisit) {
        widgets.add(Center(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent),
                shape: BoxShape.rectangle,
                color: Colors.black45,
              ),
              child: Text(
                translation.text(ScreenEditorText.helpMessage),
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            )));
      }
    }

    Container screen;
    if (_service.activeScreenViewModel.backgroundPath != null &&
        _service.activeScreenViewModel.backgroundPath.isNotEmpty) {
      FileImage fi = FileImage(
          File(_service.activeScreenViewModel.backgroundPath)
      );
      screen = Container(
          key: UniqueKey(),
          decoration: BoxDecoration(
            image: DecorationImage(
              image:fi,
              fit: BoxFit.fill,
            ),
          ),
          child: Container(child: Stack(children: widgets),
              key: Key(_service.activeScreenViewModel.controls.length.toString())));
    } else {
      screen = Container(
          color: _service.activeScreenViewModel.backgroundColor,
          child: Stack(children: widgets,
          key: Key(_service.activeScreenViewModel.controls.length.toString())));
    }

    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);

    return GestureDetector(
        onDoubleTapDown: _handleDoubleTapDown,
        onDoubleTap: _handleDoubleTap,
        child: Scaffold(body: screen));
  }

  //user tapped save in the settings menu
  void tapSave() {
    _service.defaultControls.saveDefaults(screenId);
    _service.activeScreenViewModel.save();
  }

  //user tapped help in the settings menu
  tapHelp() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
      return HelpDialog(
          translation: translation,
          );
    });
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
      gridSize.value = newValue.toInt();
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
    int adjustedSize = gridSize.value;
    if (gridSize.value < 1) {
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
        }).then((_)=>setState((){}));
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
    SharedPreferences.getInstance()
        .then((value) => value.setBool("$screenId$prefHelpKey", false));
    _firstVisit = false;
    setState(() {
      showPopupDialog(SettingsDialog.display(context, this));
    });
  }

  Future<void> _onSelected(int selectedControlIndex) async {
    controlResult result = controlResult.save;
    result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return ControlDialog(
              translation: translation,
              screenId: _service.activeScreenViewModel.screenId,
              gicEditControl: GicEditControl(
                gridSize: gridSize,
                pixelRatio: pixelRatio,
                control: _service
                    .activeScreenViewModel.controls[selectedControlIndex],
                controlIndex: selectedControlIndex,
                onSelected: null,
              ));
        });
    setState(() {
      if (result != null)
        if (result == controlResult.delete) {
          setState(() {
            deletedWidget = _service.activeScreenViewModel.controls.removeAt(selectedControlIndex);
          });
        _showDeleteToast();
      } else if (result == controlResult.save) {
          switch (_service
              .activeScreenViewModel.controls[selectedControlIndex].type) {
            case ControlViewModelType.Button:
              _service.defaultControls.defaultButton = _service
                  .activeScreenViewModel.controls[selectedControlIndex].clone();
              break;
            case ControlViewModelType.Text:
              _service.defaultControls.defaultText = _service
                  .activeScreenViewModel.controls[selectedControlIndex].clone();
              break;
            case ControlViewModelType.Image:
              break;
            case ControlViewModelType.Toggle:
              _service.defaultControls.defaultToggle = _service
                  .activeScreenViewModel.controls[selectedControlIndex].clone();
              break;
            case ControlViewModelType.QuickButton:
              _service.defaultControls.defaultButton = _service
                  .activeScreenViewModel.controls[selectedControlIndex].clone();
              break;
          }
        }
    });
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
