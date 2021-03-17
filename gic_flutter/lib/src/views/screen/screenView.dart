import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/networkModel.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/screenViewModel.dart';

import 'gicButton.dart';

class ScreenView extends StatelessWidget {
  final ScreenViewModel screen;
  final List<Widget> widgets = new List<Widget>();
  final NetworkModel networkModel;

  ScreenView({Key key, @required this.screen, @required this.networkModel});

  @override
  Widget build(BuildContext context) {
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    if (screen != null)
      screen.controls.forEach((element) {
        widgets.add(_buildGicControl(element, pixelRatio));
      });

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

  Widget _buildGicControl(ControlViewModel element, double pixelRatio) {
    return Positioned(
        left: element.left / pixelRatio,
        top: element.top / pixelRatio,
        child: GicControl(
            control: element,
            networkModel: networkModel,
            pixelRatio: pixelRatio));
  }

}
