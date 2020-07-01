import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gic_flutter/model/channel.dart';
import 'package:gic_flutter/model/intl/intlLauncher.dart';
import 'package:gic_flutter/model/launcherModel.dart';
import 'package:gic_flutter/ui/launcher.dart';
import 'package:gic_flutter/views/accentButton.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:showcaseview/showcaseview.dart';

class ScreenList extends StatelessWidget {

  final List<ScreenListItem> _screens;
  final IntlLauncher _translations;
  final List<TextEditingController> _screenNameController = new List<TextEditingController>();
  final LauncherState _parent;

  ScreenList(this._parent,
      this._screens,
      this._translations);

  @override
  Widget build(BuildContext context) {
    _screenNameController.clear();
    for (var i = 0; i < _screens.length; i++) {
      TextEditingController tec = new TextEditingController();
      tec.text = _screens[i].name;
      _screenNameController.add(tec);
    }

    return Expanded(
      child: ScrollablePositionedList.builder(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 48),
          itemCount: _screenNameController.length,
          itemScrollController: _parent.itemScrollController,
          itemPositionsListener: _parent.itemPositionsListener,
          itemBuilder: (context, index) {
            return screenCard(index, context);
          }),
    ); //
  }

  Container screenCard(int index, BuildContext context) {
//    GlobalKey screenCard;
//    if (index == 0)
//      screenCard = _screenListKey;
//    else
//      screenCard = new GlobalObjectKey("manageScreenList" + index.toString());
    return Container(
        height: 160,
        width: double.maxFinite,
//        key: screenCard,
        child: Card(
          elevation: 5,
          child:
          new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _screenName(index),
              screenButtons(index, context)
            ],
          ),
        )
    );
  }

  Container screenButtons(int index, BuildContext context) {
//    GlobalKey export;
//    GlobalKey update;
//    GlobalKey edit;
//    GlobalKey delete;
//    if (index == 0) {
//      export = _screenListExportKey;
//      update = _screenListUpdateKey;
//      edit = _screenListEditKey;
//      delete = _screenListDeleteKey;
//    } else {
//      export = new GlobalObjectKey("export" + index.toString());
//      update = new GlobalObjectKey("update" + index.toString());
//      edit = new GlobalObjectKey("edit" + index.toString());
//      delete = new GlobalObjectKey("delete" + index.toString());
//    }
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new AccentButton(
              child: Text(_translations.text(LauncherText.start)),
//            key: update,
              onPressed: () {
                _startGame(index);
              },
            ),
            new IconButton(
              icon: Icon(Icons.edit),
              tooltip:_translations.text(LauncherText.buttonEdit),
//            key: edit,
              onPressed: () {
                _editScreen(index);
              },
            ),
            new IconButton(
              icon: Icon(Icons.share),
              tooltip: _translations.text(LauncherText.buttonExport),
//            key: export,
              onPressed: () {
                _export(_screens[index].id);
              },
            ),
            new IconButton(
              color: Theme.of(context).errorColor,
              icon: Icon(Icons.delete_forever),
              tooltip: _translations.text(LauncherText.buttonDelete),
//            key: delete,
              onPressed: () {
                _confirmDialog(index, _screens[index].name, context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDialog(int index, String name, BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_translations.text(LauncherText.deleteConfirmTitle)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(_translations.text(LauncherText.deleteConfirm) + name),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                _deleteScreen(index);
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _screenName(int index) {
    return Expanded(
        child:
        Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _updateButton(index),
                _textField(index),
              ],
            )
        )
    );
  }

  Widget _textField(int index) {
    return new Flexible(
      child: new TextFormField(
        controller: _screenNameController[index],
        decoration: InputDecoration(
            hintText: _translations.text(LauncherText.screenName)),
      ),
    );
  }

  Widget _updateButton(int index) {
    if (index == 0) {
      return Showcase(
          key: _parent.updateKey,
          title: _translations.text(LauncherText.buttonUpdate),
          description: _translations.text(LauncherText.helpUpdate),
          child: _innerUpdateButton(index));
    } else {
      return _innerUpdateButton(index);
    }
  }

  Widget _innerUpdateButton(int index) {
    return new IconButton(
      icon: Icon(Icons.save),
      tooltip:_translations.text(LauncherText.buttonUpdate),
      onPressed: () {
        _updateScreen(index);
      },
    );
  }

  void _showMessage(String text) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
    );
  }

  _editScreen(int selectedScreenIndex) async {
    MethodChannel platform = new MethodChannel(Channel.channelView);
    try {
      await platform.invokeMethod(Channel.actionViewEdit, {"selectedScreenId": _screens[selectedScreenIndex].id});
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  _startGame(int selectedScreenIndex) async {
    String password = _parent.passwordController.text;
    String address = _parent.addressController.text;
    String port = _parent.portController.text;

    if (password == null || password.length < 6) {
      _showMessage(_translations.text(LauncherText.errorPassword));
      return;
    }
    if (port == null || int.tryParse(port) == null) {
      _showMessage(_translations.text(LauncherText.errorPort));
      return;
    }
    if (address == null || address.length == 0) {
      _showMessage(_translations.text(LauncherText.errorServerInvalid));
      return;
    }
    _parent.launcherBloc.saveMainSettings(address, port, password);

    MethodChannel platform = new MethodChannel(Channel.channelView);
    try {
      await platform.invokeMethod(Channel.actionViewStart, {"password": password, "address": address, "port":port, "selectedScreenId": _screens[selectedScreenIndex].id});
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  void _updateScreen(int index) {
    _parent.launcherBloc.updateScreenName (_screens[index].id, _screenNameController[index].text);
    _screens[index].name = _screenNameController[index].text;
    Fluttertoast.showToast(
      msg: _translations.text(LauncherText.nameUpdated),
    );
  }

  void _deleteScreen(int index) async {
    await _parent.launcherBloc.deleteScreen(_screens[index].id);
    Fluttertoast.showToast(
      msg: _translations.text(LauncherText.deleteComplete),
    );
  }

  Future<void> _export(int id) async {
    if (await Permission.storage.request().isGranted) {
      String exportPath = await FilePicker.getDirectoryPath();
      if (exportPath != null && exportPath.isNotEmpty) {
        await _parent.launcherBloc.export(exportPath, id);
        Fluttertoast.showToast(
          msg: _translations.text(LauncherText.exportComplete),
        );
      }
    }
  }
}