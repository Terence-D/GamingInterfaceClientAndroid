import 'dart:convert';
import 'dart:io';

import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gic_flutter/model/channel.dart';
import 'package:gic_flutter/model/intl/intlLauncher.dart';
import 'package:gic_flutter/model/intl/localizations.dart';
import 'package:gic_flutter/model/launcherModel.dart';
import 'package:gic_flutter/theme/theme.dart';
import 'package:gic_flutter/views/accentButton.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:showcaseview/showcaseview.dart';

import 'launcher.dart';

class VersionResponse {
  final String version;

  VersionResponse({this.version});

  factory VersionResponse.fromJson(Map<String, dynamic> json) {
    return VersionResponse(version: json['version']);
  }
}

class ScreenList extends StatelessWidget {
  final List<ScreenListItem> _screens;
  final IntlLauncher _translations;
  final List<TextEditingController> _screenNameController = new List<TextEditingController>();
  final LauncherState _parent;

  final String serverApiVersion = "2.0.0.0";

  ScreenList(this._parent, this._screens, this._translations);

  @override
  Widget build(BuildContext context) {
    _screenNameController.clear();
    for (var i = 0; i < _screens.length; i++) {
      TextEditingController tec = new TextEditingController();
      tec.text = _screens[i].name;
      debugPrint("#$i id=${_screens[i].id} name=${_screens[i].name}");
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
    return Container(
        height: 160,
        width: double.maxFinite,
        child: Card(
          elevation: 5,
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[_screenName(index), screenButtons(index, context)],
          ),
        ));
  }

