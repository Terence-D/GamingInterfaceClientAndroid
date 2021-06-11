import 'package:gic_flutter/src/backend/models/networkModel.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/screenViewModel.dart';
import 'dart:io';

import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gic_flutter/src/backend/models/channel.dart';
import 'package:gic_flutter/src/backend/models/intl/intlLauncher.dart';
import 'package:gic_flutter/src/backend/models/launcherModel.dart';
import 'package:gic_flutter/src/views/accentButton.dart';
import 'package:gic_flutter/src/views/screen/screenView.dart';
import 'package:gic_flutter/src/views/screenEditor/screenEditor.dart';
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
  final List<TextEditingController> _screenNameController = <TextEditingController>[];
  final LauncherState _parent;

  ScreenList(this._parent, this._screens, this._translations);

  @override
  Widget build(BuildContext context) {
    _screenNameController.clear();
    for (var i = 0; i < _screens.length; i++) {
      TextEditingController tec = TextEditingController();
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
    return Container(
        height: 160,
        width: double.maxFinite,
        child: Card(
          elevation: 5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[_screenName(index), screenButtons(index, context)],
          ),
        ));
  }

  Container screenButtons(int index, BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _startButton(index, context),
            _editButton(index, context),
            _shareButton(index, context),
            _deleteButton(context, index),
          ],
        ),
      ),
    );
  }

  Widget _innerDeleteButton(BuildContext context, int index) {
    return IconButton(
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
    return IconButton(
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

  Widget _editButton(int index, BuildContext context) {
    if (index == 0) {
      return Showcase(
          key: _parent.editKey,
          title: _translations.text(LauncherText.buttonEdit),
          description: _translations.text(LauncherText.helpEdit),
          child: _innerEditButton(index, context));
    } else {
      return _innerEditButton(index, context);
    }
  }

  IconButton _innerEditButton(int index, BuildContext context) {
    return IconButton(
      icon: Icon(Icons.edit),
      tooltip: _translations.text(LauncherText.buttonEdit),
      onPressed: () {
        _editScreen(index, context);
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
    return AccentButton(
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
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                _deleteScreen(index);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
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
    return Flexible(
      child: TextFormField(
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
    return IconButton(
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

  _editScreen(int selectedScreenIndex, BuildContext context) async {
    int screenId = _screens[selectedScreenIndex].id;

    await Navigator.push(context, MaterialPageRoute(builder: (context) =>
        ScreenEditor(screenId: screenId)));

    // MethodChannel platform = new MethodChannel(Channel.channelView);
    // try {
    //   await platform.invokeMethod(Channel.actionViewEdit, {"selectedScreenId": _screens[selectedScreenIndex].id});
    // } on PlatformException catch (e) {
    //   print(e.message);
    // }
  }

  // _showLoaderDialog(BuildContext context) {
  //   AlertDialog alert = AlertDialog(
  //     content: Row(
  //       children: [
  //         CircularProgressIndicator(),
  //         Container(margin: EdgeInsets.only(left: 7), child: Text(_translations.text(LauncherText.loading))),
  //       ],
  //     ),
  //   );
  //   showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (BuildContext context) {
  //       return alert;
  //     },
  //   );
  // }

  _showResizeDialog(BuildContext context, String optionalText, NetworkModel networkModel, int screenId) {
    // set up the buttons
    Widget resizeButton = TextButton(
      child: Text("Resize"),
      onPressed: () {
        Navigator.pop(context);
        _parent.launcherBloc.resize(screenId, context);
        _validateSettings(networkModel, context, screenId);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Continue"),
      onPressed: () {
        Navigator.pop(context);
        _validateSettings(networkModel, context, screenId);
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

  // _showUpgradeDialog(BuildContext context) {
  //   // set up the buttons
  //   Widget cancelButton = FlatButton(
  //     child: Text("Ok"),
  //     onPressed: () {
  //       Navigator.pop(context);
  //     },
  //   );
  //   Widget continueButton = RaisedButton(
  //       onPressed: () async {
  //         Email email = Email(
  //           body: "https://github.com/Terence-D/GamingInterfaceCommandServer/releases",
  //           subject: Intl.of(context).onboardEmailSubject,
  //         );
  //         await FlutterEmailSender.send(email);
  //       },
  //       child: Text(Intl.of(context).onboardSendLink, style: TextStyle(color: Colors.white)),
  //       color: CustomTheme.of(context).primaryColor);
  //
  //   // set up the AlertDialog
  //   AlertDialog alert = AlertDialog(
  //     title: Text("Upgrade Server"),
  //     content: Text(_translations.text(LauncherText.errorOutOfDate)),
  //     actions: [
  //       cancelButton,
  //       continueButton,
  //     ],
  //   );
  //
  //   // show the dialog
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return alert;
  //     },
  //   );
  // }

  Future<bool> _checkScreenDimensions(int screenId, NetworkModel networkModel, BuildContext context) async {
    List deviceInfo = _parent.launcherBloc.getDimensions(context);
    List screenInfo = await _parent.launcherBloc.checkScreenSize(screenId);

    bool rotate = false;
    if (deviceInfo[0] != screenInfo[0]) {
      rotate = true;
    }

    //add some buffer for the check
    if ((deviceInfo[1] + 10 < screenInfo[1] || deviceInfo[2] + 10 < screenInfo[2])) {
      await _showResizeDialog(context, "Note it is recommended to rotate your device for using this screen", networkModel, screenId);
      return true;
    } else if (rotate) {
      _showMessage("Note it is recommended to rotate your device for using this screen");
    }
    return false;
  }

  _validateScreen(int screenIndex, BuildContext context) async {
    int screenId = _screens[screenIndex].id;

    NetworkModel networkModel = NetworkModel();
    await networkModel.init(_parent.passwordController.text, _parent.addressController.text,  _parent.portController.text);

    if (await _checkScreenDimensions(screenId, networkModel, context)) {
      return;
    }

    await _validateSettings(networkModel, context, screenId);
  }

  Future _validateSettings(NetworkModel networkModel, BuildContext context, int screenId) async {
    // if (networkModel.password == null || networkModel.password.length < 6) {
    //   _showMessage(_translations.text(LauncherText.errorPassword));
    //   return;
    // }
    // if (networkModel.port == null || int.tryParse(networkModel.port) == null) {
    //   _showMessage(_translations.text(LauncherText.errorPort));
    //   return;
    // }
    // if (networkModel.address == null || networkModel.address.length == 0) {
    //   _showMessage(_translations.text(LauncherText.errorServerInvalid));
    //   return;
    // }
    //
    // //check network version now
    // Future<NetworkResponse> response = NetworkService.checkVersion(networkModel);
    //
    // NetworkResponse test = await response;
    //
    // switch (test) {
    //   case NetworkResponse.Ok:
        _startGame(context, screenId, networkModel);
    //     break;
    //   case NetworkResponse.OutOfDate:
    //     _showUpgradeDialog(context);
    //     break;
    //   case NetworkResponse.Error:
    //     _showMessage("${_translations.text(LauncherText.errorServerError)}");
    //     break;
    // }
  }

  _startGame(BuildContext context, int screenId, NetworkModel networkModel) async {
    _parent.launcherBloc.saveConnectionSettings(networkModel);

    ScreenViewModel screen = _parent.launcherBloc.loadScreen(screenId);

    await Navigator.push(context, MaterialPageRoute(builder: (context) =>
        ScreenView(screen: screen, networkModel: networkModel)));
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
    await Fluttertoast.showToast(
      msg: _translations.text(LauncherText.deleteComplete),
    );
  }

  Future<void> _export(BuildContext context, int id) async {
    const platform = MethodChannel(Channel.channelUtil);
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

      if (exportPath != null && exportPath.isNotEmpty) {
        await _parent.launcherBloc.export(exportPath, id);
        await Fluttertoast.showToast(
          msg: _translations.text(LauncherText.exportComplete),
        );
      }
    }
  }
}
