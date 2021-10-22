import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/intl/intlScreenEditor.dart';
import 'package:gic_flutter/src/views/screenEditor/helpDialog/selectTab.dart';

class HelpDialog extends StatefulWidget {
  final IntlScreenEditor translation;

  HelpDialog({Key key, this.translation})
      : super(key: key);

  @override
  _HelpDialogState createState() => _HelpDialogState(translation);
}

class _HelpDialogState extends State<HelpDialog> {
  final IntlScreenEditor translation;

  List<Widget> _tabs = [];
  List<Widget> _tabContents = [];

  _HelpDialogState(this.translation);

  //headers
  Widget editTab() => Tab(icon: Icon(Icons.edit));
  Widget movingTab() => Tab(icon: Icon(Icons.touch_app));
  Widget sizingTab() => Tab(icon: Icon(Icons.photo_size_select_large));
  Widget quitTab() => Tab(icon: Icon(Icons.exit_to_app));

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
                title:
                    Text(translation.text(ScreenEditorText.helpDialogTitle)),
                bottom: TabBar(
                  tabs: _tabs,
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
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
    _tabs.add(editTab());
    _tabContents.add(SimpleTextTab(
      title: translation.text(ScreenEditorText.helpEditHeader),
      details: translation.text(ScreenEditorText.helpEditDetails),
    ));
    _tabs.add(movingTab());
    _tabContents.add(SimpleTextTab(
      title: translation.text(ScreenEditorText.helpMoveHeader),
      details: translation.text(ScreenEditorText.helpMoveDetails),
    ));
    _tabs.add(sizingTab());
    _tabContents.add(SimpleTextTab(
      title: translation.text(ScreenEditorText.helpSizeHeader),
      details: translation.text(ScreenEditorText.helpSizeDetails),
    ));
    _tabs.add(quitTab());
    _tabContents.add(SimpleTextTab(
      title: translation.text(ScreenEditorText.helpQuitHeader),
      details: translation.text(ScreenEditorText.helpQuitDetails),
    ));
  }
}
