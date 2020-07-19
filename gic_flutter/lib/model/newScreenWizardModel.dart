import 'package:gic_flutter/model/screen/gicControl.dart';

class NewScreenWizardModel {
  String toolbarTitle;
  //These are built in the view and passed back as requires Context
  int screenWidth;
  int screenHeight;

  String screenName;
  bool isLandscape = true; // used for constructing the above screen values.  User set
  //Grid view related
  int horizontalControlCount;
  int verticalControlCount;
  //default look for both
  String buttonNormalImage;
  String buttonPressedImage;
  String switchNormalImage;
  String switchPressedImage;

  List<Control> controls; // our list of controls to create
}

class Control {
  String text;
  String key;
  int type = GicControl.TYPE_BUTTON;
  List<String> modifiers = new List<String>();
}
