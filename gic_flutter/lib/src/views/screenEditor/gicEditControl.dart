import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/font.dart';

typedef void SelectedWidgetCallback(int selectedControlIndex);
typedef void DragControl(
    double newLeft, double newTop, int selectedControlIndex);

class GicEditControl extends StatefulWidget {
  final SelectedWidgetCallback onSelected;
  final DragControl onDrag;

  final ControlViewModel control;
  final int controlIndex;
  final double pixelRatio;

  GicEditControl(
      {Key key,
      @required this.control,
      @required this.controlIndex,
      @required this.onSelected,
      @required this.onDrag,
      @required this.pixelRatio})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return GicEditControlState(
        control: control,
        controlIndex: controlIndex,
        onSelected: onSelected,
        onDrag: onDrag,
    pixelRatio: pixelRatio);
  }
}

class GicEditControlState extends State<GicEditControl> {
  final SelectedWidgetCallback onSelected;
  final DragControl onDrag;

  final ControlViewModel control;
  final BorderRadius buttonBorder = new BorderRadius.all(Radius.circular(5));
  final int controlIndex;
  final double pixelRatio;

  GicEditControlState(
      {@required this.control,
      @required this.controlIndex,
      @required this.onSelected,
      @required this.onDrag,
      @required this.pixelRatio});

  Color color;

  @override
  void initState() {
    color = Colors.red;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: control.top / pixelRatio,
      left: control.left / pixelRatio,
      child: GestureDetector(
          onPanUpdate: (tapInfo) {
            setState(() {
              control.left += tapInfo.delta.dx;
              control.top += tapInfo.delta.dy;
              onDrag(control.left / pixelRatio, control.top / pixelRatio, controlIndex);
            });
          },
          child: Stack(children: <Widget>[
            _dynamicControl(),
            FlatButton(
                onPressed: _onTap,
                child: Text("", style: _getTextStyle(control.font)),
                minWidth: control.width / pixelRatio,
                height: control.height / pixelRatio)
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
      width: control.width / pixelRatio,
      height: control.height / pixelRatio,
    );
  }

  Widget _gicText() {
    return Text(control.text, style: _getTextStyle(control.font));
  }

  TextStyle _getTextStyle(Font font) {
    return TextStyle(
        color: font.color, fontFamily: font.family, fontSize: font.size / pixelRatio);
  }

  Container _gicButton() {
    return Container(
      width: control.width / pixelRatio,
      height: control.height / pixelRatio,
      decoration: _buildButton(),
      child: Center(
          child: Text(control.text,
              textAlign: TextAlign.center, style: _getTextStyle(control.font))),
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
      onSelected(controlIndex);
    });
  }
}
