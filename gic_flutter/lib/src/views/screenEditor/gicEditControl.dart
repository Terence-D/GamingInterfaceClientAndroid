import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/font.dart';

typedef void SelectedWidgetCallback(int id);

class GicEditControl extends StatefulWidget {

  final SelectedWidgetCallback onSelected;

  final ControlViewModel control;
  final TextStyle textStyle;
  final int id;

  GicEditControl({Key key, @required this.control, @required this.id, @required this.textStyle, @required this.onSelected})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return GicEditControlState(control: control, id: id, textStyle: textStyle, onSelected: onSelected);
  }
}

class GicEditControlState extends State<GicEditControl> {
  final SelectedWidgetCallback onSelected;

  final ControlViewModel control;
  final TextStyle textStyle;
  final BorderRadius buttonBorder = new BorderRadius.all(Radius.circular(5));
  final int id;

  GicEditControlState({@required this.control, @required this.id, @required this.textStyle, @required this.onSelected});

  Color color;

  @override
  void initState() {
    color = Colors.red;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: control.top,
      left: control.left,
      child: GestureDetector(
          onPanUpdate: (tapInfo) {
            setState(() {
              control.left += tapInfo.delta.dx;
              control.top += tapInfo.delta.dy;
            });
          },
          child: Stack(children: <Widget>[
            _dynamicControl(),
            FlatButton(
                onPressed: _onTap,
                child: Text("", style: _getTextStyle(control.font)),
                minWidth: control.width,
                height: control.height)
          ])),
    );
  }

  Widget _dynamicControl() {
    switch (control.type) {
      case ControlViewModelType.Text:
        return _gicText();
      case ControlViewModelType.Image:
        return _gicImage();
      default:
        return _gicButton();
    }
  }

  Widget _gicImage() {
    return Image.file(
      File(control.images[0]),
      width: control.width,
      height: control.height,
    );
  }

  Widget _gicText() {
    return Text(control.text, style: _getTextStyle(control.font));
  }

  TextStyle _getTextStyle(Font font) {
    return TextStyle(
        color: font.color, fontFamily: font.family, fontSize: font.size);
  }

  Container _gicButton() {
    return Container(
      width: control.width,
      height: control.height,
      decoration: _buildButton(),
      child: Center(
          child: Text(control.text,
              textAlign: TextAlign.center, style: textStyle)),
    );
  }

  BoxDecoration _buildButton() {
    int imageIndex = 0;
    Alignment begin = Alignment.bottomCenter;
    Alignment end = Alignment.topCenter;

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
              image: new AssetImage(
                  "assets/images/controls/${control.images[imageIndex]}.png"),
              fit: BoxFit.cover));
    }
  }

  _onTap() {
    setState(() {
      onSelected(id);
    });
  }
}
