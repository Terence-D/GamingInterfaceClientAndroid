import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/networkModel.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';
import 'package:gic_flutter/src/backend/services/networkService.dart';

class GicButton extends StatefulWidget {
  final ControlViewModel control;
  final TextStyle textStyle;
  final NetworkModel networkModel;

  GicButton({Key key, @required this.control, @required this.textStyle, @required this.networkModel}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return GicButtonState(control: control, textStyle: textStyle, networkModel: networkModel);
  }
}

class GicButtonState extends State<GicButton> {
  final ControlViewModel control;
  final TextStyle textStyle;
  final BorderRadius buttonBorder = new BorderRadius.all(Radius.circular(5));
  final NetworkModel networkModel;

  BoxDecoration unpressed;
  BoxDecoration pressed;
  BoxDecoration active;

  GicButtonState({@required this.control, @required this.textStyle, @required this.networkModel}) {
    unpressed = _buildDesign(false);
    pressed = _buildDesign(true);
    active = unpressed;
  }

  onTap() {
    setState(() {
      switch (control.type) {
        case ControlViewModelType.Toggle:
          sendCommand("toggle");
          if (active == pressed)
            active = unpressed;
          else
            active = pressed;
          break;
        case ControlViewModelType.QuickButton:
        case ControlViewModelType.Button:
          sendCommand("key");
          active = pressed;
      }
    });
  }

  onTapUp() {
    if (control.type != ControlViewModelType.Toggle)
      setState(() {
        active = unpressed;
      });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTapDown: (TapDownDetails details) => onTap(),
        onTapUp: (TapUpDetails details) => onTapUp(),
        child: Container(
          width: control.width,
          height: control.height,
          decoration: active,
          child: Center(
              child: Text(control.text,
                textAlign: TextAlign.center,
                style: textStyle
              )),
        ));
  }

  BoxDecoration _buildDesign(bool isPressed) {
    int imageIndex = 0;
    Alignment begin = Alignment.bottomCenter;
    Alignment end = Alignment.topCenter;

    if (isPressed) {
      imageIndex++;
      begin = Alignment.topCenter;
      end = Alignment.bottomCenter;
    }

    if (control.design == ControlDesignType.UpDownGradient) {
      return BoxDecoration(
          borderRadius: buttonBorder,
          gradient: LinearGradient(
            colors: control.colors,
            begin: begin,
            end: end,
          ));
    } else {
      return BoxDecoration(
          borderRadius: buttonBorder,
          image: DecorationImage(
              image: AssetImage("assets/images/controls/${control.images[imageIndex]}.png"),
              fit: BoxFit.cover));
    }
  }

  Future<void> sendCommand(String command) async {
    NetworkService.sendCommand(networkModel, command, control.commands[0]);
  }
}
