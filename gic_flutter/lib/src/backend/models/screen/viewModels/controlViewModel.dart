import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/screen/gicControl.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/font.dart';

import '../command.dart';

enum ControlViewModelType {
    Button,
    Text,
    Image,
    Switch,
    QuickButton
}

enum SwitchPosition {
    OffReadyForMouseDown,
    OffReadyForMouseUp,
    OnReadyForMouseDown,
    OnReadyForMouseUp,
}
class ControlViewModel {
    ControlViewModelType type = ControlViewModelType.Button;
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

    factory ControlViewModel.fromModel(GicControl model) {
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
                return ControlViewModelType.Switch;
            default:
                return ControlViewModelType.QuickButton;
        }
    }

    static List<Command> _getCommands(GicControl model) {
        List<Command> rv = new List<Command>();
        if (model.command != null) {
            rv.add(model.command);
            if (model.commandSecondary != null)
                rv.add(model.commandSecondary);
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
        if (model.fontName != null && model.fontName.isEmpty) {
            rv.family = model.fontName;
        }

        return rv;
    }

    static List<Color> _getColors(GicControl model) {
        List<Color> colors = new List<Color>();
        if (model.primaryColor == -1)
            colors.add (Colors.black);
        else
            colors.add (_convertJavaColor(model.primaryColor));
        if (model.secondaryColor == -1)
            colors.add (Colors.white);
        else
            colors.add (_convertJavaColor(model.secondaryColor));

        return colors;
    }

    /// Convert legacy java color to Flutter Color
    static Color _convertJavaColor (int legacyColor) {
        int r = (legacyColor >> 16) & 0xFF;
        int g = (legacyColor >> 8) & 0xFF;
        int b = legacyColor & 0xFF;

        return Color.fromARGB(1, r, g, b);
    }

    static List<String> _getImages(GicControl model) {
        List<String> images = new List<String>();
        if (model.primaryImage.isNotEmpty)
            images.add(model.primaryImage);
        if (model.secondaryImage.isNotEmpty)
            images.add(model.secondaryImage);

        return images;
    }
}