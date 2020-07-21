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
          RaisedButton(onPressed: () {  },
            child: Text("Increase Horizontal"),),
          RaisedButton(onPressed: () {  },
            child: Text("Reduce Horizontal"),),
          RaisedButton(onPressed: () {  },
            child: Text("Increase Vertical"),),
          RaisedButton(onPressed: () {  },
            child: Text("Reduce Vertical"),),
          Table(
            border: TableBorder.all(),
            children: [
              TableRow( children: [
                Column(children:[
                  Icon(Icons.account_box, size: 32,),
                  Text('My Account')
                ]),
                Column(children:[
                  Icon(Icons.settings, size: 32,),
                  Text('Settings')
                ]),
                Column(children:[
                  Icon(Icons.lightbulb_outline, size: 32,),
                  Text('Ideas')
                ]),
              ]),
              TableRow( children: [
                Icon(Icons.cake, size: 32,),
                Icon(Icons.voice_chat, size: 32,),
                Icon(Icons.add_location, size: 32,),
              ]),
          ]),
      ]
      )
    );
  }

  void _setButton() {
    icon = new Icon(Icons.screen_lock_portrait);
    if (widget.state.viewModel.isLandscape)
      icon = new Icon(Icons.screen_lock_landscape);
  }
}

