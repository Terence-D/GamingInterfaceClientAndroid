import 'dart:async';

import 'package:gic_flutter/model/launcherModel.dart';
import 'package:gic_flutter/resources/launcherRepo.dart';
import 'package:rxdart/rxdart.dart';

class LauncherBloc {
  final _repository = LauncherRepo();
  final _modelFetcher = PublishSubject<LauncherModel>();

  Stream<LauncherModel> get preferences => _modelFetcher.stream;

  fetchAllPreferences() async {
    LauncherModel itemModel = await _repository.fetch();
    _modelFetcher.sink.add(itemModel);
  }

  saveMainSettings(String address, String port, String password) {
    _repository.saveMainSettings(address, port, password);
  }


  setDarkTheme(bool newValue) {
    _repository.setDarkMode(newValue);
  }

  dispose() {
    _modelFetcher.close();
  }

  newScreen() async {
    await _repository.newScreen();
    await fetchAllPreferences();
  }


  Future<void> updateScreenName(int id, String text) async {
    _repository.updateName(id, text);
  }

  Future deleteScreen(int id) async {
    int rv = await _repository.deleteScreen(id);

    if (rv < 0) {
//          _contract.onError(1);
    } else {
      fetchAllPreferences();
    }
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