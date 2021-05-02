import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/autoItKeyMap.dart';
import 'package:gic_flutter/src/backend/models/intl/intlScreenEditor.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';
import 'package:gic_flutter/src/views/screenEditor/gicEditControl.dart';

class CommandTab extends StatefulWidget {
  final IntlScreenEditor translation;
  final GicEditControl gicEditControl;
  final bool isButton;

  CommandTab({Key key, this.gicEditControl, this.translation, this.isButton})
      : super(key: key);

  @override
  CommandTabState createState() => CommandTabState();
}

class CommandTabState extends State<CommandTab> {
  final List<TextEditingController> textControllers = [];
  final AutoItKeyMap _commandList = new AutoItKeyMap();
  final List<String> _dropDownItems = [];
  String switchText;

  @override
  void initState() {
    if (widget.gicEditControl.control.type == ControlViewModelType.QuickButton)
      switchText = widget.translation.text(ScreenEditorText.enabled);
    else
      switchText = widget.translation.text(ScreenEditorText.disabled);

    _commandList.map.entries.forEach((e) => _dropDownItems.add(e.value));
    widget.gicEditControl.control.commands.forEach((element) {
      if (element.key == null) element.key = _commandList.map.keys.first;
    });
  } //text to show when the quick button is toggled

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text(widget.translation.text(ScreenEditorText.commandTabHeader),
              style: Theme.of(context).textTheme.headline5),
          Visibility(
            child: Text(widget.translation
                .text(ScreenEditorText.commandTabPrimaryToggleDetails)),
            visible: widget.gicEditControl.control.type ==
                ControlViewModelType.Toggle,
          ),
          Visibility(
            child: Text(widget.translation
                .text(ScreenEditorText.commandTabPrimaryDetails)),
            visible: widget.gicEditControl.control.type !=
                ControlViewModelType.Toggle,
          ),
          buildCommandDropDown(0),
          Row(children: modifierCheckboxes(0)),
          const Divider(
            height: 40,
            thickness: 5,
            indent: 20,
            endIndent: 20,
          ),
          Visibility(
              child: Column(
                children: [
                  Text(widget.translation
                      .text(ScreenEditorText.commandTabSecondaryDetails)),
                  buildCommandDropDown(1),
                  Row(children: modifierCheckboxes(1))
                ],
              ),
              visible: !widget.isButton),
          Visibility(
              child: Column(
                children: [
                  Text(widget.translation
                      .text(ScreenEditorText.commandTabQuickModeDetails)),
                  Row(
                    children: [
                      Text(switchText),
                      buildQuickMode(),
                    ],
                  )
                ],
              ),
              visible: widget.isButton)
        ],
      ),
    );
  }

  @override
  void dispose() {
    textControllers.forEach((element) => element.dispose());
    super.dispose();
  }

  //toggle switch letting the enabling/disabling of quick mode for buttons
  Switch buildQuickMode() {
    return Switch(
      value: (widget.gicEditControl.control.type ==
          ControlViewModelType.QuickButton),
      onChanged: (value) {
        setState(() {
          if ((widget.gicEditControl.control.type ==
              ControlViewModelType.QuickButton)) {
            widget.gicEditControl.control.type = ControlViewModelType.Button;
            switchText = widget.translation.text(ScreenEditorText.disabled);
          } else {
            widget.gicEditControl.control.type =
                ControlViewModelType.QuickButton;
            switchText = widget.translation.text(ScreenEditorText.enabled);
          }
        });
      },
    );
  }

  //this drop down provides a list of all supported commands
  //the index determines if we are doing this for the primary or secondary controls
  DropdownButton<String> buildCommandDropDown(int commandIndex) {
    return DropdownButton<String>(
      isExpanded: true,
      hint: Text(widget.translation.text(ScreenEditorText.commandDropDownHint)),
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

  //these modifiers are used for commands and are to allow the selection
  //of modifier keys like ctrl alt shift
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

  //builds the actual checkbox for the modifierCheckboxes method
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
