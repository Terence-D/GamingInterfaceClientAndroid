import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';
import 'package:gic_flutter/src/views/screenEditor/gicEditControl.dart';

class ControlDialog extends StatefulWidget {
  final GicEditControl gicEditControl;

  const ControlDialog({Key key, this.gicEditControl}) : super(key: key);

  @override
  _ControlDialogState createState() => _ControlDialogState();
}

class _ControlDialogState extends State<ControlDialog> {
  List<Widget> tabs = [];
  List<Widget> tabContents = [];


  @override
  void initState() {
    switch (widget.gicEditControl.control.type) {
      case ControlViewModelType.Text:
        tabs.add(textTab());
        tabContents.add(textTabContents());
        break;
      case ControlViewModelType.Button:
      case ControlViewModelType.Image:
        tabs.add(imageTab());
        tabContents.add(imageTabContents());
        break;
      case ControlViewModelType.Toggle:
      case ControlViewModelType.QuickButton:
        tabs.add(commandTab());
        tabContents.add(commandTabContents());
        tabs.add(imageTab());
        tabContents.add(imageTabContents());
        tabs.add(textTab());
        tabContents.add(textTabContents());
        break;
    }
    //everyone gets sizing
    tabs.add(sizingTab());
    tabContents.add(sizingTabContents());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(),
        elevation: 0,
        child: DefaultTabController(
            length: tabs.length,
            child: Scaffold(
              appBar: AppBar(
                bottom: TabBar(
                  tabs: tabs,
                ),
                title: widget.gicEditControl,
              ),
              body: TabBarView(
                children: tabContents,
              ),
            )));
  }

  commandTab() {
    return Tab(icon: Icon(Icons.build));
  }

  imageTab() {
    return Tab(icon: Icon(Icons.image));
  }

  textTab() {
    return Tab(icon: Icon(Icons.text_fields));
  }

  sizingTab() {
    return Tab(icon: Icon(Icons.straighten));
  }

  commandTabContents() {
    return Column(
      children: <Widget>[
      ],
    );
  }

  textTabContents() {
    return Column(
      children: <Widget>[
      ],
    );
  }

  imageTabContents() {
    return Column(
      children: <Widget>[
      ],
    );
  }

  sizingTabContents() {
    return Column(
      children: <Widget>[
      ],
    );
  }
}
