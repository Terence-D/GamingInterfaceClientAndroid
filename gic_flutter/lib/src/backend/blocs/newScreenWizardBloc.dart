import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/newScreenWizardModel.dart';
import 'package:gic_flutter/src/backend/models/screen/command.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';
import 'package:gic_flutter/src/backend/services/screenService.dart';

/// This is the presentation layer of the new screen wizard ui
/// It's pretty simplistic, and doesn't need a lot of bloc fanciness
/// but in the interest of keeping like minded code together, keeping the
/// naming convention standard
class NewScreenWizardBloc {
  ScreenService _screenService = ScreenService();
  int _margins = 32; //may want to make this user selectable in a future release

  /// Creates a new empty screen
  /// Adds in the controls from the model
  /// Saves it
  Future<void> saveScreen(NewScreenWizardModel model) async {
    //create an initial screen in the list / set the active screen to it
    await _screenService.createScreen();
    //now that we have an active, lets load in the defaults
    await _screenService.initDefaults();

    //set up the defaults based on the model
    _screenService.activeScreenViewModel!.name = model.screenName;
    _screenService.activeScreenViewModel!.backgroundColor = Colors.black54;
    await _buildControls(model);

    //save it
    await _screenService.activeScreenViewModel!.save();
  }

  /// Here we build all of the controls we will add to the new screen
  Future<void> _buildControls(NewScreenWizardModel model) async {
    //to get workable screen width, we need to take the total width passed in
    //then remove a margin for every control we have horizontally, +1
    int workableWidth = model.screenWidth.floor() -
        (_margins * model.horizontalControlCount) -
        (_margins * 2);
    //now we divide that by the number of controls, and we have our control width
    double controlWidth = (workableWidth / model.horizontalControlCount);

    //now do the same for height
    int workableHeight = model.screenHeight.floor() -
        (_margins * model.verticalControlCount) -
        (_margins * 2);
    double controlHeight = (workableHeight / model.verticalControlCount);

    //lets limit the ugly, and hard code a height limit to be 20% max of the screen
    if (controlHeight > (workableHeight * .2))
      controlHeight = workableHeight * .2;

    //build the control in a grid fashion, horizontally x vertically
    int i = 0; //tracks which control we're on
    for (int y = 0; y < model.verticalControlCount; y++) {
      for (int x = 0; x < model.horizontalControlCount; x++) {
        NewScreenWizardControl element = model.controls[i];

        //only proceed if the control has valid OR key
        if (element.text == null && element.key == null) return;

        _screenService.activeScreenViewModel!.controls
            .add(_buildControl(controlHeight, controlWidth, x, y, element));
        i++;
      }
    }
  }

  /// This builds an individual control we are adding to the new screen
  ControlViewModel _buildControl(double controlHeight, double controlWidth,
      int x, int y, NewScreenWizardControl element) {
    ControlViewModel control = ControlViewModel();
    control.height = controlHeight;
    control.width = controlWidth;
    control.left = (_margins + ((_margins + controlWidth) * x));
    control.top = (_margins + ((_margins + controlHeight) * y));

    List<String> mods = [];
    if (element.ctrl) mods.add("CTRL");
    if (element.alt) mods.add("ALT");
    if (element.shift) mods.add("SHIFT");
    control.commands
        .add(Command(key: element.key, modifiers: mods, activatorType: 0));

    ControlViewModel defaultControl =
        _screenService.defaultControls.defaultButton;

    control.text = element.text;
    if (element.isSwitch) {
      //special conditions apply
      control.type = ControlViewModelType.Toggle;
      defaultControl = _screenService.defaultControls.defaultToggle;
      control.images.add("toggle_off");
      control.images.add("toggle_on");
      //shrink the switch to make room for text
    } else {
      control.type = ControlViewModelType.Button;
      control.images.add("button_black");
      control.images.add("button_black2");
    }

    control.colors = defaultControl.colors;
    return control;
  }
}
