import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/intl/localizations.dart';

enum ScreenEditorText {
  addButton,
  addToggle,
  addText,
  addImage,
  setBackground,
  setGrid,
  save,
  menu,
  backgroundMenu,
  backgroundColor,
  backgroundImage,
  ok
}

class IntlScreenEditor {
  BuildContext _context;

  IntlScreenEditor(this ._context);

  String text(ScreenEditorText text) {
    return _localizedStrings[Intl.of(_context).locale.languageCode][text];
  }

  static Map<String, Map<ScreenEditorText, String>> _localizedStrings = {
    'en': {
      ScreenEditorText.addButton: "Add Button",
      ScreenEditorText.addToggle: "Add Toggle",
      ScreenEditorText.addText: "Add Text",
      ScreenEditorText.addImage: "Add Image",
      ScreenEditorText.setBackground: "Background",
      ScreenEditorText.setGrid: "Grid Size",
      ScreenEditorText.save: "Save",
      ScreenEditorText.menu: "Menu",
      ScreenEditorText.backgroundMenu: "Background Style",
      ScreenEditorText.backgroundColor: "Color",
      ScreenEditorText.backgroundImage: "Image",
      ScreenEditorText.ok: "Ok",
    }
  };
}
