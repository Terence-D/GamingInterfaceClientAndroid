import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/screen/gicControl.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/font.dart';

import '../command.dart';
import '../controlTypes.dart';

enum ControlViewModelType { Button, Text, Image, Toggle, QuickButton }

enum ControlDesignType { Image, UpDownGradient }

class ControlViewModel {
  ControlViewModelType type = ControlViewModelType.Button;
  ControlDesignType design = ControlDesignType.Image;

  List<Command> commands = new List<Command>();

  String text = "-";
  Font font = new Font();

  double left = 0;
  double width = 320;
  double top = 120;
  double height = 120;

  List<Color> colors = new List<Color>();
  List<String> images = new List<String>();

  ControlViewModel();

  factory ControlViewModel.fromLegacyModel(GicControl model) {
    ControlViewModel rv = new ControlViewModel();
    rv.text = model.text;
    rv.left = model.left;
    rv.top = model.top;
    rv.width = model.width.toDouble();
    rv.height = model.height.toDouble();
    rv.type = _getType(model.viewType);
    rv.commands = _getCommands(model);
    rv.font = _getFont(model);
    rv.colors = _getColors(model);
    rv.images = _getImages(model);
    if (rv.images.isEmpty) rv.design = ControlDesignType.UpDownGradient;

    return rv;
  }

  factory ControlViewModel.fromJson(Map<String, dynamic> json) {
    ControlViewModel rv = new ControlViewModel();
    rv.design = json['design'];
    rv.text = json['text'];
    rv.left = json['left'];
    rv.top = json['top'];
    rv.width = json['width'];
    rv.height = json['height'];
    rv.type = json['type'];
    rv.commands = json['commands'];
    rv.font = json['font'];
    rv.colors = json['colors'];
    rv.images = json['images'];

    return rv;
  }

  Map<String, dynamic> toJson() => {
        'version': "2",
        'type': type,
        'design': design,
        'commands': commands,
        'text': text,
        'left': left,
        'width': width,
        'top': top,
        'height': height,
        'font': font,
        'colors': colors,
        'images': images,
      };

  static ControlViewModelType _getType(int viewType) {
    switch (viewType) {
      case 0:
        return ControlViewModelType.Button;
      case 1:
        return ControlViewModelType.Text;
      case 2:
        return ControlViewModelType.Image;
      case 3:
        return ControlViewModelType.Toggle;
      default:
        return ControlViewModelType.QuickButton;
    }
  }

  static List<Command> _getCommands(GicControl model) {
    List<Command> rv = new List<Command>();
    if (model.command != null) {
      rv.add(model.command);
      if (model.commandSecondary != null) rv.add(model.commandSecondary);
    }
    return rv;
  }

  static Font _getFont(GicControl model) {
    Font rv = new Font();
    if (model.fontColor == -1)
      rv.color = Colors.white;
    else
      rv.color = _convertJavaColor(model.fontColor);
    rv.size = model.fontSize.toDouble();
    if (model.fontName != null && model.fontName.isNotEmpty) {
      rv.family = model.fontName;
    }

    return rv;
  }

  static List<Color> _getColors(GicControl model) {
    List<Color> colors = new List<Color>();
    if (model.primaryColor == -1)
      colors.add(Colors.black);
    else
      colors.add(_convertJavaColor(model.primaryColor));
    if (model.secondaryColor == -1)
      colors.add(Colors.white);
    else
      colors.add(_convertJavaColor(model.secondaryColor));

    return colors;
  }

  /// Convert legacy java color to Flutter Color
  static Color _convertJavaColor(int legacyColor) {
    return Color(legacyColor);
  }

  static List<String> _getImages(GicControl model) {
    List<String> images = new List<String>();
    if (model.primaryImage != null && model.primaryImage.isNotEmpty)
      images.add(model.primaryImage);
    else if (model.primaryImageResource != -1)
      images.add(_convertDrawableResource(
          model.primaryImageResource, model.viewType, true));
    else
      return images; //mo primary, no secondary
    if (model.secondaryImage != null && model.secondaryImage.isNotEmpty)
      images.add(model.secondaryImage);
    else if (model.secondaryImageResource != -1)
      images.add(_convertDrawableResource(
          model.secondaryImageResource, model.viewType, false));

    return images;
  }

  static String _convertDrawableResource(
      int imageResource, int viewType, bool isPrimary) {
    if (viewType == 0 || viewType == 4) {
      //its a button
      if (imageResource < ControlTypes.buttonDrawables.length)
        return ControlTypes.buttonDrawables[imageResource];
      if (isPrimary)
        return ControlTypes.buttonDrawables[2]; //blue
      else
        return ControlTypes.buttonDrawables[3]; //dark blue
    } else {
      if (imageResource < ControlTypes.buttonDrawables.length)
        return ControlTypes.toggleDrawables[imageResource];
      if (isPrimary)
        return ControlTypes.toggleDrawables[2];
      else
        return ControlTypes.toggleDrawables[3];
    }
  }
}
