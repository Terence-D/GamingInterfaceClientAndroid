import 'package:equatable/equatable.dart';

class MainVM extends Equatable {
  String get toolbarTitle => "Gaming Interface Client";
  String get screenTitle => "GIC";

  ScreenListItem selectedScreen;
  bool firstRun;
  bool darkMode;
  String address;
  String password;
  String port;
  bool donate;
  bool donateStar;
  List<ScreenListItem> screenList = new List<ScreenListItem>();
}

abstract class MainVMRepo {
  fetch();
}

class FetchDataException implements Exception {
  String _message;

  FetchDataException(this._message);

  String toString() {
    return "Exception: $_message";
  }
}

class ScreenListItem {
  const ScreenListItem(this.id, this.name);

  final String name;
  final int id;
}