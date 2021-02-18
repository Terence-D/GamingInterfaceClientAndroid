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
  int screenId = -1;
  String name;
  List<ControlViewModel> controls = new List<ControlViewModel>();
  int newControlId = -1;
  Color backgroundColor;
  String backgroundPath;

  ScreenViewModel();

  factory ScreenViewModel.fromJson(Map<String, dynamic> json) {
    ScreenViewModel rv = new ScreenViewModel();
    rv.screenId = json['screenId'];
    rv.name = json['name'];
    rv.controls = json['controls'];
    rv.newControlId = json['newControlId'];
    rv.backgroundColor = json['backgroundColor'];
    rv.backgroundPath = json['backgroundPath'];
    return rv;
  }

  Map<String, dynamic> toJson() => {
        'version': "2",
        'screenId': screenId,
        'name': name,
        'controls': controls,
        'newControlId': newControlId,
        'backgroundColor': backgroundColor,
        'backgroundPath': backgroundPath
      };

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
            String originalImagePath =
                image; //paths are absolute for images as it may be in assets OR imported custom
            File imageFile = new File(originalImagePath);
            String newImageFile = path.join(screenPath, originalImagePath);
            imageFile.copy(newImageFile);
          });
        });
      }

      //save the json file
      final File file = File('$screenPath/data.json');
      return file.writeAsString(json.encode(toJson()));
    } catch (_) {
      return null;
    }
  }

  Future<int> export(String exportPath) async {
    final Directory appFolder = await getApplicationDocumentsDirectory();
    final String screenPath = path.join(
        appFolder.path, ScreenService.screenFolder, screenId.toString());
    return CompressedFileService.compressFolder(
        screenPath, exportPath, "${screenId.toString()}_$name");
  }

  /// LEGACY CODE BELOW
  factory ScreenViewModel.fromLegacyModel(Screen model, double pixelRatio) {
    ScreenViewModel rv = new ScreenViewModel();
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
