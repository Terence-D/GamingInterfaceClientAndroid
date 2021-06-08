import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/screen/command.dart';
import 'package:gic_flutter/src/backend/models/screen/controlTypes.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/font.dart';

abstract class BaseGicControl extends StatefulWidget {
  final ControlViewModel control;
  final double pixelRatio;

  BaseGicControl({Key key, @required this.control, @required this.pixelRatio})
      : super(key: key);
}

abstract class BaseGicControlState extends State<BaseGicControl> {
  final ControlViewModel control;
  final double pixelRatio;
  final BorderRadius buttonBorder = BorderRadius.all(Radius.circular(5));

  BoxDecoration unpressed;
  BoxDecoration pressed;
  BoxDecoration active;

  BaseGicControlState({@required this.control, @required this.pixelRatio});

  sendCommand(String commandUrl, int commandIndex);

  GestureDetector buildControl();

  @override
  Widget build(BuildContext context) {
    bool isPressed = false;
    if (active == pressed) {
      isPressed = true;
    }
    if (control.type == ControlViewModelType.Button ||
        control.type == ControlViewModelType.QuickButton ||
        control.type == ControlViewModelType.Toggle ) {
      unpressed = _buildButtonDesign(false);
      pressed = _buildButtonDesign(true);
      if (isPressed) {
        active = pressed;
      } else {
        active = unpressed;
      }
    }
    return buildControl();
  }

  Widget buildControlContainer() {
    Widget toReturn;
    switch (control.type) {
      case ControlViewModelType.Text:
        toReturn = _gicText();
        break;
      case ControlViewModelType.Image:
        toReturn = _gicImage();
        break;
      default:
        toReturn = _gicButton();
        break;
    }
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return toReturn;
    });
  }

  onTap() {
    setState(() {
      switch (control.type) {
        case ControlViewModelType.Toggle:
          _toggleTap(Command.KEY_DOWN);
          break;
        case ControlViewModelType.QuickButton:
          _buttonTap("toggle", Command.KEY_DOWN, pressed);
          break;
        case ControlViewModelType.Button:
          _buttonTap("key", Command.KEY_DOWN, pressed);
          break;
        case ControlViewModelType.Text:
        case ControlViewModelType.Image:
          sendCommand(null, -1);
          break;
      }
    });
  }

  onTapUp() {
    setState(() {
      switch (control.type) {
        case ControlViewModelType.Toggle:
          _toggleTap(Command.KEY_UP);
          break;
        case ControlViewModelType.QuickButton:
          _buttonTap("toggle", Command.KEY_UP, unpressed);
          break;
        case ControlViewModelType.Button:
          _buttonTap("key", Command.KEY_UP, unpressed);
          break;
        case ControlViewModelType.Text:
        case ControlViewModelType.Image:
          sendCommand(null, -1);
          break;
      }
    });
  }

  TextStyle getTextStyle(Font font, double pixelRatio) {
    return TextStyle(
        color: font.color,
        fontFamily: font.family,
        fontSize: font.size / pixelRatio);
  }

  void _toggleTap(int activatorType) {
    String commandType = "toggle";
    int commandIndex = 0;
    if (activatorType == Command.KEY_DOWN) {
      if (active == unpressed) {
        commandIndex = 0;
      } else {
        commandIndex = 1;
      }
    } else {
      if (active == unpressed) {
        commandIndex = 0;
        active = pressed;
      } else {
        commandIndex = 1;
        active = unpressed;
      }
    }
    control.commands[commandIndex].activatorType = activatorType;
    sendCommand(commandType, 0);
  }

  void _buttonTap(String commandUrl, int activatorType, BoxDecoration status) {
    sendCommand(commandUrl, 0);
    control.commands[0].activatorType = activatorType;
    active = status;
  }

  Widget _gicButton() {
    return Container(
      width: control.width / pixelRatio,
      height: control.height / pixelRatio,
      decoration: active,
      child: Center(
          child: Text(control.text,
              textAlign: TextAlign.center,
              style: getTextStyle(control.font, pixelRatio))),
    );
  }

  Widget _gicImage() {
    if (control.images.isEmpty) {
      return Container(
          width: control.width / pixelRatio,
          height: control.height / pixelRatio,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/icons/app_icon.png"),
                  fit: BoxFit.cover)));
    } else {
      return Image.file(
        File(control.images[0]),
        width: control.width / pixelRatio,
        height: control.height / pixelRatio,
      );
    }
  }

  Widget _gicText() {
    return Container(
        width: control.width / pixelRatio,
        child:
            Text(control.text, style: getTextStyle(control.font, pixelRatio)));
  }

  BoxDecoration _buildButtonDesign(bool isPressed) {
    int imageIndex = 0;
    Alignment begin = Alignment.bottomCenter;
    Alignment end = Alignment.topCenter;

    if (isPressed) {
      imageIndex++;
      begin = Alignment.topCenter;
      end = Alignment.bottomCenter;
    }

    if (control.design == ControlDesignType.UpDownGradient) {
      List<Color> colors = [control.colors[0], control.colors[1]];
      LinearGradient linearGradient  = LinearGradient(
        colors: colors,
        begin: begin,
        end: end,
      );
      return BoxDecoration(borderRadius: buttonBorder, gradient: linearGradient);
    } else {
      ImageProvider imageProvider;
      DecorationImage decorationImage;
      if (File(control.images[imageIndex]).isAbsolute) {
        imageProvider = FileImage(File(control.images[imageIndex]));
      } else {
        imageProvider = AssetImage(
            "assets/images/controls/${control.images[imageIndex]}.png");
      }
      decorationImage =DecorationImage(
          image: imageProvider,
          fit: BoxFit.fill);
      return BoxDecoration(
          borderRadius: buttonBorder,
          image: decorationImage);
    }
  }
}
