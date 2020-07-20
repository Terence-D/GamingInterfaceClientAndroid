// this widget handles setting if we are portrait or landscape mode
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gic_flutter/model/intl/intlNewScreenWizard.dart';

import 'newScreenWizard.dart';

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
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            widget.state.translation.text(NewScreenWizardText.orientation),
            style: Theme.of(context).textTheme.headline5,
          ),
          RaisedButton(
              onPressed: () {
               _updateOrientation();
              },
              child: icon
          ),
        ],
      ),
    );
  }

  void _updateOrientation() {
    setState(() {
      widget.state.viewModel.isLandscape = !widget.state.viewModel.isLandscape;
      _setButton();
    });
  }

  void _setButton() {
    icon = new Icon(Icons.screen_lock_portrait);
    if (widget.state.viewModel.isLandscape)
      icon = new Icon(Icons.screen_lock_landscape);
  }
}

