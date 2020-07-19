import 'package:flutter/material.dart';
import 'package:gic_flutter/model/intl/localizations.dart';

enum NewScreenWizardText {
  toolbarTitle,
  save,
  next,
  screenName,
  increaseHorizontal,
  increaseVertical,
  decreaseHorizontal,
  decreaseVertical,
  buttonDesign,
  buttonNormal,
  buttonPressed,
  switchDesign,
  switchNormal,
  switchPressed,
  orientation,
  layout
}

class IntlNewScreenWizard {
  BuildContext _context;

  IntlNewScreenWizard(this ._context);

  String text(NewScreenWizardText text) {
    return _localizedStrings[Intl.of(_context).locale.languageCode][text];
  }

  static Map<String, Map<NewScreenWizardText, String>> _localizedStrings = {
    'en': {
      NewScreenWizardText.toolbarTitle: 'New Screen Wizard',
      NewScreenWizardText.save: "Save",
      NewScreenWizardText.next: "Next",
      NewScreenWizardText.screenName: 'Screen Name',
      NewScreenWizardText.increaseHorizontal: "More Horizontal Controls",
      NewScreenWizardText.increaseVertical: "More Vertical Controls",
      NewScreenWizardText.decreaseHorizontal: "Less Horizontal Controls",
      NewScreenWizardText.decreaseVertical: 'Less Vertical Controls',
      NewScreenWizardText.buttonDesign: "Button Design",
      NewScreenWizardText.buttonNormal: "Normal",
      NewScreenWizardText.buttonPressed: "Pressed",
      NewScreenWizardText.switchDesign: 'Switch Design',
      NewScreenWizardText.switchNormal: "Normal",
      NewScreenWizardText.switchPressed: "Pressed",
      NewScreenWizardText.orientation: "Orientation",
      NewScreenWizardText.layout: "Layout",
    }
  };
}
