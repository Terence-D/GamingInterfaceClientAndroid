import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/autoItKeyMap.dart';
import 'package:gic_flutter/src/backend/models/intl/intlScreenEditor.dart';
import 'package:gic_flutter/src/backend/models/screen/command.dart';
import 'package:gic_flutter/src/backend/models/screen/controlDefaults.dart';
import 'package:gic_flutter/src/backend/models/screen/gicControl.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';
import 'package:gic_flutter/src/views/screenEditor/controlDialog/baseTab.dart';
import 'package:gic_flutter/src/views/screenEditor/gicEditControl.dart';

class CommandTab extends BaseTab {
  final IntlScreenEditor translation;
  final GicEditControl gicEditControl;
  final bool isButton;
  final int screenId;

  CommandTab({Key? key, required this.screenId, required this.gicEditControl, required this.translation, required this.isButton})
      : super(
      key: key,
      gicEditControl: gicEditControl,
      translation: translation,
      screenId: screenId);

  @override
  CommandTabState createState() => CommandTabState();
}

class CommandTabState extends BaseTabState {
  final List<TextEditingController> textControllers = [];
  final AutoItKeyMap _commandList = AutoItKeyMap();
  final List<String> _dropDownItems = [];
  String? switchText;
  Orientation? orientation;

  @override
  void initState() {
    super.initState();
    if (widget.gicEditControl.control.type ==
        ControlViewModelType.QuickButton) {
      switchText = widget.translation.text(ScreenEditorText.enabled);
    } else {
      switchText = widget.translation.text(ScreenEditorText.disabled);
    }

    _commandList.map.entries.forEach((e) => _dropDownItems.add(e.value));
    widget.gicEditControl.control.commands.forEach((element) {
      if (element.key == null) element.key = _commandList.map.keys.first;
    });
  } //text to show when the quick button is toggled

  @override
  Widget build(BuildContext context) {
    orientation = MediaQuery.of(context).orientation;
    pixelRatio = MediaQuery.of(context).devicePixelRatio;
    return SingleChildScrollView(
      child: Container(
        child: LayoutBuilder(
            builder: (BuildContext ctx, BoxConstraints constraints) {
          return Column(
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
              _buildCommandWidgets(0),
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
                      _buildCommandWidgets(1),
                    ],
                  ),
                  visible: widget.gicEditControl.control.type ==
                      ControlViewModelType.Toggle),
              Visibility(
                  child: _quickCommandDetails(),
                  visible: widget.gicEditControl.control.type ==
                          ControlViewModelType.Button ||
                      widget.gicEditControl.control.type ==
                          ControlViewModelType.QuickButton),
              preview(constraints)
            ],
          );
        }),
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
    if (widget.gicEditControl.control.commands.isEmpty) {
      widget.gicEditControl.control.commands.add(Command());
    }
    while (commandIndex >=widget.gicEditControl.control.commands.length) {
      widget.gicEditControl.control.commands.add(Command());
    }
    var val;
    val = _commandList
        .map[widget.gicEditControl.control.commands[commandIndex].key];
    return DropdownButton<String>(
      isExpanded: true,
      hint: Text(widget.translation.text(ScreenEditorText.commandDropDownHint)),
      value: val,
      underline: Container(
        height: 24,
      ),
      onChanged: (String? newValue) {
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
    if (widget.gicEditControl.control.commands.isEmpty) {
      widget.gicEditControl.control.commands.add(Command());
      widget.gicEditControl.control.commands.add(Command());
    }
    if (commandIndex >= widget.gicEditControl.control.commands.length) {
      commandIndex = 0;
    }
    return Checkbox(
        value: widget.gicEditControl.control.commands[commandIndex].modifiers!
            .contains(modifier), //do something here
        onChanged: (bool? value) {
          setState(() {
            if (value!) {
              widget.gicEditControl.control.commands[commandIndex].modifiers!
                  .add(modifier);
            } else {
              widget.gicEditControl.control.commands[commandIndex].modifiers!
                  .remove(modifier);
            }
          });
        });
  }

  Widget _buildCommandWidgets(int index) {
    if (orientation == Orientation.portrait) {
      return Column(
        children: [
          buildCommandDropDown(index),
          Row(children: modifierCheckboxes(index)),
        ],
      );
    } else {
      List<Widget> modifiers = [];
      modifiers.add (Flexible(child: buildCommandDropDown(index)));
      modifiers.addAll(modifierCheckboxes(index));
      return Row (children: modifiers);
    }
  }

  Widget _quickCommandDetails() {
    if (orientation == Orientation.portrait) {
      return Column(
        children: [
          Text(widget.translation
              .text(ScreenEditorText.commandTabQuickModeDetails)),
          Row(
            children: [
              Text(switchText!),
              buildQuickMode(),
            ],
          )
        ],
      );
    }   else {
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(widget.translation
                .text(ScreenEditorText.commandTabQuickModeDetails)),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Text(switchText!),
                buildQuickMode(),
              ],
            ),
          )
        ],
      );
    }
  }
}
