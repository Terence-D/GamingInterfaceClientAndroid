// this widget handles setting if we are portrait or landscape mode
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gic_flutter/src/backend/models/intl/intlNewScreenWizard.dart';

import 'newScreenWizard.dart';
import 'package:gic_flutter/src/theme/dimensions.dart' as dim;

class OrientationWidget extends StatefulWidget {
  final NewScreenWizardState state;

  const OrientationWidget(this.state, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => OrientationState();
}

class OrientationState extends State<OrientationWidget> {
  Icon icon;
  String primaryText;
  String secondaryText;

  @override
  void initState() {
    _setButton();
    primaryText = widget.state.translation.text(NewScreenWizardText.width);
    secondaryText = widget.state.translation.text(NewScreenWizardText.height);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _buildDimensions();
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            widget.state.translation.text(NewScreenWizardText.orientation),
            style: Theme.of(context).textTheme.headline5,
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                    onPressed: () {
                      _updateOrientation();
                    },
                    child: icon),
                Flexible(
                    child: Padding(
                  padding: EdgeInsets.only(
                      left: dim.activityMargin,
                      right: dim.activityMargin,
                      bottom: dim.activityMargin),
                  child: Column(
                    children: [
                      TextField(
                        controller:
                            widget.state.screenPrimarySizeTextController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          LimitRangeTextInputFormatter(1, 4000)
                        ],
                      ),
                      Text(primaryText)
                    ],
                  ),
                )),
                Text(
                  " X ",
                  style: Theme.of(context).textTheme.headline5,
                ),
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: dim.activityMargin,
                        right: dim.activityMargin,
                        bottom: dim.activityMargin),
                    child: Column(
                      children: [
                        TextField(
                          controller:
                              widget.state.screenSecondarySizeTextController,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                            LimitRangeTextInputFormatter(1, 4000)
                          ],
                        ),
                        Text(secondaryText)
                      ],
                    ),
                  ),
                ),
              ])
        ],
      ),
    );
  }

  void _updateOrientation() {
    setState(() {
      widget.state.viewModel.isLandscape = !widget.state.viewModel.isLandscape;
      _setButton();
      _buildDimensions();
    });
  }

  void _setButton() {
    icon = Icon(Icons.stay_current_portrait);
    if (widget.state.viewModel.isLandscape) {
      icon = Icon(Icons.stay_current_landscape);
    }
  }

  void _buildDimensions() {
    if (MediaQuery.of(context).orientation == Orientation.portrait &&
        widget.state.viewModel.isLandscape) {
      widget.state.screenPrimarySizeTextController.text =
          (MediaQuery.of(context).size.height *
                  MediaQuery.of(context).devicePixelRatio)
              .floor()
              .toString();
      widget.state.screenSecondarySizeTextController.text =
          (MediaQuery.of(context).size.width *
                  MediaQuery.of(context).devicePixelRatio)
              .floor()
              .toString();
    } else if (MediaQuery.of(context).orientation == Orientation.portrait) {
      widget.state.screenSecondarySizeTextController.text =
          (MediaQuery.of(context).size.height *
                  MediaQuery.of(context).devicePixelRatio)
              .floor()
              .toString();
      widget.state.screenPrimarySizeTextController.text =
          (MediaQuery.of(context).size.width *
                  MediaQuery.of(context).devicePixelRatio)
              .floor()
              .toString();
    } else if (MediaQuery.of(context).orientation == Orientation.landscape &&
        !widget.state.viewModel.isLandscape) {
      widget.state.screenPrimarySizeTextController.text =
          (MediaQuery.of(context).size.height *
                  MediaQuery.of(context).devicePixelRatio)
              .floor()
              .toString();
      widget.state.screenSecondarySizeTextController.text =
          (MediaQuery.of(context).size.width *
                  MediaQuery.of(context).devicePixelRatio)
              .floor()
              .toString();
    } else {
      widget.state.screenSecondarySizeTextController.text =
          (MediaQuery.of(context).size.height *
                  MediaQuery.of(context).devicePixelRatio)
              .floor()
              .toString();
      widget.state.screenPrimarySizeTextController.text =
          (MediaQuery.of(context).size.width *
                  MediaQuery.of(context).devicePixelRatio)
              .floor()
              .toString();
    }
  }
}

class LimitRangeTextInputFormatter extends TextInputFormatter {
  LimitRangeTextInputFormatter(this.min, this.max) : assert(min < max);

  final int min;
  final int max;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var value = int.parse(newValue.text);
    if (value < min) {
      return TextEditingValue(text: min.toString());
    } else if (value > max) {
      return TextEditingValue(text: max.toString());
    }
    return newValue;
  }
}
