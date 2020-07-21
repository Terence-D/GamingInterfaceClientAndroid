// this widget handles setting if we are portrait or landscape mode
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gic_flutter/model/intl/intlNewScreenWizard.dart';

import 'newScreenWizard.dart';

class LayoutWidget extends StatefulWidget {
  final NewScreenWizardState state;

  const LayoutWidget ( this.state, {Key key  }): super(key: key);

  @override
  State<StatefulWidget> createState() => new LayoutState();

}

class LayoutState extends State<LayoutWidget> {
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
            widget.state.translation.text(NewScreenWizardText.layout),
            style: Theme.of(context).textTheme.headline5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(onPressed: () { _updateCount(horizontal: -1); },
                child: Text("Remove"),),
              Text("${widget.state.viewModel.horizontalControlCount} Controls Wide"),
              RaisedButton(onPressed: () { _updateCount(horizontal: 1); },
                child: Text("Add"),),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(onPressed: () { _updateCount(vertical: -1); },
                child: Text("Remove"),),
              Text("${widget.state.viewModel.verticalControlCount} Controls Deep"),
              RaisedButton(onPressed: () { _updateCount(vertical: 1); },
                child: Text("Add"),),
            ],
          ),
          Text("${widget.state.viewModel.horizontalControlCount * widget.state.viewModel.verticalControlCount } Total controls",),
      ]
      )
    );
  }

  void _setButton() {
    icon = new Icon(Icons.screen_lock_portrait);
    if (widget.state.viewModel.isLandscape)
      icon = new Icon(Icons.screen_lock_landscape);
  }

  void _updateCount({int horizontal=0, int vertical=0}) {
    setState(() {
      if (widget.state.viewModel.horizontalControlCount + horizontal > 0 &&
          widget.state.viewModel.horizontalControlCount + horizontal < 25)
        widget.state.viewModel.horizontalControlCount += horizontal;
      if (widget.state.viewModel.verticalControlCount + vertical > 0 &&
          widget.state.viewModel.verticalControlCount + vertical < 25)
        widget.state.viewModel.verticalControlCount += vertical;
    });
  }
}

