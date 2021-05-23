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
  ok,
  disabled,
  enabled,
  commandTabHeader,
  commandTabPrimaryDetails,
  commandTabPrimaryToggleDetails,
  commandTabSecondaryDetails,
  commandTabQuickModeDetails,
  commandDropDownHint,
  textTabHeader,
  textTabPrimaryDetails,
  textTabPrimaryToggleDetails,
  textTabFontColor,
  textTabFont,
  textTabFontSize,
  sizeTabHeader,
  sizeTabLeft,
  sizeTabTop,
  sizeTabWidth,
  sizeTabHeight,
  sizeTabDetails,
  designTabHeader,
  designTabDetails,
  designTabPrimaryColor,
  designTabSecondaryColor,
  designTabPressedImage,
  designTabUnpressedImage,
  designTabToggleOffImage,
  designTabToggleOnImage,
  designTabImport,
  designTabPickColor,
  designTabChooseImage,
  designTabImageBased,
  designTabColorBased,
  controlDialogTitle,
  widgetDeleted,
  undo
}

class IntlScreenEditor {
  BuildContext _context;

  IntlScreenEditor(this._context);

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
      ScreenEditorText.disabled: "Quick Mode Off",
      ScreenEditorText.enabled: "Quick Mode On",
      ScreenEditorText.commandTabHeader: "Commands",
      ScreenEditorText.commandTabPrimaryDetails:
          "Choose a command to send, along with any modifiers (such as Control or Shift keys)",
      ScreenEditorText.commandTabPrimaryToggleDetails:
          "Choose a command to send when the toggle is set, along with any modifiers (such as Control or Shift keys)",
      ScreenEditorText.commandTabSecondaryDetails:
          "Choose a command to send when the toggle is reset, along with any modifiers (such as Control or Shift keys)",
      ScreenEditorText.commandTabQuickModeDetails:
          "Quick Mode - Enable this if you need to quickly send a command.  Disable if you need to hold it down longer for the command to activate on the server.",
      ScreenEditorText.commandDropDownHint: "Choose a Command",
      ScreenEditorText.textTabHeader: "Text/Font",
      ScreenEditorText.textTabPrimaryDetails: "Enter the text you want shown",
      ScreenEditorText.textTabPrimaryToggleDetails:
          "Enter the text you want shown when toggle is off, and customize the display of the font",
      ScreenEditorText.textTabFontColor: "Color",
      ScreenEditorText.textTabFont: "Font",
      ScreenEditorText.textTabFontSize: "Size",
      ScreenEditorText.sizeTabHeader: "Dimensions",
      ScreenEditorText.sizeTabDetails:
          "Fine tune the size and position of the control",
      ScreenEditorText.sizeTabLeft: "Left",
      ScreenEditorText.sizeTabTop: "Top ",
      ScreenEditorText.sizeTabWidth: "Width",
      ScreenEditorText.sizeTabHeight: "Height",
      ScreenEditorText.designTabDetails:
          "An image or a color gradient can be used decorate your buttons.  If you want to use a custom image, choose Import first.",
      ScreenEditorText.designTabImport: "Import Custom Image",
      ScreenEditorText.designTabHeader: "Design",
      ScreenEditorText.designTabPressedImage:
          "Button Pressed Image",
      ScreenEditorText.designTabPrimaryColor: "Primary Color",
      ScreenEditorText.designTabSecondaryColor: "Secondary Color",
      ScreenEditorText.designTabToggleOffImage:
          "Toggled off Image",
      ScreenEditorText.designTabToggleOnImage:
          "Toggled on Image",
      ScreenEditorText.designTabUnpressedImage:
          "Button Unpressed Image",
      ScreenEditorText.designTabPickColor: "Choose a color",
      ScreenEditorText.designTabChooseImage: "Choose an existing image, or for a custom image choose Import first",
      ScreenEditorText.designTabColorBased: "Use Colors",
      ScreenEditorText.designTabImageBased: "Use Images",
      ScreenEditorText.controlDialogTitle: "Control",
      ScreenEditorText.widgetDeleted: "Control Removed",
      ScreenEditorText.undo: "Undo"
    }
  };
}
