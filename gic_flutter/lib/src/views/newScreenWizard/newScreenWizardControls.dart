import 'dart:core';

import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/autoItKeyMap.dart';
import 'package:gic_flutter/src/backend/models/intl/intlNewScreenWizard.dart';
import 'package:gic_flutter/src/backend/models/newScreenWizardModel.dart';
import 'package:gic_flutter/src/theme/dimensions.dart' as dim;

import 'newScreenWizard.dart';

class NewScreenWizardControls extends StatefulWidget {
  final NewScreenWizardState state;

  const NewScreenWizardControls (this.state, { Key key }): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return NewScreenWizardControlsState();
  }
}

class NewScreenWizardControlsState extends State<NewScreenWizardControls> {
  int _itemCount = 0;
  List<_Key> _keyMap = [];
  AutoItKeyMap autoItKeyMap = AutoItKeyMap();
  List<_Key> selectedKey = [];
  List<String> controlTypeText;

  @override
  void initState() {
    controlTypeText = [];

    _itemCount = widget.state.viewModel.horizontalControlCount * widget.state.viewModel.verticalControlCount;
    selectedKey = List(_itemCount);

    widget.state.keyNameController = List(_itemCount);
    widget.state.viewModel.controls = List(_itemCount);

    //initialize values to be sane
    for (var i = 0; i < _itemCount; i++) {
      TextEditingController tec = TextEditingController();
      widget.state.keyNameController[i] = tec;
      widget.state.viewModel.controls[i] = NewScreenWizardControl();
      controlTypeText.add(widget.state.translation.text(NewScreenWizardText.buttonType));
    }

    autoItKeyMap.map.forEach((key, value) {
      _keyMap.add(_Key(key, value));
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              // scrollDirection: Axis.horizontal,
                itemCount: _itemCount,
                padding: EdgeInsets.fromLTRB(dim.activityMargin, dim.activityMargin,  dim.activityMargin, dim.activityMargin),
                itemBuilder: (context, index) {
                  return _controlCard(index, context);
                }),
          ),
        ],
      ),
    );
  }

  Container _controlCard(int index, BuildContext context) {
    return Container(
        height: 180,
        width: double.maxFinite,
        child: Card(
          elevation: 5,
          child:
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: dim.activityMargin, right: dim.activityMargin),
                      child: TextFormField(
                        controller: widget.state.keyNameController[index],
                        decoration: InputDecoration(
                            hintText: widget.state.translation.text(NewScreenWizardText.controlText)),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: dim.activityMargin, right: dim.activityMargin),
                    child: DropdownButton<_Key>(
                      hint: Text(widget.state.translation.text(NewScreenWizardText.controlCommand)),
                      onChanged: (_Key newValue) { _updateState(index, control: newValue); },
                      value: selectedKey[index],
                      items: _dropdownItems()
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: [
                      Switch(
                        value: widget.state.viewModel.controls[index].isSwitch,
                        onChanged: (bool value) {
                        _updateState(index, isSwitch: value);  }
                        ),
                      Text(controlTypeText[index]),
                    ],
                  ),

                  Column(
                    children: [
                      Switch(
                          value: widget.state.viewModel.controls[index].ctrl,
                          onChanged: (bool value) {
                            _updateState(index, ctrl: value);  }
                      ),
                      Text(widget.state.translation.text(NewScreenWizardText.ctrl)),
                    ],
                  ),

                  Column(
                    children: [
                      Switch(
                          value: widget.state.viewModel.controls[index].alt,
                          onChanged: (bool value) {
                            _updateState(index, alt: value);  }
                      ),
                      Text(widget.state.translation.text(NewScreenWizardText.alt)),
                    ],
                  ),

                  Column(
                    children: [
                      Switch(
                          value: widget.state.viewModel.controls[index].shift,
                          onChanged: (bool value) {
                            _updateState(index, shift: value);  }
                      ),
                      Text(widget.state.translation.text(NewScreenWizardText.shift)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        )
    );
  }

  void _updateState(int index, {_Key control, bool isSwitch, bool ctrl, bool alt, bool shift}) {
    setState(() {
      if (control != null) {
        selectedKey[index] = control;
        widget.state.viewModel.controls[index].key = control.key;
      }

      if (isSwitch != null) {
        widget.state.viewModel.controls[index].isSwitch = isSwitch;
        if (isSwitch) {
          controlTypeText[index] = widget.state.translation.text(NewScreenWizardText.switchType);
        } else {
          controlTypeText[index] = widget.state.translation.text(NewScreenWizardText.buttonType);
        }
      }

      if (ctrl != null) {
        widget.state.viewModel.controls[index].ctrl = ctrl;
      }
      if (alt != null) {
        widget.state.viewModel.controls[index].alt = alt;
      }
      if (shift != null) {
        widget.state.viewModel.controls[index].shift = shift;
      }
    });
  }

  List<DropdownMenuItem<_Key>> _dropdownItems() {
    return _keyMap.map((_Key key) {
      return DropdownMenuItem<_Key>(
          value: key,
          child: Text(key.text));
    }).toList();
  }
}

class _Key {
  final String key;
  final String text;
  _Key (this.key, this.text);
}