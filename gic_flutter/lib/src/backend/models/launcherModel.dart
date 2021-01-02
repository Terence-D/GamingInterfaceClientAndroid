class LauncherModel {
  String toolbarTitle;
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