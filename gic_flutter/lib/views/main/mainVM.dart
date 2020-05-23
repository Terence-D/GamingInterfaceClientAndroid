import 'package:equatable/equatable.dart';
import 'package:gic_flutter/model/viewModel.dart';

class MainVM extends Equatable implements ViewModel {
  String toolbarTitle = "Gaming Interface Client";
  String get screenTitle => " ";

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
  ScreenListItem(this.id, this.name);

  String name;
  final int id;
}