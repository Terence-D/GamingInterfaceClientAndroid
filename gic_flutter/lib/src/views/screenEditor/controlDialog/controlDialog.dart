import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/intl/intlScreenEditor.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';
import 'package:gic_flutter/src/backend/services/screenService.dart';
import 'package:gic_flutter/src/views/screenEditor/controlDialog/commandTab.dart';
import 'package:gic_flutter/src/views/screenEditor/controlDialog/designTab.dart';
import 'package:gic_flutter/src/views/screenEditor/controlDialog/sizeTab.dart';
import 'package:gic_flutter/src/views/screenEditor/controlDialog/textTab.dart';
import 'package:gic_flutter/src/views/screenEditor/gicEditControl.dart';

enum controlResult {save,delete}

class ControlDialog extends StatefulWidget {
  final IntlScreenEditor translation;
  final GicEditControl gicEditControl;
  final int screenId;
  final ScreenService screenService;

  ControlDialog({Key key, this.gicEditControl, this.translation, this.screenId, this.screenService})
      : super(key: key);

  @override
  _ControlDialogState createState() => _ControlDialogState(translation);
}

class _ControlDialogState extends State<ControlDialog> {
  final IntlScreenEditor translation;

  List<Widget> _tabs = [];
  List<Widget> _tabContents = [];

  _ControlDialogState(this.translation);

  Widget designTab() => Tab(icon: Icon(Icons.image));

  Widget textTab() => Tab(icon: Icon(Icons.text_fields));

  Widget buildTab() => Tab(icon: Icon(Icons.build));

  Widget sizingTab() => Tab(icon: Icon(Icons.straighten));

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    buildTabs();
    return Dialog(
        child: DefaultTabController(
            length: _tabs.length,
            child: Scaffold(
              appBar: AppBar(
                leading: Builder(
                  builder: (BuildContext context) {
                    return IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: () {
                        Navigator.pop(context, controlResult.save);
                      },
                      tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                    );
                  },
                ),
                title:
                    Text(translation.text(ScreenEditorText.controlDialogTitle)),
                actions: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(right: 20.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context, controlResult.delete);
                        },
                        child: Icon(
                          Icons.delete,
                          size: 26.0,
                        ),
                      )),
                ],
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
        _tabs.add(designTab());
        _tabContents.add(DesignTab(
          gicEditControl: widget.gicEditControl,
          translation: translation,
          screenId: widget.screenId,
        ));
        break;
      case ControlViewModelType.Button:
      case ControlViewModelType.QuickButton:
        _tabs.add(buildTab());
        _tabContents.add(CommandTab(
            gicEditControl: widget.gicEditControl,
            translation: translation,
            isButton: true));
        _tabs.add(designTab());
        _tabContents.add(DesignTab(
          gicEditControl: widget.gicEditControl,
          translation: translation,
          screenId: widget.screenId,
        ));
        _tabs.add(textTab());
        _tabContents.add(TextTab(
            gicEditControl: widget.gicEditControl, translation: translation));
        break;
      case ControlViewModelType.Toggle:
        _tabs.add(buildTab());
        _tabContents.add(CommandTab(
            gicEditControl: widget.gicEditControl,
            translation: translation,
            isButton: true));
        _tabs.add(designTab());
        _tabContents.add(DesignTab(
          gicEditControl: widget.gicEditControl,
          translation: translation,
          screenId: widget.screenId,
        ));
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
}
