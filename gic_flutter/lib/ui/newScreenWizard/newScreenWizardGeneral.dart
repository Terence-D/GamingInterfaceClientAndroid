import 'package:flutter/material.dart';
import 'package:gic_flutter/model/intl/intlNewScreenWizard.dart';
import 'package:gic_flutter/theme/dimensions.dart' as dim;

import 'OrientationWidget.dart';
import 'newScreenWizard.dart';

class NewScreenWizardGeneral extends StatefulWidget {
  final NewScreenWizardState state;

  const NewScreenWizardGeneral (this.state, { Key key }): super(key: key);

  @override
  State<StatefulWidget> createState() {
    state.screenNameTextController.addListener(() {    state.viewModel.screenName = state.screenNameTextController.text;});
    return NewScreenWizardGeneralState();
  }
}

class NewScreenWizardGeneralState extends State<NewScreenWizardGeneral> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(dim.activityMargin),
        child: Column(
          children: <Widget>[
            TextField(
              controller: widget.state.screenNameTextController,
              decoration: InputDecoration(
                  hintText: widget.state.translation.text(NewScreenWizardText.screenName)),

            ),
            OrientationWidget(widget.state),
            _LayoutWidget(),
            _DesignWidget()
          ],
        ),
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
