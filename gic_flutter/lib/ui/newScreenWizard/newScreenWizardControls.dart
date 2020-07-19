import 'package:gic_flutter/theme/dimensions.dart' as dim;
import 'package:flutter/material.dart';
import 'package:gic_flutter/ui/newScreenWizard/newScreenWizard.dart';

class NewScreenWizardControls extends StatelessWidget {
  final NewScreenWizardState _state;

  NewScreenWizardControls(this._state) {
    _state.screenNameTextController.addListener(() {    _state.viewModel.screenName = _state.screenNameTextController.text;});
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(dim.activityMargin),
        child: Column(
          children: <Widget>[
            TextField(), //screen name
            Text("Orientation"),
            Image(image: null,), //portrait vs landscape
            Text("Layout"),
            FlatButton(onPressed: () {  },
              child: Text("Increase Horizontal"),),
            FlatButton(onPressed: () {  },
              child: Text("Reduce Horizontal"),),
            FlatButton(onPressed: () {  },
              child: Text("Increase Vertical"),),
            FlatButton(onPressed: () {  },
              child: Text("Reduce Vertical"),),
            Text("Button Design"),
            FlatButton(onPressed: () {  },
              child: Text("Normal Image"),),
            FlatButton(onPressed: () {  },
              child: Text("Pressed Image"),),
            Text("Switch Design"),
            FlatButton(onPressed: () {  },
              child: Text("Normal Image"),),
            FlatButton(onPressed: () {  },
              child: Text("Pressed Image"),),
          ],
        ),
      ),
    );

  }

}
