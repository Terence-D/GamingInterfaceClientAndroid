import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:gic_flutter/services/setting/settingRepository.dart';

class MainVM extends Equatable {
  SettingRepository _settingRepo;

  int _selectedScreenId;
  bool _firstRun;
  bool _darkMode;
  String _address;
  String _password;
  String _port;
  List<ScreenListItem> _screenList = new List<ScreenListItem>();

  MainVM(SettingRepository settingRepo) {
    _settingRepo = settingRepo;
  }

  Future<void> saveSettings() async {
    await _settingRepo.saveMainSettings(_address, _port, _password);
  }

  Future<void> loadSettings() async {
    await _settingRepo.loadSettings();
    _selectedScreenId = _settingRepo.selectedScreenId;
    _address = _settingRepo.address;
    _port = _settingRepo.port;
    _firstRun = _settingRepo.firstRun;
    _darkMode = _settingRepo.darkMode;
    _password = _settingRepo.password;
    LinkedHashMap _screenListMap = _settingRepo.screenList;
    _screenList = new List();
    _screenListMap.forEach((k, v) => _screenList.add(new ScreenListItem(k, v)) );
  }

  int get selectedScreenId => _selectedScreenId;
  bool get firstRun => _firstRun;
  bool get darkMode => _darkMode;
  String get address => _address;
  String get password => _password;
  String get port => _port;
  set password(String newValue)  {
     _password = newValue;
  }
  set address(String newValue) { 
  _address = newValue;
  }
  set port(String newValue) { 
  _port = newValue;
  }

  List<ScreenListItem> get screenList => _screenList;

  String get toolbarTitle => "Gaming Interface Client";
  String get screenTitle => "GIC";

  set darkMode(bool newValue) => _setDarkMode(newValue);

  _setDarkMode(bool newValue) {
    _darkMode = newValue;
    _settingRepo.setDarkMode (newValue);
  }
}

class ScreenListItem {
  const ScreenListItem(this.id, this.name);

  final String name;
  final int id;
}