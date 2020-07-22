import 'package:flutter/material.dart';
import 'package:gic_flutter/model/intl/intlNewScreenWizard.dart';
import 'package:gic_flutter/theme/dimensions.dart' as dim;

import 'layoutWidget.dart';
import 'orientationWidget.dart';
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
            LayoutWidget(widget.state),
            //ControlDesignWidget(widget.state),
          ],
        ),
      ),
    );

  }
}
