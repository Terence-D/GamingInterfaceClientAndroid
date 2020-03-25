import 'package:flutter/material.dart';
import 'package:gic_flutter/model/viewModel.dart';
import 'package:gic_flutter/theme/dimensions.dart' as dim;
import 'package:gic_flutter/views/main/mainVM.dart';

import '../accentButton.dart';
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text(_viewModel.toolbarTitle),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(dim.activityMargin),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    RaisedButton(
                      key: _newKey,
                      onPressed: () {
                        (presentation as ManagePresentation).newScreen();
                      },
                      child: Text(_viewModel.btnNew),
                    ),
                    RaisedButton(
                      key: _importKey,
                      onPressed: () {
                        (presentation as ManagePresentation).importScreen();
                      },
                      child: Text(_viewModel.btnImport),
                    ),
                  ],
                ),
                DropdownButton<ScreenListItem>(
                  key: _screenListKey,
                  value: _viewModel.selectedScreen,
                  items:
                  _viewModel.screens.map((ScreenListItem item) {
                    return new DropdownMenuItem<ScreenListItem>(
                      value: item,
                      child: new Text(
                        item.name,
                      ),
                    );
                  }).toList(),
                  onChanged: (ScreenListItem item) {
                    setState(() {
                      _viewModel.selectedScreen = item;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    new Flexible(

                      child: new TextFormField(
                        key: _screenNameKey,
                        controller: screenNameController,
                        decoration: InputDecoration(hintText: _viewModel.screenName),
                      ),
                    ),
                    RaisedButton(
                      key: _updateKey,
                      onPressed: () {
                        (presentation as ManagePresentation).updateScreen(screenNameController.text);
                      },
                      child: Text(_viewModel.btnUpdate),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    AccentButton(
                      key: _deleteKey,
                      onPressed: () {
                        (presentation as ManagePresentation).deleteScreen();
                      },
                      child: Text(_viewModel.btnDelete),
                    ),
                    RaisedButton(
                      key: _exportKey,
                      onPressed: () {
                        (presentation as ManagePresentation).exportScreen();
                      },
                      child: Text(_viewModel.btnExport),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended (
          key: _editKey,
          onPressed: () {
            (presentation as ManagePresentation).editScreen();
          },
          label: Text(_viewModel.btnEdit)
        )); //
  }
}
