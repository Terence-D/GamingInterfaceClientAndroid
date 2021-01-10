import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gic_flutter/src/backend/models/networkModel.dart';
import 'package:gic_flutter/src/backend/models/screen/command.dart';
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTapDown: (TapDownDetails details) => onTap(),
        onTapUp: (TapUpDetails details) => onTapUp(),
        child: Container(
          width: control.width,
          height: control.height,
          decoration: active,
          child: Center(child: Text(control.text, textAlign: TextAlign.center, style: textStyle)),
        ));
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
          break;
      }
    });
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
    control.commands[0].activatorType = activatorType;
    active = status;
    sendCommand(commandUrl, 0);
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
      if (control.images[imageIndex].contains("9.png")) {
        return BoxDecoration(
            borderRadius: buttonBorder,
            image: new DecorationImage(
                image: new AssetImage("assets/images/controls/${control.images[imageIndex]}.png"),
                centerSlice: new Rect.fromLTRB(5, 3, 147, 49),
                fit: BoxFit.cover)
        );
      }
      return BoxDecoration(
          borderRadius: buttonBorder,
          image: new DecorationImage(
            image: new AssetImage("assets/images/controls/${control.images[imageIndex]}.png"),
            centerSlice: new Rect.fromLTRB(5, 3, 147, 49),
            fit: BoxFit.cover)
      );
    }
  }

  Future<void> sendCommand(String commandUrl, int commandIndex) async {
    NetworkResponse response = await NetworkService.sendCommand(networkModel, commandUrl, control.commands[commandIndex]);
    if (response == NetworkResponse.Error)
      Fluttertoast.showToast(
        msg: "error",
        toastLength: Toast.LENGTH_SHORT,
      );
  }
}
