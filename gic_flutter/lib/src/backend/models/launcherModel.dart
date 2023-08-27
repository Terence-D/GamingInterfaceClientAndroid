/// TODO this should be renamed
class LauncherModel {
  String toolbarTitle = "";
  bool firstRun = false;
  bool darkMode = true;
  bool sound = false;
  bool vibration = false;
  bool keepScreenOn = false;
  String address = "";
  String password = "";
  String port = "";
  bool donate = false;
  bool donateStar = false;
  List<ScreenListItem> screens = [];
  int newScreenid = 0;
}

class ScreenListItem {
  ScreenListItem(this.id, this.name);

  String? name;
  final int? id;
}
