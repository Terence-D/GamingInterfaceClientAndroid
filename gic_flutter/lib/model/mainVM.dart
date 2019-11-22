import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:gic_flutter/model/screen/Screens.dart';
import 'package:gic_flutter/services/setting/settingRepository.dart';

class MainVM extends Equatable {
  SettingRepository _settingRepo;

  int _selectedScreenId;
  bool _firstRun;
  bool _darkMode;
  String _address;
  String _password;
  String _port;
  bool _donate;
  bool _donateStar;
  List<ScreenListItem> screenList = new List<ScreenListItem>();

  MainVM(SettingRepository settingRepo) {
    _settingRepo = settingRepo;
  }

  Future<void> saveSettings() async {
    await _settingRepo.saveMainSettings(_address, _port, _password, selectedScreenId);
  }

  Future<void> loadSettings(BuildContext context) async {
    await _settingRepo.loadSettings();
    _selectedScreenId = _settingRepo.selectedScreenId;
    _address = _settingRepo.address;
    _port = _settingRepo.port;
    _firstRun = _settingRepo.firstRun;
    _donate = _settingRepo.donate;
    _donateStar = _settingRepo.donateStar;
    _darkMode = _settingRepo.darkMode;
    _password = _settingRepo.password;
    Screens _screenRepo = new Screens();
    LinkedHashMap _screenListMap = await _screenRepo.getScreenList(context);
    screenList = new List();
    if (_screenListMap != null && _screenListMap.length > 0) {
      _screenListMap.forEach((k, v) => screenList.add(new ScreenListItem(k, v)) );
      debugPrint("${screenList.length}");
    }
  }

  int get selectedScreenId => _selectedScreenId;
  bool get firstRun => _firstRun;
  bool get darkMode => _darkMode;
  bool get donate => _donate;
  bool get donateStar => _donateStar;
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
  set selectedScreenId(int newValue) {
    _selectedScreenId = newValue;
  }

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