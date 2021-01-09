import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/networkModel.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/font.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/screenViewModel.dart';

import 'gicButton.dart';

class ScreenView extends StatelessWidget {
  final ScreenViewModel screen;
  final List<Widget> widgets = new List<Widget>();
  final NetworkModel networkModel;

  ScreenView({Key key, @required this.screen, @required this.networkModel}) : super(key: key) {
    if (screen != null)
      screen.controls.forEach((element) {
        widgets.add(_buildGicControl(element));
      });
  }

  @override
  Widget build(BuildContext context) {
    return _setBackground();
  }

  Widget _setBackground() {
    if (screen.backgroundPath != null && screen.backgroundPath.isNotEmpty) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(File(screen.backgroundPath)),
              fit: BoxFit.fill,
            ),
          ),
          child: Stack(children: widgets),
        ),
      );
    } else {
      return Material(
        color: screen.backgroundColor,
        child: Stack(children: widgets),
      );
    }
  }

  Widget _buildGicControl(ControlViewModel element) {
    return Positioned(
      left: element.left,
      top: element.top,
      child: _dynamicControl(element),
    );
  }

  Widget _dynamicControl(ControlViewModel element) {
    switch (element.type) {
      case ControlViewModelType.Text:
        return _gicText(element);
      case ControlViewModelType.Image:
        return _gicImage(element);
      default:
        return GicButton(control: element, textStyle: _getTextStyle(element.font), networkModel: networkModel);
    }
  }

  Widget _gicImage(ControlViewModel element) {
    return Image.file(File(element.images[0]),
      width: element.width,
      height: element.height,
    );
  }

  Widget _gicText(ControlViewModel element) {
    return new Container(width: element.width, child: Text(element.text, style: _getTextStyle(element.font)));
  }

  TextStyle _getTextStyle(Font font) {
    return TextStyle(color: font.color, fontFamily: font.family, fontSize: font.size);
  }
}
