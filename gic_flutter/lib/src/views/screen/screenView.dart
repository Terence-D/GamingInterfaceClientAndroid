import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';
import 'package:gic_flutter/src/backend/services/networkService.dart';
import 'package:gic_flutter/src/views/screen/screenVM.dart';
import 'package:keep_screen_on/keep_screen_on.dart';

import 'gicControl.dart';

/// Wrapper for stateful functionality to provide onInit calls in our stateless
/// screenview widget
class ScreenViewStatefulWrapper extends StatefulWidget {
  final ScreenVM viewModel;

  const ScreenViewStatefulWrapper({@required this.viewModel});
  @override
  _StatefulWrapperState createState() => _StatefulWrapperState(this.viewModel);
}

class _StatefulWrapperState extends State<ScreenViewStatefulWrapper> {
  final ScreenVM viewModel;

  _StatefulWrapperState(this.viewModel);

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenView(screenVM: viewModel);
  }

  @override
  void dispose() {
    super.dispose();
    KeepScreenOn.turnOff();
  }
}

class ScreenView extends StatelessWidget {
  final List<Widget> widgets = [];
  final ScreenVM screenVM;
  final AudioCache player = new AudioCache();
  final alarmAudioPath = "audio/flick.wav";

  ScreenView({Key key, @required this.screenVM});

  @override
  Widget build(BuildContext context) {
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    if (screenVM.screen != null) {
      screenVM.screen.controls.forEach((element) {
        widgets.add(_buildGicControl(element, pixelRatio));
      });
    }
    if (screenVM.keepScreenOn) {
      KeepScreenOn.turnOn();
    }

    if (screenVM.screen.backgroundPath != null &&
        screenVM.screen.backgroundPath.isNotEmpty) {
      imageCache.clear();
      imageCache.clearLiveImages();

      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(File(screenVM.screen.backgroundPath)),
              fit: BoxFit.fill,
            ),
          ),
          child: Stack(children: widgets),
        ),
      );
    } else {
      return Scaffold(
        body: Container(
          color: screenVM.screen.backgroundColor,
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
            networkModel: screenVM.networkModel,
            screenView: this,
            pixelRatio: pixelRatio));
  }

  Future<void> sendCommand(ControlViewModel control, String commandUrl,
      int commandIndex, bool provideFeedback) async {
    if (provideFeedback) {
      playSound();
      vibration();
    }
    if (screenVM.networkModel != null) {
      NetworkResponse response = await NetworkService.sendCommand(
          screenVM.networkModel, commandUrl, control.commands[commandIndex]);
      if (response == NetworkResponse.Error) {
        await Fluttertoast.showToast(
          msg: "Error Connecting to Server",
          toastLength: Toast.LENGTH_SHORT,
        );
      } else if (response == NetworkResponse.Unauthorized) {
        await Fluttertoast.showToast(
          msg: "Unauthorized, check that the passwords match",
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    }
  }

  void playSound() {
    if (screenVM.playSound) {
      player.play(alarmAudioPath);
    }
  }

  void vibration() {
    if (screenVM.vibration) {
      HapticFeedback.lightImpact().ignore();
    }
  }
}
