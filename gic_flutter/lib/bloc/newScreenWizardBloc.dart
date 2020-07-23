import 'package:gic_flutter/model/controlDefaults.dart';
import 'package:gic_flutter/model/newScreenWizardModel.dart';
import 'package:gic_flutter/model/screen/command.dart';
import 'package:gic_flutter/model/screen/gicControl.dart';
import 'package:gic_flutter/model/screen/screen.dart';
import 'package:gic_flutter/resources/screenRepository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// This is the presentation layer of the new screen wizard ui
/// It's pretty simplistic, and doesn't need a lot of bloc fanciness
/// but in the interest of keeping like minded code together, keeping the
/// naming convention standard
class NewScreenWizardBloc {
  ScreenRepository _repository;

  int _margins = 32; //may want to make this user selectable in a future release

  /// Saves the values into a new screen
  Future<void> saveScreen(NewScreenWizardModel model) async {
    if (_repository == null)
      _repository = new ScreenRepository();
    await _repository.getScreenList();
    int newId = _repository.findUniqueId();
    Screen newScreen = await _buildScreen(model, newId);

    if (newScreen != null)
      _repository.save(newScreen);
  }

  /// constructs a proper screen object based on our model
  /// returns a screen, or null on error
  Future<Screen> _buildScreen(NewScreenWizardModel model, int newId) async {
    Screen newScreen = new Screen();
    newScreen.screenId = newId;
    newScreen.name = model.screenName;
    newScreen.controls = new List();

    newScreen.backgroundColor = 100; //??

    await _buildControls(model, newScreen);
    return newScreen;
  }

  Future<void> _buildControls(NewScreenWizardModel model, Screen newScreen) async {
    //load in defaults
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ControlDefaults defaults = new ControlDefaults(prefs, newScreen.screenId);

    //to get workable screen width, we need to take the total width passed in
    //then remove a margin for every control we have horizontally, +1
    int workableWidth = model.screenWidth.floor() -
        (_margins * model.horizontalControlCount) + _margins;
    //now we divide that by the number of controls, and we have our control width
    int controlWidth = (workableWidth / model.horizontalControlCount).round();

    //now do the same for height
    int workableHeight = model.screenHeight.floor() -
        (_margins * model.verticalControlCount) + _margins;
    int controlHeight = (workableHeight / model.verticalControlCount).round();

    //build the control in a grid fashion, horizontally x vertically
    int i=0; //tracks which control we're on
    for (int y=0; y < model.verticalControlCount; y++) {
      for (int x=0; x < model.horizontalControlCount; x++) {
        Control element = model.controls[i];

        //only proceed if the control has valid name and key
        if (element.text == null || element.key == null)
          return;

        GicControl control = new GicControl.empty();
        control.command = new Command.empty();
        control.commandSecondary = new Command.empty();

        control.text = element.text;

        control.height = controlHeight;
        control.width = controlWidth;

        int left = (_margins + ((_margins + controlWidth) * x));
        int top = (_margins + ((_margins + controlHeight) * y));
        control.left = left.toDouble();
        control.top = top.toDouble();


        control.command.key = element.key;
        control.command.activatorType = 0;

        if (element.ctrl)
          control.command.modifiers.add("CTRL");
        if (element.alt)
          control.command.modifiers.add("ALT");
        if (element.shift)
          control.command.modifiers.add("SHIFT");

        GicControl defaultControl = defaults.defaultButton;
        if (element.isSwitch) {
          control.viewType = GicControl.TYPE_SWITCH;
          defaultControl = defaults.defaultSwitch;
          defaultControl.primaryImageResource = prefs.getInt("default_switch_primary");
          defaultControl.secondaryImageResource = prefs.getInt("default_switch_secondary");
        }
        else {
          control.viewType = GicControl.TYPE_BUTTON;
          defaultControl.primaryImageResource = prefs.getInt("default_button_primary");
          defaultControl.secondaryImageResource = prefs.getInt("default_button_secondary");
        }
        control.primaryColor = defaultControl.primaryColor;
        control.primaryImage = defaultControl.primaryImage;
        control.primaryImageResource = defaultControl.primaryImageResource;
        control.secondaryImage = defaultControl.secondaryImage;
        control.secondaryColor = defaultControl.secondaryColor;
        control.secondaryImageResource = defaultControl.secondaryImageResource;

        //load in the backgrounds
        if (element.isSwitch) {
          control.primaryImage = model.switchNormalImage;
          control.secondaryImage = model.switchPressedImage;
        } else {
          //its a button
          control.primaryImage = model.buttonNormalImage;
          control.secondaryImage = model.buttonPressedImage;
        }
        newScreen.controls.add(control);
        i++;
      }
    }
  }
}