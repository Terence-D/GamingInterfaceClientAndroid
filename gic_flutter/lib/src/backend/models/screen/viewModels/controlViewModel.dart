import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/screen/gicControl.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/font.dart';

import '../command.dart';
import '../controlTypes.dart';

enum ControlViewModelType { Button, Text, Image, Toggle, QuickButton }

ControlViewModelType getTypeFromString(String typeAsString) {
  for (ControlViewModelType element in ControlViewModelType.values) {
    if (element.toString() == typeAsString) {
      return element;
    }
  }
  return null;
}

enum ControlDesignType { Image, UpDownGradient }

ControlDesignType getTypeDesignString(String designAsString) {
  for (ControlDesignType element in ControlDesignType.values) {
    if (element.toString() == designAsString) {
      return element;
    }
  }
  return null;
}

class ControlViewModel {
  int version = 2;

  ControlViewModelType type = ControlViewModelType.Button;
  ControlDesignType design = ControlDesignType.Image;

  List<Command> commands = [];

  String text = "-";
  Font font = Font.empty();

  double left = 0;
  double width = 320;
  double top = 120;
  double height = 120;

  List<Color> colors = [];
  List<String> images = [];

  ControlViewModel();

  factory ControlViewModel.fromLegacyModel(GicControl model) {
    ControlViewModel rv = ControlViewModel();
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

  ControlViewModel clone() {
    ControlViewModel clone = ControlViewModel();
    clone.version = version;
    clone.type = type;
    clone.design = design;
    clone.commands = List.from(commands);
    clone.text = text;
    clone.font = font.clone();
    clone.left = left;
    clone.width = width;
    clone.top = top;
    clone.height = height;
    clone.colors = List.from(colors);
    clone.images = List.from(images);

    return clone;
  }

  ControlViewModel.fromJson(Map<String, dynamic> json)
      : version = json['version'],
        design = getTypeDesignString(json['design']),
        text = json['text'],
        left = json['left'],
        top = json['top'],
        width = json['width'],
        height = json['height'],
        type = getTypeFromString(json['type']),
        commands = _getCommandsFromJson(json),
        font = Font.fromJson(json['font']),
        colors = _getColorsFromJson(json),
        images = _getImagesFromJson(json);

  static List<String> _getImagesFromJson(Map<String, dynamic> json) {
    var list = json['images'] as List;
    List<String> images = [];
    list.forEach((value) {
      images.add(value);
    });
    return images;
  }

  static List<Command> _getCommandsFromJson(Map<String, dynamic> json) {
    var list = json['commands'] as List;
    List<Command> commands = [];
    list.forEach((value) {
      commands.add(Command.fromJson(value));
    });
    return commands;
  }

  static List<Color> _getColorsFromJson(Map<String, dynamic> json) {
    var list = json['colors'] as List;
    List<Color> colors = <Color>[];
    list.forEach((value) {
      colors.add(Color(value));
    });
    return colors;
  }

  Map<String, dynamic> toJson() => {
        'version': 2,
        'design': design.toString(),
        'text': text,
        'left': left,
        'top': top,
        'width': width,
        'height': height,
        'type': type.toString(),
        'commands': commands,
        'font': font,
        'colors': _colorsToJson(colors),
        'images': images,
      };

  static List<int> _colorsToJson(List<Color> colors) {
    List<int> rv = <int>[];
    colors.forEach((Color element) {
      rv.add(element.value);
    });
    return rv;
  }

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
    List<Command> rv = <Command>[];
    if (model.command != null) {
      rv.add(model.command);
      if (model.commandSecondary != null) rv.add(model.commandSecondary);
    }
    return rv;
  }

  static Font _getFont(GicControl model) {
    Font rv = Font();
    if (model.fontColor == -1) {
      rv.color = Colors.white;
    } else {
      rv.color = _convertJavaColor(model.fontColor);
    }
    rv.size = model.fontSize.toDouble();
    if (model.fontName != null && model.fontName.isNotEmpty) {
      rv.family = model.fontName;
    }

    return rv;
  }

  static List<Color> _getColors(GicControl model) {
    List<Color> colors = <Color>[];
    if (model.primaryColor == -1) {
      colors.add(Colors.black);
    } else {
      colors.add(_convertJavaColor(model.primaryColor));
    }
    if (model.secondaryColor == -1) {
      colors.add(Colors.white);
    } else {
      colors.add(_convertJavaColor(model.secondaryColor));
    }

    return colors;
  }

  /// Convert legacy java color to Flutter Color
  static Color _convertJavaColor(int legacyColor) {
    return Color(legacyColor);
  }

  static List<String> _getImages(GicControl model) {
    List<String> images = <String>[];
    if (model.primaryImage != null && model.primaryImage.isNotEmpty) {
      images.add(model.primaryImage);
    } else if (model.primaryImageResource != -1) {
      images.add(_convertDrawableResource(
          model.primaryImageResource, model.viewType, true));
    } else {
      return images;
    } //mo primary, no secondary
    if (model.secondaryImage != null && model.secondaryImage.isNotEmpty) {
      images.add(model.secondaryImage);
    } else if (model.secondaryImageResource != -1) {
      images.add(_convertDrawableResource(
          model.secondaryImageResource, model.viewType, false));
    }

    return images;
  }

  static String _convertDrawableResource(
      int imageResource, int viewType, bool isPrimary) {
    if (viewType == 0 || viewType == 4) {
//its a button
      if (imageResource < ControlTypes.buttonDrawables.length) {
        return ControlTypes.buttonDrawables[imageResource];
      }
      if (isPrimary) {
        return ControlTypes.buttonDrawables[2];
      } else {
        return ControlTypes.buttonDrawables[3];
      } //dark blue
    } else {
      if (imageResource < ControlTypes.buttonDrawables.length) {
        return ControlTypes.toggleDrawables[imageResource];
      }
      if (isPrimary) {
        return ControlTypes.toggleDrawables[2];
      } else {
        return ControlTypes.toggleDrawables[3];
      }
    }
  }
}
