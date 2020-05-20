import 'package:flutter/material.dart';
import 'package:gic_flutter/model/viewModel.dart';

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

  GlobalKey _newKey = GlobalObjectKey("manageNew");
  GlobalKey _screenListKey = GlobalObjectKey("manageScreenList");

  List<TextEditingController> screenNameController = new List<TextEditingController>();

  @override
  void initState() {
    presentation = new ManagePresentation(this);
    super.initState();
  }

  @override
  void onLoadComplete(ViewModel viewModel) {
    setState(() {
      this._viewModel = viewModel;
      screenNameController = new List<TextEditingController>();
      for (var i = 0; i < _viewModel.screens.length; i++) {
        TextEditingController tec = new TextEditingController();
        tec.text = _viewModel.screens[i].name;
        screenNameController.add(tec);
      }
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
                  _loadHelp();
                }),
            // overflow menu
            PopupMenuButton<int>(
                onSelected: _menuSelectAction,
                itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<int>>[
                  PopupMenuItem<int>(
                      value: 0,
                      child: Text(_viewModel.btnImport)
                  )
                ]
            )
          ],
        ),
        body: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                    key: _screenListKey,
                    itemCount: screenNameController.length,
                    itemBuilder: (context, index) {
                      return screenCard(index);
                    }),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
            key: _newKey,
            onPressed: () {
              (presentation as ManagePresentation).newScreen();
            },
            label: Text(_viewModel.btnNew)
        )
    ); //
  }

  void _menuSelectAction(int choice) {
    (presentation as ManagePresentation).importScreen();
  }

  Container screenCard(int index) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
      height: 160,
      width: double.maxFinite,
      child: Card(
        elevation: 5,
        child:
        new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              screenName(index),
              screenButtons(index)
            ],
          ),
      )
    );
  }

  Container screenButtons(int index) {
    return Container(
      child: new ButtonBar(
        children: <Widget>[
          new FlatButton(
            child: Text(_viewModel.btnUpdate),
            onPressed: () {
              (presentation as ManagePresentation).updateScreenName(index, screenNameController[index].text);
            },
          ),
          new FlatButton(
            child: Text(_viewModel.btnEdit),
            onPressed: () {
              (presentation as ManagePresentation).editScreen(index);
            },
          ),
          new FlatButton(
            child: Text(_viewModel.btnExport),
            onPressed: () {
              (presentation as ManagePresentation).exportScreen(index);
            },
          ),
          new FlatButton(
            color: Theme.of(context).errorColor,
            child: Text(_viewModel.btnDelete),
            onPressed: () {
              (presentation as ManagePresentation).deleteScreen(index);
            },
          ),
        ],
      ),
    );
  }

  Widget screenName(int index) {
    return
      Expanded(
        child:
      Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              new Flexible(
               child: new TextFormField(
                 controller: screenNameController[index],
                 decoration: InputDecoration(hintText: _viewModel.screenName),
               ),
              ),
            ],
          )
    )
      );
    }

  void _loadHelp() {}
}