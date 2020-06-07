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

  saveMainSettings(String address, String port, String password, int screenId) {
    _repository.saveMainSettings(address, port, password, screenId);
  }


  setDarkTheme(bool newValue) {
    _repository.setDarkMode(newValue);
  }

  dispose() {
    _modelFetcher.close();
  }

  Future<void> updateScreenName(int id, String text) async {
    _repository.updateName(id, text);
  }
}