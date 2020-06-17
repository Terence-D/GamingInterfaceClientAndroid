import 'package:gic_flutter/model/viewModel.dart';
import 'package:gic_flutter/views/main/mainVM.dart';

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