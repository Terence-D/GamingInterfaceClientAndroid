import 'package:flutter/material.dart';
import 'package:gic_flutter/model/viewModel.dart';
import 'package:gic_flutter/views/main/mainVM.dart';

import '../basePage.dart';
import 'managePresentation.dart';
import 'manageVM.dart';

class ManageView extends BasePage {
  @override
  ManageViewState createState() {
    return ManageViewState();
  }
}

class ManageViewState extends BaseState<ManageView> {
  ManageVM _viewModel;

  GlobalKey _exportKey = GlobalObjectKey("manageExport");
  GlobalKey _newKey = GlobalObjectKey("manageNew");
  GlobalKey _importKey = GlobalObjectKey("manageImport");
  GlobalKey _deleteKey = GlobalObjectKey("manageDelete");
  GlobalKey _editKey = GlobalObjectKey("manageEdit");
  GlobalKey _updateKey = GlobalObjectKey("manageUpdate");
  GlobalKey _screenListKey = GlobalObjectKey("manageScreenList");
  GlobalKey _screenNameKey = GlobalObjectKey("manageScreenNameList");

  TextEditingController screenNameController = new TextEditingController();

  @override
  void initState() {
    presentation = new ManagePresentation(this);
    super.initState();
  }

  @override
  void onLoadComplete(ViewModel viewModel) {
    setState(() {
      this._viewModel = viewModel;
      if (_viewModel.screens.length > 0)
        screenNameController.text = _viewModel.screens[0].name;
      else
        screenNameController.text = "";
      if (_viewModel.screens.length > 0)
        _viewModel.selectedScreen = _viewModel.screens[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text(_viewModel.toolbarTitle),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.help_outline),
                onPressed: () {
//                  _loadHelp();
                }),
            // overflow menu
            PopupMenuButton<int>(
              onSelected: _menuSelectAction,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                PopupMenuItem<int>(
                  value: 0,
                  child: Text(_viewModel.btnImport)
                )]
              )],
            ),
        body: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: ListView.builder(
// scrollDirection: Axis.horizontal,
                    itemCount: _viewModel.screens.length,
                    itemBuilder: (context, index) {
                      return screenCard(_viewModel.screens[index]);
                    }),
              ),
            ],
          ),
//            margin: EdgeInsets.all(dim.activityMargin),
//            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
//              children: <Widget>[
//                Row(
//                  mainAxisAlignment: MainAxisAlignment.spaceAround,
//                  children: <Widget>[
//                    Padding(
//                      padding: EdgeInsets.all(dim.activityMargin),
//                      child:
//                      RaisedButton(
//                        key: _newKey,
//                        onPressed: () {
//                          (presentation as ManagePresentation).newScreen();
//                        },
//                        child: Text(_viewModel.btnNew),
//                      ),
//                    ),
//                  ],
//                ),
//                Row(
//                  mainAxisAlignment: MainAxisAlignment.spaceAround,
//                  children: <Widget>[
//                    new Flexible(
//
//                      child: new TextFormField(
//                        key: _screenNameKey,
//                        controller: screenNameController,
//                        decoration: InputDecoration(hintText: _viewModel.screenName),
//                      ),
//                    ),
//                    Padding(
//                      padding: EdgeInsets.all(dim.activityMargin),
//                      child:
//                      RaisedButton(
//                        key: _updateKey,
//                        onPressed: () {
//                          (presentation as ManagePresentation).updateScreen(screenNameController.text);
//                        },
//                        child: Text(_viewModel.btnUpdate),
//                      ),
//                    ),
//                  ],
//                ),
//                Row(
//                  mainAxisAlignment: MainAxisAlignment.spaceAround,
//                  children: <Widget>[
//                    Padding(
//                      padding: EdgeInsets.all(dim.activityMargin),
//                      child:
//                      AccentButton(
//                        key: _deleteKey,
//                        onPressed: () {
//                          (presentation as ManagePresentation).deleteScreen();
//                        },
//                        child: Text(_viewModel.btnDelete),
//                      ),
//                    ),
//                    Padding(
//                      padding: EdgeInsets.all(dim.activityMargin),
//                      child:
//                      RaisedButton(
//                        key: _exportKey,
//                        onPressed: () {
//                          (presentation as ManagePresentation).exportScreen();
//                        },
//                        child: Text(_viewModel.btnExport),
//                      ),
//                    ),
//                  ],
//                ),
//              ],
//            ),
//          ),
        ),
        floatingActionButton: FloatingActionButton.extended (
          key: _editKey,
          onPressed: () {
            (presentation as ManagePresentation).editScreen();
          },
          label: Text(_viewModel.btnEdit)
        )); //
  }

  void _menuSelectAction(int choice) {
    (presentation as ManagePresentation).importScreen();
  }
}

Container screenCard(ScreenListItem screen) {
  return Container(
    padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
    height: 220,
    width: double.maxFinite,
    child: Card(
      elevation: 5,
      child: Container(
        child: Padding(
          padding: EdgeInsets.all(7),
          child: Stack(children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: Stack(
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.only(left: 10, top: 5),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              screenName(screen),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                            ],
                          )
                        ],
                      ))
                ],
              ),
            )
          ]),
        ),
      ),
    ),
  );
}


Widget screenName(ScreenListItem screen) {
  return Align(
    alignment: Alignment.centerLeft,
    child: RichText(
      text: TextSpan(
        text: "${screen.name}",
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 20),
      ),
    ),
  );
}
