import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/screen/screen.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';
import 'package:gic_flutter/src/backend/services/compressedFileService.dart';
import 'package:gic_flutter/src/backend/services/screenService.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ScreenViewModel {
  int version;
  int screenId = -1;
  String name;
  List<ControlViewModel> controls = new List<ControlViewModel>();
  int newControlId = -1;
  Color backgroundColor;
  String backgroundPath;

  ScreenViewModel(
      {this.version,
      this.screenId,
      this.name,
      this.controls,
      this.newControlId,
      this.backgroundColor,
      this.backgroundPath});

  ScreenViewModel.fromJson(Map<String, dynamic> json)
      : version = json['version'],
        screenId = json['screenId'],
        name = json['name'],
        controls = convertJsonToControl(json),
        newControlId = json['newControlId'],
        backgroundColor = new Color(json['backgroundColor']),
        backgroundPath = json['backgroundPath'];

  static convertJsonToControl(Map<String, dynamic> json) {
    var list = json['controls'] as List;
    List<ControlViewModel> controls = new List<ControlViewModel>();
    list.forEach((value) {
      controls.add(ControlViewModel.fromJson(value));
    });
    return controls;
  }

  /// Converts this screen view model into a json map
  Map<String, dynamic> toJson() => {
        'version': 2,
        'screenId': screenId,
        'name': name,
        'controls': controls,
        'newControlId': newControlId,
        'backgroundColor': backgroundColor.value,
        'backgroundPath': backgroundPath
      };

  /// Create a clone of this object
  ScreenViewModel buildClone() {
    ScreenViewModel newModel = new ScreenViewModel();
    newModel.screenId = screenId;
    newModel.name = name;
    newControlId = newControlId;

    return newModel;
  }

  /// Save the control to the applications documents directory
  /// NSData / AppData / etc depending on OS
  /// If importPath isn't null, it will use it as the source location for the resource files.  If it is null
  /// If jsonOnly is set, it will speedup the process by only saving the json changes
  /// It'll use the builtin ScreenService.backgroundImagePath
  /// Returns either the file we wrote, or null on error
  Future<File> save(
      {bool jsonOnly = false, String backgroundImageLocation: ""}) async {
    if (screenId < 0) return null;

    try {
      final Directory appFolder = await getApplicationDocumentsDirectory();
      final String screenPath = path.join(
          appFolder.path, ScreenService.screenFolder, screenId.toString());
      final Directory screenFolder = new Directory(screenPath);
      if (!jsonOnly) {
        //create folder if doesn't exist
        if (!screenFolder.existsSync())
          screenFolder.createSync(recursive: true);

        //copy in resources
        String pathToUse = appFolder.path;
        if (backgroundImageLocation.isNotEmpty)
          pathToUse = backgroundImageLocation;
        if (backgroundPath != null && backgroundPath.isNotEmpty) {
          String originalBackgroundImagePath = path.join(
              pathToUse, ScreenService.backgroundImageFolder, backgroundPath);
          File backgroundFile = new File(originalBackgroundImagePath);
          String newBackgroundImageFile = path.join(screenPath, backgroundPath);
          backgroundFile.copy(newBackgroundImageFile);
        }
        controls.forEach((control) {
          control.images.forEach((image) {
            File imageFile = new File(image);
            //if the path is an absolute path, copy them in to the local path
            if (imageFile.isAbsolute) {
              imageFile.copy(screenPath);
            }
            image = path.basename(imageFile.path);
          });
        });
      }

      //save the json file
      String screenJsonFile = path.join(screenPath, "data.json");
      final File file = File(screenJsonFile);
      return file.writeAsString(json.encode(toJson()));
    } catch (_) {
      return null;
    }
  }

  /// Export the screen to the chosen path
  Future<int> export(String exportPath) async {
    final Directory appFolder = await getApplicationDocumentsDirectory();
    final String screenPath = path.join(
        appFolder.path, ScreenService.screenFolder, screenId.toString());
    return CompressedFileService.compressFolder(
        screenPath, exportPath, "${screenId.toString()}_$name");
  }

  /// LEGACY CODE BELOW
  factory ScreenViewModel.fromLegacyModel(Screen model) {
    ScreenViewModel rv = new ScreenViewModel();
    rv.controls = new List<ControlViewModel>();
    rv.screenId = model.screenId;
    rv.name = model.name;
    model.controls.forEach((element) {
      rv.controls.add(new ControlViewModel.fromLegacyModel(element));
    });
    rv.newControlId = model.newControlId;

    if (model.backgroundColor == -1 || model.backgroundColor == null)
      rv.backgroundColor = Colors.black;
    else
      rv.backgroundColor = _convertLegacyColor(model.backgroundColor);
    rv.backgroundPath = model.backgroundPath;
    return rv;
  }

  /// Convert legacy java color to Flutter Color
  static Color _convertLegacyColor(int legacyColor) {
    return Color(legacyColor);
  }
}
