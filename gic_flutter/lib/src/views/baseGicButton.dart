import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';

abstract class BaseGicButton extends StatefulWidget {
  final ControlViewModel control;
  final TextStyle textStyle;

  BaseGicButton({Key key, @required this.control, @required this.textStyle}) : super(key: key);
}

abstract class BaseGicButtonState extends State<BaseGicButton> {
  final ControlViewModel control;
  final TextStyle textStyle;
  final BorderRadius buttonBorder = new BorderRadius.all(Radius.circular(5));

  BoxDecoration unpressed;
  BoxDecoration pressed;
  BoxDecoration active;

  BaseGicButtonState({@required this.control, @required this.textStyle}) {
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

  onTap();

  onTapUp();

}
