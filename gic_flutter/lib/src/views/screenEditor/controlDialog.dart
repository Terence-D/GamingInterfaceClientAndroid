import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gic_flutter/src/backend/models/autoItKeyMap.dart';
import 'package:gic_flutter/src/backend/models/intl/intlScreenEditor.dart';
import 'package:gic_flutter/src/backend/models/screen/fonts.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';
import 'package:gic_flutter/src/views/screenEditor/gicEditControl.dart';

class ControlDialog extends StatefulWidget {
  final IntlScreenEditor translation;
  final GicEditControl gicEditControl;

  const ControlDialog({Key key, this.gicEditControl, this.translation})
      : super(key: key);

  @override
  _ControlDialogState createState() => _ControlDialogState(translation);
}

class _ControlDialogState extends State<ControlDialog> {
  final IntlScreenEditor translation;
  final AutoItKeyMap _commandList = new AutoItKeyMap();
  final List<String> _dropDownItems = [];

  List<TextEditingController> textControllers = [];
  List<Widget> _tabs = [];
  List<Widget> _tabContents = [];
  String switchText; //text to show when the quick button is toggled

  _ControlDialogState(this.translation);

  Widget imageTab() => Tab(icon: Icon(Icons.image));

  Widget textTab() => Tab(icon: Icon(Icons.text_fields));

  Widget sizingTab() => Tab(icon: Icon(Icons.straighten));

  @override
  void initState() {
    super.initState();

    if (widget.gicEditControl.control.type == ControlViewModelType.QuickButton)
      switchText = translation.text(ScreenEditorText.enabled);
    else
      switchText = translation.text(ScreenEditorText.disabled);

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
              ),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TabBarView(
                  children: _tabContents,
                ),
              ),
            )));
  }

  @override
  void dispose() {
    textControllers.forEach((element) => element.dispose());
    super.dispose();
  }

  //sets up the tabs, based on type of control we're editing
  //different control types need different tab views
  void buildTabs() {
    _tabs = [];
    _tabContents = [];
    switch (widget.gicEditControl.control.type) {
      case ControlViewModelType.Text:
        buildTextTab(false);
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
        buildTextTab(false);
        break;
      case ControlViewModelType.Toggle:
        buildCommandTab(false);
        _tabs.add(imageTab());
        _tabContents.add(imageTabContents());
        buildTextTab(true);
        break;
    }
    //everyone gets sizing
    _tabs.add(sizingTab());
    _tabContents.add(sizingTabContents());
  }

  void buildTextTab(bool isToggle) {
    List<Widget> widgets = [];

    _tabs.add(textTab());

    widgets.add(Text(translation.text(ScreenEditorText.textTabHeader),
        style: Theme.of(context).textTheme.headline5));
    //everyone has at least 1 text
    widgets.add(Text(translation.text(ScreenEditorText.textTabPrimaryDetails)));
    widgets.add(buildText(0));

    if (isToggle) {
      widgets.add(
          Text(translation.text(ScreenEditorText.textTabPrimaryToggleDetails)));
      widgets.add(buildText(1));
    }

    widgets.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          child: Text(translation.text(ScreenEditorText.textTabFontColor)),
          onPressed: () {
            pickColor();
          },
        ),
        ElevatedButton(
          child: Text(translation.text(ScreenEditorText.textTabFont)),
          onPressed: () {
            pickFont();
          },
        )
      ],
    ));

    widgets.add(Text(translation.text(ScreenEditorText.textTabFontSize)));

    widgets.add(
      Row(
        children: [
          Slider(
            min: 8,
            max: 512,
            value: widget.gicEditControl.control.font.size,
            onChanged: (value) {
              setState(() {
                widget.gicEditControl.control.font.size = value.roundToDouble();
              });
            },
          ),
          Flexible(child: size())
        ],
      ),
    );

    _tabContents.add(Column(
      children: widgets,
    ));
  }

  TextField size() {
    TextEditingController controller = new TextEditingController();
    textControllers.add(controller);
    controller.text = widget.gicEditControl.control.font.size.toString();
    controller.addListener(() {
      widget.gicEditControl.control.font.size = double.parse(controller.text);
    });

    return TextField(
        controller: controller, keyboardType: TextInputType.number);
  }

  Color pickerColor = Color(0xff443a49);

  void _changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  void pickColor() {
    pickerColor = widget.gicEditControl.control.font.color;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(translation.text(ScreenEditorText.backgroundColor)),
        content: SingleChildScrollView(
            child: ColorPicker(
          pickerColor: pickerColor,
          onColorChanged: _changeColor,
          showLabel: true,
          enableAlpha: false,
        )),
        actions: <Widget>[
          TextButton(
            child: Text(translation.text(ScreenEditorText.ok)),
            onPressed: () {
              widget.gicEditControl.control.font.color = pickerColor;
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  //Command Tab - handles the tab to design sending commands to the server
  void buildCommandTab(bool isButton) {
    _tabs.add(Tab(icon: Icon(Icons.build)));
    List<Widget> widgets = [];

    widgets.add(Text(translation.text(ScreenEditorText.commandTabHeader),
        style: Theme.of(context).textTheme.headline5));
    //everyone has at least 1 command to pick
    if (widget.gicEditControl.control.type == ControlViewModelType.Toggle)
      widgets.add(Text(
          translation.text(ScreenEditorText.commandTabPrimaryToggleDetails)));
    else
      widgets.add(
          Text(translation.text(ScreenEditorText.commandTabPrimaryDetails)));
    widgets.add(buildCommandDropDown(0));
    widgets.add(Row(children: modifierCheckboxes(0)));

    widgets.add(const Divider(
      height: 40,
      thickness: 5,
      indent: 20,
      endIndent: 20,
    ));

    if (!isButton) {
      widgets.add(
          Text(translation.text(ScreenEditorText.commandTabSecondaryDetails)));
      widgets.add(buildCommandDropDown(1));
      widgets.add(Row(children: modifierCheckboxes(1)));
    } else {
      widgets.add(
          Text(translation.text(ScreenEditorText.commandTabQuickModeDetails)));
      widgets.add(Row(
        children: [
          Text(switchText),
          buildQuickMode(),
        ],
      ));
    }

    _tabContents.add(Column(
      children: widgets,
    ));
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

  //show text editing widget for the supplied index
  TextField buildText(int textIndex) {
    TextEditingController controller = new TextEditingController();

    textControllers.add(controller);
    controller.text = widget.gicEditControl.control.text;
    controller.addListener(() {
      widget.gicEditControl.control.text = controller.text;
    });

    return TextField(
      controller: controller,
    );
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
            switchText = translation.text(ScreenEditorText.disabled);
          } else {
            widget.gicEditControl.control.type =
                ControlViewModelType.QuickButton;
            switchText = translation.text(ScreenEditorText.enabled);
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
      hint: Text(translation.text(ScreenEditorText.commandDropDownHint)),
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

  void pickFont() {
    List<Widget> fontButtons = [];
    Fonts.list().forEach((key, value) {
      fontButtons.add (
        TextButton(
          onPressed: () {
            widget.gicEditControl.control.font.family = key;
            Navigator.pop(context);
          },
          child: Text(
            value,
            style: TextStyle(fontFamily: key, fontSize: 36),
          ),
        ),
      );
    });

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              height: 300,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: fontButtons,
                ),
              ),
            ),
          );
        });
  }
}
