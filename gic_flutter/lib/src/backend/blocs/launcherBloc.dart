import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/launcherModel.dart';
import 'package:gic_flutter/src/backend/models/networkModel.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/screenViewModel.dart';
import 'package:gic_flutter/src/backend/repositories/launcherRepository.dart';
import 'package:rxdart/rxdart.dart';

/// LauncherBloc acts as the Presentation layer for the Launcher UI
class LauncherBloc {
  LauncherRepository? _repository;
  PublishSubject? _modelFetcher;
  LauncherModel? itemModel;

  LauncherBloc() {
    this._repository = LauncherRepository();
    this._modelFetcher = PublishSubject<LauncherModel>();
  }

  LauncherBloc.withMocks(repository) {
    _repository = repository;
    this._modelFetcher = PublishSubject<LauncherModel>();
  }

  Stream get preferences => _modelFetcher!.stream;

  /// Loads the preferences from the repository, and adds to the sink
  Future<void> fetchAllPreferences() async {
    itemModel = await _repository!.fetch();
    _modelFetcher?.sink.add(itemModel);
  }

  /// saves the server connection settings
  ///
  /// @param address Address for the GIC server
  /// @param port Port number of the GIC server
  /// @param password Secret for securing the connection to the GIC server
  void saveConnectionSettings(NetworkModel networkModel) {
    _repository?.saveMainSettings(networkModel);
  }

  /// Sets the purchase value
  void setDonation(String id, bool newValue) {
    _repository?.setDonation(id, newValue);
  }

  /// closes the stream
  void dispose() {
    _modelFetcher?.close();
  }

  /// Changes the screen name
  ///
  /// @param id Id of the screen we want to update the name of
  /// @param newName New name of the screen
  Future<void> updateScreenName(int? id, String? newName) async {
    await _repository?.updateName(id, newName);
  }

  /// Deletes the screen
  ///
  /// @param id The Id of the screen we want to remove
  /// @return The new cache size, or -1 if an error occurs
  Future<int> deleteScreen(int? id) async {
    int? rv = await _repository?.deleteScreen(id);

    if (rv! >= 0) {
      await fetchAllPreferences();
    }

    return rv;
  }

  /// Imports a new screen into GIC
  ///
  /// @param file the file we are importing
  /// @return the new Id of the imported screen, or a negative value on failure
  Future<int> import(String file) async {
    int newItemId = await _repository!.import(file);
    await fetchAllPreferences();

    return newItemId;
  }

  /// Exports a new screen into GIC
  ///
  /// @param exportPath directory we are exporting to
  /// @param id Id of the screen we want to export
  /// @return complete path of file
  Future<String> export(String? exportPath, int? id) async {
    return await _repository!.export(exportPath, id);
  }

  Future<List> checkScreenSize(int screenId) async {
    return await _repository!.checkScreenSize(screenId);
  }

  List getDimensions(BuildContext context) {
    return _repository!.buildDimensions(context);
  }

  bool getSound() {
    return itemModel!.sound;
  }

  bool getVibration() {
    return itemModel!.vibration;
  }

  bool getKeepScreenOn() => itemModel!.keepScreenOn;

  /// and resizes the screen to fit the devices dimensions
  /// saved as a new screen
  void resize(int screenId, BuildContext context) async {
    await _repository!.resizeScreen(screenId, context);
    await fetchAllPreferences();
  }

  Future<ScreenViewModel?> loadScreen(int screenId) async {
    return await _repository!.setActiveScreen(screenId);
  }
}
