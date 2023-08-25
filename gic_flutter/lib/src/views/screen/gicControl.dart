import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/networkModel.dart';
import 'package:gic_flutter/src/views/baseGicControl.dart';
import 'package:gic_flutter/src/views/screen/screenView.dart';

class GicControl extends BaseGicControl {
  final NetworkModel? networkModel;
  final BoxConstraints? constraints;
  final ScreenView? screenView;

  GicControl(
      {
        Key? key,
        required control,
        required this.networkModel,
        required pixelRatio,
        this.screenView,
        this.constraints
      })
      : super(
            key: key,
            control: control,
            pixelRatio: pixelRatio,
            constraints: constraints);

  @override
  State<StatefulWidget> createState() {
    return GicButtonState(
        control: control,
        networkModel: networkModel,
        pixelRatio: pixelRatio,
        constraints: constraints!);
  }
}

class GicButtonState extends BaseGicControlState {
  final NetworkModel? networkModel;
  final BoxConstraints constraints;

  GicButtonState(
      {required control,
      required this.networkModel,
      required pixelRatio,
      required this.constraints})
      : super(control: control, pixelRatio: pixelRatio);

  void sendCommand(String? commandUrl, int commandIndex, bool provideFeedback) {
    if ((widget as GicControl).screenView != null)
      (widget as GicControl).screenView!.sendCommand(control, commandUrl!, context, commandIndex, provideFeedback).ignore();
  }

  GestureDetector buildControl() {
    return GestureDetector(
        onTapDown: (TapDownDetails details) => onTap(),
        onTapUp: (TapUpDetails details) => onTapUp(),
        child: buildControlContainer(constraints));
  }
}
