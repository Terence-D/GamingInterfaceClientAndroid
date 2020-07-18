import 'dart:async';
import 'package:gic_flutter/model/newScreenWizardModel.dart';
import 'package:gic_flutter/model/screen/command.dart';
import 'package:gic_flutter/model/screen/gicControl.dart';
import 'package:gic_flutter/model/screen/screen.dart';
import 'package:gic_flutter/resources/screenRepository.dart';
import 'package:rxdart/rxdart.dart';

/// This is the presentation layer of the new screen wizard ui
/// It's pretty simplistic, and doesn't need a lot of bloc fanciness
/// but in the interest of keeping like minded code together, keeping the
/// naming convention standard
class NewScreenWizardBloc {
  PublishSubject _modelFetcher;
  ScreenRepository _repository;

  int _margins = 16; //may want to make this user selectable in a future release

  NewScreenWizardBloc() {
    this._modelFetcher = new PublishSubject<NewScreenWizardModel>();
  }

  /// Saves the values into a new screen
  void saveScreen(NewScreenWizardModel model) {
    _repository.getScreenList();
    int newId = _repository.findUniqueId();
    Screen newScreen = _buildScreen(model, newId);

    if (newScreen != null)
      _repository.save(newScreen);
  }

  /// closes the stream
  void dispose() {
    _modelFetcher.close();
  }

  /// constructs a proper screen object based on our model
  /// returns a screen, or null on error
  Screen _buildScreen(NewScreenWizardModel model, int newId) {
    Screen newScreen = new Screen();
    newScreen.screenId = newId;
    newScreen.name = model.screenName;

    //to get workable screen width, we need to take the total width passed in
    //then remove a margin for every control we have horizontally, +1
    int workableWidth = model.screenWidth -
        (_margins * model.horizontalControlCount) + _margins;
    //now we divide that by the number of controls, and we have our control width
    int controlWidth = (workableWidth / model.horizontalControlCount).round();

    //now do the same for height
    int workableHeight = model.screenHeight -
        (_margins * model.verticalControlCount) + _margins;
    int controlHeight = (workableHeight / model.verticalControlCount).round();

    model.controls.forEach((element) {
      GicControl control = new GicControl();
      control.command = new Command();

      control.text = element.text;
      control.viewType = element.type;
      control.height = controlHeight;
      control.width = controlWidth;

      control.command.key = element.key;
      control.command.modifiers = element.modifiers;

      //load in the backgrounds
      if (element.type == GicControl.TYPE_SWITCH) {
        control.primaryImage = model.switchNormalImage;
        control.secondaryImage = model.switchPressedImage;
      } else {
        //its a button
        control.primaryImage = model.buttonNormalImage;
        control.secondaryImage = model.buttonPressedImage;
      }
      newScreen.controls.add(control);
    });
    return newScreen;
  }
}