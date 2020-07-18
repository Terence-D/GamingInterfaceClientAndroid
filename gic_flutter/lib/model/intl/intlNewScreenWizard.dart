import 'package:flutter/material.dart';
import 'package:gic_flutter/model/intl/localizations.dart';

enum NewScreenWizardText {
  toolbarTitle,
  save
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
      NewScreenWizardText.save: "Save"
    }
  };
}
