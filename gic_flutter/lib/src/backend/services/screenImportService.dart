/*
* This class handles importing in a zip file and all contained image and jsons
* */
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:gic_flutter/src/backend/models/screen/screen.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/screenViewModel.dart';
import 'package:gic_flutter/src/backend/services/screenService.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'compressedFileService.dart';

class ScreenImportService {
  String screensDirectory = "";

  init() async {
    Directory appFolder = await getApplicationDocumentsDirectory();
    screensDirectory = path.join(appFolder.path, ScreenService.screenFolder);
  }

  Future<ScreenViewModel> importJson(String fileToImport) async {
    //simple import, this should be an absolute path to asset folder
    String json = await rootBundle.loadString(fileToImport);
    int newId = _findNewScreenId();
    ScreenViewModel importedScreen =
        _importScreenJson(jsonToImport: json, newScreenId: newId);

    await importedScreen.save();

    return importedScreen;
  }

  importZip(String fileToImport) async {
    int newId = _findNewScreenId(); //new screen id for us to use

    //extract here
    Directory tempFolder = await getTemporaryDirectory();
    String importPath = path.join(tempFolder.path, "screenImports");

    //extract compressed file
    String originalId = CompressedFileService.extract(fileToImport, importPath);

    //build the path to the extracted contents
    String extractedContents = path.join(importPath, originalId);

    //import the json file
    String pathOfJson = path.join(extractedContents, "data.json");
    String json = await File(pathOfJson).readAsString();
    ScreenViewModel importedScreen =
        _importScreenJson(jsonToImport: json, newScreenId: newId);
    File? screenFile = await importedScreen.save(); //save once to generate the folder structure

    //now just... copy everything inside?
    Directory extractedFileLocation = Directory(extractedContents);
    List<FileSystemEntity> extractedFiles = extractedFileLocation.listSync();
    extractedFiles.forEach(await (element) {
      print("element ${element.path}");
      if (path.extension(element.path) != ".json") {
        File toCopy = File(element.path);
        String basename = path.basename(toCopy.path);
        String destination = path.join(screenFile!.parent.path, basename);
        toCopy.copySync(destination);
        //search for any instances that point to this image, and update accordingly
        if (importedScreen.backgroundPath!.contains(basename)) {
          importedScreen.backgroundPath = destination;
          // importedScreen.backgroundColor = null;
        }
        for (int i = 0; i < importedScreen.controls!.length; i++) {
          for (int n = 0;
              n < importedScreen.controls![i].images.length;
              n++) {
            if (importedScreen.controls![i].images[n].contains(basename)) {
              importedScreen.controls![i].images[n] = destination;
            }
          }
                }
            }
    });

    //re save the json file
    await importedScreen.save();

    //cleanup
    Directory(importPath).deleteSync(recursive: true);

    return importedScreen;
  }

  /// This will create a screen object based on the imported json
  ScreenViewModel _importScreenJson({String jsonToImport = "", int newScreenId = -1}) {
    Map rawJson = json.decode(jsonToImport);
    ScreenViewModel screenToImport;
    if (rawJson.containsKey("version")) {
      //get a screen object based on the JSON extracted
      screenToImport = ScreenViewModel.fromJson(json.decode(jsonToImport));
    } else {
      //legacy
      // get a screen object based on the JSON extracted
      Map<String, dynamic> controlMap = jsonDecode(jsonToImport);
      //build the new screen from the incoming json
      Screen legacy = Screen.fromJson(controlMap);
      screenToImport = ScreenViewModel.fromLegacyModel(legacy);
    }
    //now we need to get a new ID, as the existing one is probably taken
    screenToImport.screenId = newScreenId;

    return screenToImport;
  }

  /// This will find a unique ID to provide for a new screen
  /// this will scan the existing directories, and find the first unused #
  int _findNewScreenId() {
    int startingId = 0;
    String checkIfExists = path.join(screensDirectory, startingId.toString());

    while (Directory(checkIfExists).existsSync()) {
      startingId++;
      checkIfExists = path.join(screensDirectory, startingId.toString());
    }
    return startingId;
  }
}
