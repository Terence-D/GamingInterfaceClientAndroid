import 'package:flutter/material.dart';
import 'package:gic_flutter/model/intl/intlNewScreenWizard.dart';
import 'package:gic_flutter/theme/dimensions.dart' as dim;
import 'newScreenWizard.dart';

class NewScreenWizardGeneral extends StatelessWidget {
  final NewScreenWizardState _state;

  NewScreenWizardGeneral(this._state) {
    _state.screenNameTextController.addListener(() {    _state.viewModel.screenName = _state.screenNameTextController.text;});
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(dim.activityMargin),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _state.screenNameTextController,
              decoration: InputDecoration(
                  hintText: _state.translation.text(NewScreenWizardText.screenName)),

            ),
            _OrientationWidget(_state),
            _LayoutWidget(),
            _DesignWidget()
          ],
        ),
      ),
    );

  }
}

// the w
class _OrientationWidget extends StatelessWidget {
  final NewScreenWizardState _state;

  _OrientationWidget(this._state);

  @override
  Widget build(BuildContext context) {
    Icon icon = new Icon(Icons.screen_lock_portrait);
    if (_state.viewModel.isLandscape)
      icon = new Icon (Icons.screen_lock_landscape);


    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _state.translation.text(NewScreenWizardText.orientation),
            style: Theme.of(context).textTheme.headline4,
          ),
          RaisedButton(onPressed: () {
            _state.viewModel.isLandscape = !_state.viewModel.isLandscape;
          },
            child: icon
          ),
        ],
      ),
    );
  }
}

class _LayoutWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Text("Layout"),
          RaisedButton(onPressed: () {  },
            child: Text("Increase Horizontal"),),
          RaisedButton(onPressed: () {  },
            child: Text("Reduce Horizontal"),),
          RaisedButton(onPressed: () {  },
            child: Text("Increase Vertical"),),
          RaisedButton(onPressed: () {  },
            child: Text("Reduce Vertical"),),
        ],
      ),
    );
  }
}

class _DesignWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Text("Button Design"),
          RaisedButton(onPressed: () {  },
            child: Text("Normal Image"),),
          RaisedButton(onPressed: () {  },
            child: Text("Pressed Image"),),
          Text("Switch Design"),
          RaisedButton(onPressed: () {  },
            child: Text("Normal Image"),),
          RaisedButton(onPressed: () {  },
            child: Text("Pressed Image"),),
        ],
      ),
    );
  }
}
