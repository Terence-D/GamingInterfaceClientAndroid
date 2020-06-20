import 'package:gic_flutter/model/viewModel.dart';

class LauncherModel implements ViewModel {
  String _title;

  @override
  String get toolbarTitle => _title;

  bool firstRun;
  bool darkMode;
  String address;
  String password;
  String port;
  bool donate;
  bool donateStar;
  List<ScreenListItem> screens;
  int newScreenid = 0;
}

class ScreenListItem {
  ScreenListItem(this.id, this.name);

  String name;
  final int id;
}