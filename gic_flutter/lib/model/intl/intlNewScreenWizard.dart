import 'package:flutter/material.dart';
import 'package:gic_flutter/model/intl/localizations.dart';

enum NewScreenWizardText {
  toolbarTitle,
  save,
  next,
  screenName,
  increase,
  decrease,
  buttonDesign,
  buttonNormal,
  buttonPressed,
  switchDesign,
  switchNormal,
  switchPressed,
  orientation,
  layout,
  controlsWide,
  controlsDepth,
  totalControls,
  buttonType,
  switchType,
  quickTap,
  ctrl, alt, shift,
  errorEnterScreenName
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
      NewScreenWizardText.increase: "Add",
      NewScreenWizardText.decrease: 'Remove',
      NewScreenWizardText.buttonDesign: "Button Design",
      NewScreenWizardText.buttonNormal: "Normal",
      NewScreenWizardText.buttonPressed: "Pressed",
      NewScreenWizardText.switchDesign: 'Switch Design',
      NewScreenWizardText.switchNormal: "Normal",
      NewScreenWizardText.switchPressed: "Pressed",
      NewScreenWizardText.orientation: "Orientation",
      NewScreenWizardText.layout: "Layout",
      NewScreenWizardText.controlsWide: "Controls Wide",
      NewScreenWizardText.controlsDepth: "Controls Deep",
      NewScreenWizardText.totalControls: "Total Controls",
      NewScreenWizardText.buttonType: "Button",
      NewScreenWizardText.switchType: "Switch",
      NewScreenWizardText.quickTap: "Quick Mode",
      NewScreenWizardText.ctrl: "Ctrl",
      NewScreenWizardText.alt: "Alt",
      NewScreenWizardText.shift: "Shift",
      NewScreenWizardText.errorEnterScreenName: "Please enter a screen name!"
    }
  };
}
