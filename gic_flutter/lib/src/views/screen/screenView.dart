import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gic_flutter/src/backend/models/networkModel.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/screenViewModel.dart';

import 'gicControl.dart';


/// Wrapper for stateful functionality to provide onInit calls in our stateless
/// screenview widget
class ScreenViewStatefulWrapper extends StatefulWidget {
  final ScreenViewModel screen;
  final NetworkModel networkModel;
  const ScreenViewStatefulWrapper({@required this.screen, @required this.networkModel});
  @override
  _StatefulWrapperState createState() => _StatefulWrapperState(this.screen, this.networkModel);
}
class _StatefulWrapperState extends State<ScreenViewStatefulWrapper> {
  final ScreenViewModel screen;
  final NetworkModel networkModel;

  _StatefulWrapperState(this.screen, this.networkModel);

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }
  @override
  Widget build(BuildContext context) {
    return ScreenView(screen: screen, networkModel: networkModel);
  }
}


class ScreenView extends StatelessWidget {
  final List<Widget> widgets = [];
  final ScreenViewModel screen;
  final NetworkModel networkModel;

  ScreenView({Key key, @required this.screen, @required this.networkModel});

  @override
  Widget build(BuildContext context) {
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    if (screen != null) {
      screen.controls.forEach((element) {
        widgets.add(_buildGicControl(element, pixelRatio));
      });
    }

    if (screen.backgroundPath != null && screen.backgroundPath.isNotEmpty) {
      imageCache.clear();
      imageCache.clearLiveImages();

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
      return Scaffold(
        body: Container(
          color: screen.backgroundColor,
          child: Stack(children: widgets),
        ),
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