  Container screenButtons(int index, BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _startButton(index, context),
            _editButton(index),
            _shareButton(index, context),
            _deleteButton(context, index),
          ],
        ),
      ),
    );
  }

  Widget _innerDeleteButton(BuildContext context, int index) {
    return new IconButton(
      color: Theme.of(context).errorColor,
      icon: Icon(Icons.delete_forever),
      tooltip: _translations.text(LauncherText.buttonDelete),
//                        key: delete,
      onPressed: () {
        _confirmDeleteDialog(index, _screens[index].name, context);
      },
    );
  }

  Widget _deleteButton(BuildContext context, int index) {
    if (index == 0) {
      return Showcase(
          key: _parent.deleteKey,
          title: _translations.text(LauncherText.buttonDelete),
          description: _translations.text(LauncherText.helpDelete),
          child: _innerDeleteButton(context, index));
    } else {
      return _innerDeleteButton(context, index);
    }
  }

  Widget _innerShareButton(int index, BuildContext context) {
    return new IconButton(
      icon: Icon(Icons.share),
      tooltip: _translations.text(LauncherText.buttonExport),
      onPressed: () {
        _export(context, _screens[index].id);
      },
    );
  }

  Widget _shareButton(int index, BuildContext context) {
    if (index == 0) {
      return Showcase(
          key: _parent.shareKey,
          title: _translations.text(LauncherText.buttonExport),
          description: _translations.text(LauncherText.helpExport),
          child: _innerShareButton(index, context));
    } else {
      return _innerShareButton(index, context);
    }
  }

  Widget _editButton(int index) {
    if (index == 0) {
      return Showcase(
          key: _parent.editKey,
          title: _translations.text(LauncherText.buttonEdit),
          description: _translations.text(LauncherText.helpEdit),
          child: _innerEditButton(index));
    } else {
      return _innerEditButton(index);
    }
  }

  IconButton _innerEditButton(int index) {
    return new IconButton(
      icon: Icon(Icons.edit),
      tooltip: _translations.text(LauncherText.buttonEdit),
      onPressed: () {
        _editScreen(index);
      },
    );
  }

  Widget _startButton(int index, BuildContext context) {
    if (index == 0) {
      return Showcase(
          key: _parent.startKey,
          title: _translations.text(LauncherText.start),
          description: _translations.text(LauncherText.helpStart),
          child: _innerStartButton(index, context));
    } else {
      return _innerStartButton(index, context);
    }
  }

  AccentButton _innerStartButton(int index, BuildContext context) {
    return new AccentButton(
      child: Text(_translations.text(LauncherText.start)),
      onPressed: () {
        _validateScreen(index, context);
      },
    );
  }

  Future<void> _confirmDeleteDialog(int index, String name, BuildContext context) async {
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
        child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _updateButton(index),
                _textField(index),
              ],
            )));
  }

  Widget _textField(int index) {
    return new Flexible(
      child: new TextFormField(
        controller: _screenNameController[index],
        decoration: InputDecoration(hintText: _translations.text(LauncherText.screenName)),
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
      tooltip: _translations.text(LauncherText.buttonUpdate),
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

  _showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(margin: EdgeInsets.only(left: 7), child: Text(_translations.text(LauncherText.loading))),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _showResizeDialog(
      BuildContext context, String optionalText, String password, String port, String address, int screenId) {
    // set up the buttons
    Widget resizeButton = FlatButton(
      child: Text("Resize"),
      onPressed: () {
        Navigator.pop(context);
        _parent.launcherBloc.resize(screenId, context);
        _validateSettings(password, port, address, context, screenId);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Continue"),
      onPressed: () {
        Navigator.pop(context);
        _validateSettings(password, port, address, context, screenId);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Resize Screen"),
      content: Text(
          "This appears to be made for a larger device - would you like to adjust the screen to fit your devices dimensions?    Note this will create a new screen with the new dimensions and launch that."),
      actions: [
        continueButton,
        resizeButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _showUpgradeDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Ok"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = RaisedButton(
        onPressed: () async {
          Email email = Email(
            body: "https://github.com/Terence-D/GamingInterfaceCommandServer/releases",
            subject: Intl.of(context).onboardEmailSubject,
          );
          await FlutterEmailSender.send(email);
        },
        child: Text(Intl.of(context).onboardSendLink, style: TextStyle(color: Colors.white)),
        color: CustomTheme.of(context).primaryColor);

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Upgrade Server"),
      content: Text(_translations.text(LauncherText.errorOutOfDate)),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<bool> _checkScreenDimensions(
      int screenId, String address, String port, String password, BuildContext context) async {
    List deviceInfo = _parent.launcherBloc.getDimensions(context);
    List screenInfo = await _parent.launcherBloc.checkScreenSize(screenId);

    bool rotate = false;
    if (deviceInfo[0] != screenInfo[0])
      rotate = true;

    //add some buffer for the check
    if ((deviceInfo[1] + 10 < screenInfo[1] || deviceInfo[2] + 10 < screenInfo[2])) {
      await _showResizeDialog(context, "Note it is recommended to rotate your device for using this screen", password,
          port, address, screenId);
      return true;
    } else if (rotate) {
      _showMessage("Note it is recommended to rotate your device for using this screen");
    }
    return false;
  }

  _validateScreen(int screenIndex, BuildContext context) async {
    int screenId = _screens[screenIndex].id;

    String password = _parent.passwordController.text;
    String address = _parent.addressController.text;
    String port = _parent.portController.text;

    if (await _checkScreenDimensions(screenId, address, port, password, context)) {
      return;
    }

    await _validateSettings(password, port, address, context, screenId);
  }

  Future _validateSettings(String password, String port, String address, BuildContext context, int screenId) async {
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

    var response;
    try {
      _showLoaderDialog(context);
      response =
          await http.post(new Uri.http(address + ":" + port, "api/version")).timeout(const Duration(seconds: 30));
    } catch (TimeoutException) {
      _showMessage(_translations.text(LauncherText.errorFirewall));
    } finally {
      Navigator.pop(context);
    }
    if (response != null && response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      VersionResponse versionResponse = VersionResponse.fromJson(jsonDecode(response.body));

      if (versionResponse.version == serverApiVersion) {
        _startGame(screenId, address, port, password);
      } else {
        _showUpgradeDialog(context);
      }
    } else {
      if (response.statusCode == 405)
        _showUpgradeDialog(context);

      _showMessage("${_translations.text(LauncherText.errorServerError)}: ${response.statusCode.toString()}");
    }
    return;
  }

  _startGame(int screenId, String address, String port, String password) async {
    _parent.launcherBloc.saveConnectionSettings(address, port, password);

    MethodChannel platform = new MethodChannel(Channel.channelView);
    try {
      await platform.invokeMethod(
          Channel.actionViewStart, {"password": password, "address": address, "port": port, "screenId": screenId});
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  void _updateScreen(int index) {
    _parent.launcherBloc.updateScreenName(_screens[index].id, _screenNameController[index].text);
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

  Future<void> _export(BuildContext context, int id) async {
    const platform = const MethodChannel(Channel.channelUtil);
    String externalPath;
    try {
      externalPath = await platform.invokeMethod(Channel.actionGetDownloadFolder);
    } on PlatformException catch (_) {
      externalPath = "";
    }

    if (await Permission.storage.request().isGranted) {
      Directory externalDirectory = Directory(externalPath);
      String exportPath = await FilesystemPicker.open(
        title: 'Save to folder',
        context: context,
        rootDirectory: externalDirectory,
        fsType: FilesystemType.folder,
        pickText: 'Save file to this folder',
      );

      //List<Directory> externalStorageDirectory = await getExternalStorageDirectories(type: StorageDirectory.downloads);
      //String exportPath =    (await getExternalStorageDirectory()).path;//externalStorageDirectory[0].path;

      if (exportPath != null && exportPath.isNotEmpty) {
        await _parent.launcherBloc.export(exportPath, id);
        Fluttertoast.showToast(
          msg: _translations.text(LauncherText.exportComplete),
        );
      }
    }
  }
}
