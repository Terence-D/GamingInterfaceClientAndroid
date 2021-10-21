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
  int version = 2;
  int screenId = -1;
  String name = "";
  List<ControlViewModel> controls = [];
  int newControlId = -1;
  Color backgroundColor = Colors.black54;
  String backgroundPath = "";

  ScreenViewModel.empty() {
    version = 2;
    screenId = -1;
    name = "";
    controls = [];
    newControlId = -1;
    backgroundColor = Color(1);
    backgroundPath = "";
  }

  ScreenViewModel(
      {this.version,
      this.screenId,
      this.name,
      this.controls,
      this.newControlId,
      this.backgroundColor,
      this.backgroundPath});

  ScreenViewModel.fromJson(Map<String, dynamic> json) {
    version = json['version'];
    screenId = json['screenId'];
    name = json['name'];
    controls = convertJsonToControl(json, 'controls');
    newControlId = json['newControlId'];
    backgroundColor = Color(json['backgroundColor']);
    backgroundPath = json['backgroundPath'];
  }

  static convertJsonToControl(Map<String, dynamic> json, String key) {
    var list = json[key] as List;
    List<ControlViewModel> controls = <ControlViewModel>[];
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
    ScreenViewModel newModel = ScreenViewModel();
    newModel.screenId = screenId;
    newModel.name = name;
    newControlId = newControlId;

    return newModel;
  }

  /// Save the screen to the applications documents directory
  /// NSData / AppData / etc depending on OS
  /// If importPath isn't null, it will use it as the source location for the resource files.  If it is null
  /// If jsonOnly is set, it will speedup the process by only saving the json changes
  /// It'll use the builtin ScreenService.backgroundImagePath
  /// Returns either the file we wrote, or null on error
  Future<File> save() async {
    if (screenId < 0) return null;

    try {
      final Directory appFolder = await getApplicationDocumentsDirectory();
      final String screenPath = path.join(
          appFolder.path, ScreenService.screenFolder, screenId.toString());
      //save the json file
      String screenJsonFile = path.join(screenPath, "data.json");
      final File file = File(screenJsonFile);
      file.createSync(recursive: true);
      final String output = json.encode(toJson());
      File toWrite = await file.writeAsString(output);
      return toWrite;
    } catch (_) {
      return null;
    }
  }

  /// Export the screen to the chosen path
  Future<String> export(String exportPath) async {
    final Directory appFolder = await getApplicationDocumentsDirectory();
    final String screenPath = path.join(
        appFolder.path, ScreenService.screenFolder, screenId.toString());
    String fileName = "${screenId.toString()}_$name";

    //we need to copy in all images stored in the files folder that this screen uses, and update their links to local
    Directory imageFilesDir = await getApplicationSupportDirectory();

    for (int i=0; i < controls.length; i++) {
      for (int n = 0; n < controls[i].images.length; n++) {
        if (controls[i].images[n].contains(imageFilesDir.path)) {
          File oldPath = File (controls[i].images[n]);
          String newPath = path.join(screenPath, path.basename(oldPath.path));
          oldPath.copySync(newPath);
          controls[i].images[n] = newPath;
        }
      }
    }
    int result = await CompressedFileService.compressFolder(
        screenPath, exportPath, fileName);

    if (result != 0)
      return null;
    else {
      return path.join(exportPath, fileName);
    }
  }

  /// LEGACY CODE BELOW
  factory ScreenViewModel.fromLegacyModel(Screen model) {
    ScreenViewModel rv = ScreenViewModel();
    rv.controls = [];
    rv.screenId = model.screenId;
    rv.name = model.name;
    model.controls.forEach((element) {
      rv.controls.add(ControlViewModel.fromLegacyModel(element));
    });
    rv.newControlId = model.newControlId;

    if (model.backgroundColor == -1 || model.backgroundColor == null) {
      rv.backgroundColor = Colors.black;
    } else {
      rv.backgroundColor = _convertLegacyColor(model.backgroundColor);
    }
    rv.backgroundPath = model.backgroundPath;
    return rv;
  }

  /// Convert legacy java color to Flutter Color
  static Color _convertLegacyColor(int legacyColor) {
    return Color(legacyColor);
  }
}
