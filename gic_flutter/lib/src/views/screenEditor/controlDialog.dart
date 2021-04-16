import 'dart:collection';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/autoItKeyMap.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';
import 'package:gic_flutter/src/views/screenEditor/gicEditControl.dart';

class ControlDialog extends StatefulWidget {
  final GicEditControl gicEditControl;

  const ControlDialog({Key key, this.gicEditControl}) : super(key: key);

  @override
  _ControlDialogState createState() => _ControlDialogState();
}

class _ControlDialogState extends State<ControlDialog> {
  List<Widget> _tabs = [];
  List<Widget> _tabContents = [];
  final AutoItKeyMap _commandList = new AutoItKeyMap();
  final List<String> _dropDownItems = [];

  @override
  void initState() {
    super.initState();
    _commandList.map.entries.forEach((e) => _dropDownItems.add(e.value));
    widget.gicEditControl.control.commands.forEach((element) {
      if (element.key == null) element.key = _commandList.map.keys.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    buildTabs();
    return Dialog(
        shape: RoundedRectangleBorder(),
        elevation: 0,
        child: DefaultTabController(
            length: _tabs.length,
            child: Scaffold(
              appBar: AppBar(
                bottom: TabBar(
                  tabs: _tabs,
                ),
                title: widget.gicEditControl,
              ),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TabBarView(
                  children: _tabContents,
                ),
              ),
            )));
  }

  void buildTabs() {
    _tabs = [];
    _tabContents = [];
    switch (widget.gicEditControl.control.type) {
      case ControlViewModelType.Text:
        _tabs.add(textTab());
        _tabContents.add(textTabContents());
        break;
      case ControlViewModelType.Image:
        _tabs.add(imageTab());
        _tabContents.add(imageTabContents());
        break;
      case ControlViewModelType.Button:
      case ControlViewModelType.QuickButton:
        buildCommandTab(true);
        _tabs.add(imageTab());
        _tabContents.add(imageTabContents());
        _tabs.add(textTab());
        _tabContents.add(textTabContents());
        break;
      case ControlViewModelType.Toggle:
        buildCommandTab(false);
        _tabs.add(imageTab());
        _tabContents.add(imageTabContents());
        _tabs.add(textTab());
        _tabContents.add(textTabContents());
        break;
    }
    //everyone gets sizing
    _tabs.add(sizingTab());
    _tabContents.add(sizingTabContents());
  }

  void buildCommandTab(bool isButton) {
    _tabs.add(Tab(icon: Icon(Icons.build)));
    List<Widget> widgets = [];

    widgets.add(Text("Commands", style: Theme.of(context).textTheme.headline5));
    //everyone has at least 1 command to pick
    widgets.add(Text(
        "Choose a command to send, along with any modifiers (such as Control or Shift keys)"));
    widgets.add(buildCommandDropDown(0));
    widgets.add(Row(children: modifierCheckboxes(0)));

    widgets.add(const Divider(
      height: 40,
      thickness: 5,
      indent: 20,
      endIndent: 20,
    ));

    if (!isButton) {
      widgets.add(Text("Secondary"));
      widgets.add(buildCommandDropDown(1));
      widgets.add(Row(children: modifierCheckboxes(1)));
    }

    //buttons have the quick toggle feature
    if (isButton) {
      bool isOn = false;
      if (widget.gicEditControl.control.type ==
          ControlViewModelType.QuickButton) isOn = true;
      widgets.add(
        Text(
            "Quick Mode - Enable this if you need to quickly send a command.  Disable if you need to hold it down longer for the command to activate on the server."),
      );
      widgets.add(Row(
        children: [
          Text("Disabled"),
          Switch(
            value: (widget.gicEditControl.control.type ==
                ControlViewModelType.QuickButton),
            onChanged: (value) {
              setState(() {
                if ((widget.gicEditControl.control.type ==
                    ControlViewModelType.QuickButton))
                  widget.gicEditControl.control.type =
                      ControlViewModelType.Button;
                else
                  widget.gicEditControl.control.type =
                      ControlViewModelType.QuickButton;
                isOn = value;
              });
            },
          ),
        ],
      ));
    }

    _tabContents.add(Column(
      children: widgets,
    ));
  }

  DropdownButton<String> buildCommandDropDown(int commandIndex) {
    return DropdownButton<String>(
      isExpanded: true,
      hint: Text("Command to send"),
      value: _commandList
          .map[widget.gicEditControl.control.commands[commandIndex].key],
      underline: Container(
        height: 24,
      ),
      onChanged: (String newValue) {
        setState(() {
          widget.gicEditControl.control.commands[commandIndex].key =
              _commandList.map.keys.firstWhere(
                  (element) => _commandList.map[element] == newValue,
                  orElse: () => _commandList.map.keys.first);
        });
      },
      items: _dropDownItems.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget imageTab() {
    return Tab(icon: Icon(Icons.image));
  }

  Widget textTab() {
    return Tab(icon: Icon(Icons.text_fields));
  }

  Widget sizingTab() {
    return Tab(icon: Icon(Icons.straighten));
  }

  Widget textTabContents() {
    return Column(
      children: <Widget>[],
    );
  }

  Widget imageTabContents() {
    return Column(
      children: <Widget>[],
    );
  }

  Widget sizingTabContents() {
    return Column(
      children: <Widget>[],
    );
  }

  List<Widget> modifierCheckboxes(int commandIndex) {
    List<Widget> widgets = [];
    widgets.add(Text("Ctrl"));
    widgets.add(modifierCheckbox(commandIndex, "CTRL"));
    widgets.add(Text("Alt"));
    widgets.add(modifierCheckbox(commandIndex, "ALT"));
    widgets.add(Text("Shift"));
    widgets.add(modifierCheckbox(commandIndex, "SHIFT"));
    return widgets;
  }

  Checkbox modifierCheckbox(int commandIndex, String modifier) {
    return Checkbox(
        value: widget.gicEditControl.control.commands[commandIndex].modifiers
            .contains(modifier), //do something here
        onChanged: (bool value) {
          setState(() {
            if (value)
              widget.gicEditControl.control.commands[commandIndex].modifiers
                  .add(modifier);
            else
              widget.gicEditControl.control.commands[commandIndex].modifiers
                  .remove(modifier);
          });
        });
  }
}
