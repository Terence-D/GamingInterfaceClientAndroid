import 'package:equatable/equatable.dart';
import 'package:gic_flutter/services/setting/settingRepository.dart';

class MainVM extends Equatable {
  SettingRepository _settingRepo;

  bool _firstRun;
  bool _darkMode;
  String _address;
  String _password;
  String _port;

  MainVM(SettingRepository settingRepo) {
    _settingRepo = settingRepo;
  }

  void loadSettings() async {
    _address = _settingRepo.address;
    _port = _settingRepo.port;
    _firstRun = _settingRepo.firstRun;
    _darkMode = _settingRepo.darkMode;
    _password = await _settingRepo.password;
  }

  bool get firstRun => _firstRun;
  bool get darkMode => _darkMode;
  String get address => _address;
  String get password => _password;
  String get port => _port;

  String get toolbarTitle => "Gaming Interface Client";
  String get screenTitle => "GIC";
}