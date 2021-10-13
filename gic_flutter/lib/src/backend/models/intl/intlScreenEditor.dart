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
  designTabImageDetails,
  designTabPrimaryColor,
  designTabSecondaryColor,
  designTabPressedImage,
  designTabUnpressedImage,
  designTabToggleOffImage,
  designTabToggleOnImage,
  designTabImport,
  designTabPickColor,
  designTabImageBased,
  designTabColorBased,
  controlDialogTitle,
  widgetDeleted,
  undo,
  previewHeader,
  helpMessage,
  helpDialogTitle,
  helpEditHeader,
  helpEditDetails,
  helpMoveHeader,
  helpMoveDetails,
  helpSizeHeader,
  helpSizeDetails,
  helpQuitHeader,
  helpQuitDetails,
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
      ScreenEditorText.menu: "Settings",
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
      ScreenEditorText.textTabPrimaryDetails: "Type in the text you want shown, and pick the color, size, and font you want to use.",
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
      ScreenEditorText.designTabImageDetails: "Import an image to display",
      ScreenEditorText.designTabImport: "Import Custom Image",
      ScreenEditorText.designTabHeader: "Design",
      ScreenEditorText.designTabPressedImage: "Button Pressed Image",
      ScreenEditorText.designTabPrimaryColor: "Primary Color",
      ScreenEditorText.designTabSecondaryColor: "Secondary Color",
      ScreenEditorText.designTabToggleOffImage: "Toggled off Image",
      ScreenEditorText.designTabToggleOnImage: "Toggled on Image",
      ScreenEditorText.designTabUnpressedImage: "Button Unpressed Image",
      ScreenEditorText.designTabPickColor: "Choose a color",
      ScreenEditorText.designTabColorBased: "Use Colors",
      ScreenEditorText.designTabImageBased: "Use Images",
      ScreenEditorText.controlDialogTitle: "Editor",
      ScreenEditorText.widgetDeleted: "Control Removed",
      ScreenEditorText.undo: "Undo",
      ScreenEditorText.previewHeader: "Preview",
      ScreenEditorText.helpMessage: "To get started, Double Tap on a Control or on the Screen to start!  You can also use the Back button (or gesture) to exit without saving.  You can move controls around by dragging or in the double tap menu.",
      ScreenEditorText.helpDialogTitle: "Help",
      ScreenEditorText.helpEditHeader:"Editing",
      ScreenEditorText.helpEditDetails:"To Edit a Control (Button, Toggle, Image, or Text), press and hold your finger on top of the Control you wish to modify until a menu appears.  Editing a Control by this method allows you to modify look, size, and (if a button or switch) the commands you can send to your computer.  It allows extremely fine control of its position on the screen and size, more so than using some of the other methods.  Tap on one of the other icons at the top to view more tips, or the Back arrow to exit.",
      ScreenEditorText.helpMoveHeader:"Moving",
      ScreenEditorText.helpMoveDetails:"You can move a Control by holding your finger down and dragging it to where you want it to.  Although less precise than using the Edit option (previous help tip), it allows a quick way to adjust your screen quickly.  You can also use the Grid option in the previous menu to make it easier to line Controls up with each other.",
      ScreenEditorText.helpSizeHeader:"Rescaling",
      ScreenEditorText.helpSizeDetails: "You can also quickly adjust the scale of the Control by using your fingers to Pinch to Zoom.  This will probably be tweaked as its fairly difficult to use, but is another alternative to the more precise editing in the Edit Control view mentioned earlier ReYou can Size a Control by holding your finger down and dragging it to where you want it to.  Although less precise than using the Edit option (previous help tip), it allows a quick way to adjust your screen quickly.  You can also use the Grid option in the previous menu to make it easier to line Controls up with each other.",
      ScreenEditorText.helpQuitHeader:"Quit",
      ScreenEditorText.helpQuitDetails:"Exiting the Screen editor can be done the same way as any other full screen app on your device.  If buttons are visible, you can press the Back button, or swipe from one of the edges of the screen.",
    }
  };
}
