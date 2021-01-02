// this widget handles setting if we are portrait or landscape mode
import
'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/intl/intlNewScreenWizard.dart';

import 'newScreenWizard.dart';

class ControlDesignWidget extends StatefulWidget {
  final NewScreenWizardState state;

  const ControlDesignWidget ( this.state, {Key key  }): super(key: key);

  @override
  State<StatefulWidget> createState() => new ControlDesignState();

}

class ControlDesignState extends State<ControlDesignWidget> {
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
            widget.state.translation.text(NewScreenWizardText.buttonDesign),
            style: Theme.of(context).textTheme.headline5,
          ),
          Container(
            height: 50.0,
            child: RaisedButton(
              onPressed: () {},
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
              padding: EdgeInsets.all(0.0),
              child: Ink(
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xff374ABE), Color(0xff64B6FF)],
                      begin: Alignment.topRight,
                    ),
                ),
                child: Container(
                  constraints: BoxConstraints(maxWidth: 300.0, minHeight: 50.0),
                  alignment: Alignment.center,
                  child: Text(
                    "Login",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateControlDesign() {
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

