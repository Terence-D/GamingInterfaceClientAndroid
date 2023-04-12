// this widget handles setting if we are portrait or landscape mode
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/intl/intlNewScreenWizard.dart';

import 'newScreenWizard.dart';

class LayoutWidget extends StatefulWidget {
  final NewScreenWizardState state;

  const LayoutWidget ( this.state, {Key key  }): super(key: key);

  @override
  State<StatefulWidget> createState() => LayoutState();
}

class LayoutState extends State<LayoutWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            widget.state.translation.text(NewScreenWizardText.layout),
            style: Theme.of(context).textTheme.headline5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(onPressed: () { _updateCount(horizontal: -1); },
                child: Text("${widget.state.translation.text(NewScreenWizardText.decrease)}"),),
              Text("${widget.state.viewModel.horizontalControlCount} ${widget.state.translation.text(NewScreenWizardText.controlsWide)}"),
              ElevatedButton(onPressed: () { _updateCount(horizontal: 1); },
                child: Text("${widget.state.translation.text(NewScreenWizardText.increase)}"),),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(onPressed: () { _updateCount(vertical: -1); },
                child: Text("${widget.state.translation.text(NewScreenWizardText.decrease)}"),),
              Text("${widget.state.viewModel.verticalControlCount} ${widget.state.translation.text(NewScreenWizardText.controlsDepth)}"),
              ElevatedButton(onPressed: () { _updateCount(vertical: 1); },
                child: Text("${widget.state.translation.text(NewScreenWizardText.increase)}"),),
            ],
          ),
          Text("${widget.state.viewModel.horizontalControlCount * widget.state.viewModel.verticalControlCount } ${widget.state.translation.text(NewScreenWizardText.totalControls)}",),
      ]
      )
    );
  }

  void _updateCount({int horizontal=0, int vertical=0}) {
    setState(() {
      if (widget.state.viewModel.horizontalControlCount + horizontal > 0 &&
          widget.state.viewModel.horizontalControlCount + horizontal < 25) {
        widget.state.viewModel.horizontalControlCount += horizontal;
      }
      if (widget.state.viewModel.verticalControlCount + vertical > 0 &&
          widget.state.viewModel.verticalControlCount + vertical < 25) {
        widget.state.viewModel.verticalControlCount += vertical;
      }
    });
  }
}

