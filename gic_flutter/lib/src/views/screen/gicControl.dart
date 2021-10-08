import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gic_flutter/src/backend/models/networkModel.dart';
import 'package:gic_flutter/src/backend/services/networkService.dart';
import 'package:gic_flutter/src/views/baseGicControl.dart';

class GicControl extends BaseGicControl {
  final NetworkModel networkModel;
  final BoxConstraints constraints;

  GicControl(
      {Key key,
      @required control,
      @required this.networkModel,
      @required pixelRatio,
      @required this.constraints})
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
        constraints: constraints);
  }
}

class GicButtonState extends BaseGicControlState {
  final NetworkModel networkModel;
  final BoxConstraints constraints;

  GicButtonState(
      {@required control,
      @required this.networkModel,
      @required pixelRatio,
      @required this.constraints})
      : super(control: control, pixelRatio: pixelRatio);

  Future<void> sendCommand(String commandUrl, int commandIndex) async {
    NetworkResponse response = await NetworkService.sendCommand(
        networkModel, commandUrl, control.commands[commandIndex]);
    if (response == NetworkResponse.Error) {
      await Fluttertoast.showToast(
        msg: "error",
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  GestureDetector buildControl() {
    return GestureDetector(
        onTapDown: (TapDownDetails details) => onTap(),
        onTapUp: (TapUpDetails details) => onTapUp(),
        child: buildControlContainer(constraints));
  }
}
