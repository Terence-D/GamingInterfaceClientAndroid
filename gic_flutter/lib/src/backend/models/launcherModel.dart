class LauncherModel {
  String toolbarTitle = "";
  bool firstRun = false;
  bool darkMode = true;
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

  String name;
  final int id;
}