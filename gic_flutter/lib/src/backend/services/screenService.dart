//this service handles the backend work required for screen editor view
//for now going with a simple service layer

import 'dart:convert';
import 'dart:io';

import 'package:gic_flutter/src/backend/models/screen/controlDefaults.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/screenViewModel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScreenService {
  //current screen working with
  ScreenViewModel activeScreenViewModel;

  //list of all screens available
  List<ScreenViewModel> screenViewModels;

  //default control values to use
  ControlDefaults defaultControls;

  //snap to grid feature for the editor
  final String _prefGridSize = "prefGridSize";
  int gridSize = 0;

  //constructor
  ScreenService(this.activeScreenViewModel);

  /// Initialize our service with values from preferences
  Future init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    defaultControls =
        new ControlDefaults(prefs, activeScreenViewModel.screenId);
    gridSize = prefs.getInt(_prefGridSize);
    if (gridSize == null) gridSize = 0;
  }

  // void addControl(Offset localPosition, BuildContext context) {
  //     pixelRatio = MediaQuery.of(context).devicePixelRatio;
  //     final double statusBarHeight = MediaQuery.of(context).padding.top;
  //     final double x = gridSize * (localPosition.dx / gridSize) + statusBarHeight;
  //     final double y = gridSize * (localPosition.dy / gridSize);
  //
  //     ControlViewModel toAdd = ControlViewModel.fromModel(defaultControls.defaultButton);
  //     toAdd.left = x;
  //     toAdd.top = y;
  //     screen.controls.add(toAdd);
  // }

  /// Save the control to the applications documents directory
  /// NSData / AppData / etc depending on OS
  /// Returns either the file we wrote, or null on error
  Future<File> saveScreen() async {
    if (activeScreenViewModel == null || activeScreenViewModel.screenId < 0)
      return null;

    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = directory.path;
    final File file = File('$path/${activeScreenViewModel.screenId}.json');

    return file.writeAsString(json.encode(activeScreenViewModel.toJson()));
  }

  /// Load in all screens
  /// Returns true on success, false on any failure
  Future<bool> loadScreens() async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();

      Stream stream = directory.list();
      await stream.forEach((element) {
        File file = File(element.path);
        screenViewModels.add(
            ScreenViewModel.fromJson(json.decode(file.readAsStringSync())));
      });

      return true;
    } catch (e) {
      // If encountering an error, return 0.
      return false;
    }
  }

  // Sets which screen we are using as active
  // Returns true on success, false when no matching screen id is found
  bool setScreen(int screenId) {
    if (screenViewModels != null && screenViewModels.isNotEmpty)
      screenViewModels.forEach((element) {
        if (element.screenId == screenId) {
          activeScreenViewModel = element;
          return true;
        }
      });
    return false;
  }
}
