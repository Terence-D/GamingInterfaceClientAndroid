// this widget handles setting if we are portrait or landscape mode
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gic_flutter/model/intl/intlNewScreenWizard.dart';

import 'newScreenWizard.dart';
import 'package:gic_flutter/theme/dimensions.dart' as dim;

class OrientationWidget extends StatefulWidget {
  final NewScreenWizardState state;

  const OrientationWidget ( this.state, {Key key  }): super(key: key);

  @override
  State<StatefulWidget> createState() => new OrientationState();

}

class OrientationState extends State<OrientationWidget> {
  Icon icon;

  @override
  void initState() {
    _setButton();
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
            children: <Widget> [
              RaisedButton(
                  onPressed: () {
                    _updateOrientation();
                  },
                  child: icon
              ),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(left: dim.activityMargin, right: dim.activityMargin, bottom: dim.activityMargin),
                  child: TextField(
                    controller: widget.state.screenWidthTextController,
                    keyboardType: TextInputType.number
                  ),
                )
              ),
              Text(" X ",
                style: Theme.of(context).textTheme.headline5,
              ),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(left: dim.activityMargin, right: dim.activityMargin, bottom: dim.activityMargin),
                  child: TextField(
                      controller: widget.state.screenHeightTextController,
                      keyboardType: TextInputType.number
                  ),
                ),
              ),
            ]
          )
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
    icon = new Icon(Icons.screen_lock_portrait);
    if (widget.state.viewModel.isLandscape)
      icon = new Icon(Icons.screen_lock_landscape);
  }

  void _buildDimensions() {
    if (MediaQuery.of(context).orientation == Orientation.portrait && widget.state.viewModel.isLandscape) {
      widget.state.screenWidthTextController.text = (MediaQuery.of(context).size.height * MediaQuery.of(context).devicePixelRatio).floor().toString();
      widget.state.screenHeightTextController.text = (MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio).floor().toString();
    } else if (MediaQuery.of(context).orientation == Orientation.portrait) {
      widget.state.screenHeightTextController.text = (MediaQuery.of(context).size.height * MediaQuery.of(context).devicePixelRatio).floor().toString();
      widget.state.screenWidthTextController.text = (MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio).floor().toString();
    } else if (MediaQuery.of(context).orientation == Orientation.landscape && !widget.state.viewModel.isLandscape) {
      widget.state.screenWidthTextController.text = (MediaQuery.of(context).size.height * MediaQuery.of(context).devicePixelRatio).floor().toString();
      widget.state.screenHeightTextController.text = (MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio).floor().toString();
    } else {
      widget.state.screenHeightTextController.text = (MediaQuery.of(context).size.height * MediaQuery.of(context).devicePixelRatio).floor().toString();
      widget.state.screenWidthTextController.text = (MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio).floor().toString();
    }
  }
}

