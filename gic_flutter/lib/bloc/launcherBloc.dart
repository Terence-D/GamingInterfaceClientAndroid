import 'dart:async';

import 'package:gic_flutter/model/launcherModel.dart';
import 'package:gic_flutter/resources/launcherRepository.dart';
import 'package:rxdart/rxdart.dart';

/// LauncherBloc acts as the Presentation layer for the Launcher UI
class LauncherBloc {
  LauncherRepository _repository;
  PublishSubject _modelFetcher;

  LauncherBloc() {
    this._repository = new LauncherRepository();
    this._modelFetcher = new PublishSubject<LauncherModel>();
  }

  LauncherBloc.withMocks (repository) {
    _repository = repository;
    this._modelFetcher = new PublishSubject<LauncherModel>();
  }

  Stream<LauncherModel> get preferences => _modelFetcher.stream;

   /// Loads the preferences from the repository, and adds to the sink
  void fetchAllPreferences() async {
    LauncherModel itemModel = await _repository.fetch();
    _modelFetcher.sink.add(itemModel);
  }

  /// saves the server connection settings
  ///
  /// @param address Address for the GIC server
  /// @param port Port number of the GIC server
  /// @param password Secret for securing the connection to the GIC server
  void saveConnectionSettings(String address, String port, String password) {
    _repository.saveMainSettings(address, port, password);
  }

  /// Sets the theme to be light or dark
  ///
  /// @param isDarkMode if true, makes it dark.  if false, sets it to light mode
  void setTheme(bool isDarkMode) {
    _repository.setDarkMode(isDarkMode);
  }

  /// closes the stream
  void dispose() {
    _modelFetcher.close();
  }

  /// Adds a new GIC screen
  ///
  /// @return the ID of the new screen
  Future<int> newScreen() async {
    int newId = await _repository.newScreen();
    await fetchAllPreferences();

    return newId;
  }

  /// Changes the screen name
  ///
  /// @param id Id of the screen we want to update the name of
  /// @param newName New name of the screen
  Future<void> updateScreenName(int id, String newName) async {
    _repository.updateName(id, newName);
  }

  /// Deletes the screen
  ///
  /// @param id The Id of the screen we want to remove
  /// @return The new cache size, or -1 if an error occurs
  Future<int> deleteScreen(int id) async {
    int rv = await _repository.deleteScreen(id);

    if (rv >= 0) {
      fetchAllPreferences();
    }

    return rv;
  }

  Future<int> import(file) async {
    int newItemId = await _repository.import(file);
    fetchAllPreferences();

    return newItemId;
  }

  export(String exportPath, int id) async {
    await _repository.export(exportPath, id);
  }
}