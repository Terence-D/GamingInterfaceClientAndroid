import 'package:gic_flutter/theme/dimensions.dart' as dim;
import 'package:flutter/material.dart';
import 'package:gic_flutter/ui/newScreenWizard/newScreenWizard.dart';

class NewScreenWizardControls extends StatefulWidget {
  final NewScreenWizardState state;

  const NewScreenWizardControls (this.state, { Key key }): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return NewScreenWizardControlsState();
  }
}

class NewScreenWizardControlsState extends State<NewScreenWizardControls> {
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
                  hintText: "asdf"),
            ),
//            OrientationWidget(widget.state),
//            LayoutWidget(widget.state),
            //ControlDesignWidget(widget.state),
          ],
        ),
      ),
    );

  }
}
