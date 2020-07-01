import 'dart:async';

import 'package:gic_flutter/model/launcherModel.dart';
import 'package:gic_flutter/resources/launcherRepository.dart';
import 'package:rxdart/rxdart.dart';

class LauncherBloc {
  final _repository = LauncherRepository();
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

  Future<int> newScreen() async {
    int newId = await _repository.newScreen();
    await fetchAllPreferences();

    return newId;
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