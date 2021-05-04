import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/intl/intlScreenEditor.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';
import 'package:gic_flutter/src/views/screenEditor/controlDialog/commandTab.dart';
import 'package:gic_flutter/src/views/screenEditor/controlDialog/sizeTab.dart';
import 'package:gic_flutter/src/views/screenEditor/controlDialog/textTab.dart';
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

  List<Widget> _tabs = [];
  List<Widget> _tabContents = [];

  _ControlDialogState(this.translation);

  Widget imageTab() => Tab(icon: Icon(Icons.image));

  Widget textTab() => Tab(icon: Icon(Icons.text_fields));

  Widget sizingTab() => Tab(icon: Icon(Icons.straighten));

  @override
  void initState() {
    super.initState();
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

  //sets up the tabs, based on type of control we're editing
  //different control types need different tab views
  void buildTabs() {
    _tabs = [];
    _tabContents = [];
    switch (widget.gicEditControl.control.type) {
      case ControlViewModelType.Text:
        _tabs.add(textTab());
        _tabContents.add(TextTab(
            gicEditControl: widget.gicEditControl, translation: translation));
        break;
      case ControlViewModelType.Image:
        _tabs.add(imageTab());
        _tabContents.add(imageTabContents());
        break;
      case ControlViewModelType.Button:
      case ControlViewModelType.QuickButton:
        _tabs.add(Tab(icon: Icon(Icons.build)));
        _tabContents.add(CommandTab(
            gicEditControl: widget.gicEditControl,
            translation: translation,
            isButton: true));
        _tabs.add(imageTab());
        _tabContents.add(imageTabContents());
        _tabs.add(textTab());
        _tabContents.add(TextTab(
            gicEditControl: widget.gicEditControl, translation: translation));
        break;
      case ControlViewModelType.Toggle:
        _tabs.add(Tab(icon: Icon(Icons.build)));
        _tabContents.add(CommandTab(
            gicEditControl: widget.gicEditControl,
            translation: translation,
            isButton: true));
        _tabs.add(imageTab());
        _tabContents.add(imageTabContents());
        _tabs.add(textTab());
        _tabContents.add(TextTab(
            gicEditControl: widget.gicEditControl, translation: translation));
        break;
    }
    //everyone gets sizing
    _tabs.add(sizingTab());
    _tabContents.add(SizeTab(
        gicEditControl: widget.gicEditControl, translation: translation));
  }

  Widget imageTabContents() {
    return Column(
      children: <Widget>[],
    );
  }
}
