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
      case ControlViewModelType.Image:
        tabs.add(imageTab());
        tabContents.add(imageTabContents());
        break;
      case ControlViewModelType.Button:
      case ControlViewModelType.QuickButton:
        buildCommandTab(true);
        tabs.add(imageTab());
        tabContents.add(imageTabContents());
        tabs.add(textTab());
        tabContents.add(textTabContents());
        break;
      case ControlViewModelType.Toggle:
        buildCommandTab(false);
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

  void buildCommandTab(bool isButton) {
    tabs.add(Tab(icon: Icon(Icons.build)));
    List<Widget> widgets = [];
    List<String> dropdownItems = <String>['A', 'B', 'C'];

    //everyone has at least 1 command to pick
    widgets.add(Text("Primary"));
    widgets.add(DropdownButton<String>(
      isExpanded: true,
      value: "A",
      elevation: 16,
      underline: Container(
        height: 2,
      ),
      onChanged: (String newValue) {
        setState(() {
        });
      },
      items: dropdownItems.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    ));
    widgets.add(Row(
      children: [
        Text("Ctrl"),
        Checkbox(
          value: true, //do something here
          onChanged: (bool value) {
            setState(() {
              //this.showvalue = value;
            });
          },
        ),
        Text("Alt"),
        Checkbox(
          value: true, //do something here
          onChanged: (bool value) {
            setState(() {
              //this.showvalue = value;
            });
          },
        ),
        Text("Shift"),
        Checkbox(
          value: true, //do something here
          onChanged: (bool value) {
            setState(() {
              //this.showvalue = value;
            });
          },
        )
      ],
    ));

    if (!isButton) {
      widgets.add(Text("Secondary"));
      widgets.add(DropdownButton<String>(
        isExpanded: true,
        value: "A",
        elevation: 16,
        underline: Container(
          height: 2,
        ),
        onChanged: (String newValue) {
          setState(() {
          });
        },
        items: dropdownItems.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ));
      widgets.add(Row(
        children: [
          Text("Ctrl"),
          Checkbox(
            value: true, //do something here
            onChanged: (bool value) {
              setState(() {
                //this.showvalue = value;
              });
            },
          ),
          Text("Alt"),
          Checkbox(
            value: true, //do something here
            onChanged: (bool value) {
              setState(() {
                //this.showvalue = value;
              });
            },
          ),
          Text("Shift"),
          Checkbox(
            value: true, //do something here
            onChanged: (bool value) {
              setState(() {
                //this.showvalue = value;
              });
            },
          )
        ],
      ));
    }

    //buttons have the quick toggle feature
    if (isButton) {
      bool isOn = false;
      if (widget.gicEditControl.control.type ==
          ControlViewModelType.QuickButton) isOn = true;
      widgets.add(Row(
        children: [
          Text("Quick Mode"),
          Switch(
            value: isOn,
            onChanged: (value) {
              setState(() {
                isOn = value;
              });
            },
          )
        ],
      ));
    }

    tabContents.add(Column(
      children: widgets,
    ));
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

  textTabContents() {
    return Column(
      children: <Widget>[],
    );
  }

  imageTabContents() {
    return Column(
      children: <Widget>[],
    );
  }

  sizingTabContents() {
    return Column(
      children: <Widget>[],
    );
  }
}
