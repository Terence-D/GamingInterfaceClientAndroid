import 'package:gic_flutter/model/screen/gicControl.dart';

class NewScreenWizardModel {
  String toolbarTitle;

  int screenWidth;
  int screenHeight;
  int horizontalControlCount;
  int verticalControlCount;
  List<Control> controls;
  String screenName;
  String buttonNormalImage;
  String buttonPressedImage;
  String switchNormalImage;
  String switchPressedImage;
}

class Control {
  String text;
  String key;
  int type = GicControl.TYPE_BUTTON;
  List<String> modifiers = new List<String>();
}
