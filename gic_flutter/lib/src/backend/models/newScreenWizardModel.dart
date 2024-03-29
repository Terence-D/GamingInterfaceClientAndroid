class NewScreenWizardModel {
  String toolbarTitle = "";
  //These are built in the view and passed back as requires Context
  double screenWidth = 0;
  double screenHeight = 0;

  String screenName = "";
  bool isLandscape = true; // used for constructing the above screen values.  User set
  //Grid view related
  int horizontalControlCount = 1;
  int verticalControlCount = 1;
  //default look for both
  String buttonNormalImage = "";
  String buttonPressedImage = "";
  String switchNormalImage = "";
  String switchPressedImage = "";

  late List controls; // our list of controls to create
}

/// This is used purely for the "new screen" view model
class NewScreenWizardControl {
  String text = "";
  String key = "";
  bool isSwitch = false;
  bool alt = false;
  bool ctrl = false;
  bool shift= false;
}
