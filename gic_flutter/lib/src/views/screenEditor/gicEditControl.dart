import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/screen/command.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';
import 'package:gic_flutter/src/views/baseGicButton.dart';
import 'package:gic_flutter/src/views/screenEditor/screenEditor.dart';

class GicEditControl extends BaseGicButton {
  final ControlViewModel control;
  final TextStyle textStyle;
  final ScreenEditorState editor;

  GicEditControl({Key key, @required this.control, @required this.textStyle, @required this.editor}) : super(key: key, control: control, textStyle: textStyle);

  @override
  State<StatefulWidget> createState() {
    return GicEditControlState(control: control, textStyle: textStyle, editor: editor);
  }
}

class GicEditControlState extends State<GicEditControl> {
  final ControlViewModel control;
  final TextStyle textStyle;
  final BorderRadius buttonBorder = new BorderRadius.all(Radius.circular(5));
  final ScreenEditorState editor;

  BoxDecoration unpressed;
  BoxDecoration pressed;
  BoxDecoration active;

  GicEditControlState({@required this.control, @required this.textStyle, @required this.editor}) {
    unpressed = _buildDesign(false);
    pressed = _buildDesign(true);
    active = unpressed;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        // onLongPressMoveUpdate: (updateDetails) {
        //   print ("originally " + control.left.toString());
        //   control.left = control.left + updateDetails.offsetFromOrigin.dx;
        //   print ("now  " + control.left.toString());
        //   active = _buildDesign(false);
        //   editor.moveControl();
        // },
        // onTapDown: (TapDownDetails details) => onTap(),
        // onTapUp: (TapUpDetails details) => onTapUp(),

        child: Container(
          width: control.width,
          height: control.height,
          decoration: active,
          child: Center(child: Text(control.text, textAlign: TextAlign.center, style: textStyle)),
        ));
  }

  // onTap() {
  //   setState(() {
  //     switch (control.type) {
  //       case ControlViewModelType.Toggle:
  //         _toggleTap(Command.KEY_DOWN);
  //         break;
  //       case ControlViewModelType.QuickButton:
  //         _buttonTap("toggle", Command.KEY_DOWN, pressed);
  //         break;
  //       case ControlViewModelType.Button:
  //         _buttonTap("key", Command.KEY_DOWN, pressed);
  //         break;
  //       case ControlViewModelType.Text:
  //       case ControlViewModelType.Image:
  //         break;
  //     }
  //   });
  // }
  //
  // onTapUp() {
  //   setState(() {
  //     switch (control.type) {
  //       case ControlViewModelType.Toggle:
  //         _toggleTap(Command.KEY_UP);
  //         break;
  //       case ControlViewModelType.QuickButton:
  //         _buttonTap("toggle", Command.KEY_UP, unpressed);
  //         break;
  //       case ControlViewModelType.Button:
  //         _buttonTap("key", Command.KEY_UP, unpressed);
  //         break;
  //       case ControlViewModelType.Text:
  //       case ControlViewModelType.Image:
  //         break;
  //     }
  //   });
  // }

  void _toggleTap(int activatorType) {
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
  }

  void _buttonTap(String commandUrl, int activatorType, BoxDecoration status) {
    control.commands[0].activatorType = activatorType;
    active = status;
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
          image: new DecorationImage(
            image: new AssetImage("assets/images/controls/${control.images[imageIndex]}.png"),
            fit: BoxFit.cover)
      );
    }
  }
}
