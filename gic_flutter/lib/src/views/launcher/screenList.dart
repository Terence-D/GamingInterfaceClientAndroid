import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:gic_flutter/src/backend/models/intl/intlLauncher.dart';
import 'package:gic_flutter/src/backend/models/intl/localizations.dart';
import 'package:gic_flutter/src/backend/models/launcherModel.dart';
import 'package:gic_flutter/src/backend/models/networkModel.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/screenViewModel.dart';
import 'package:gic_flutter/src/backend/services/cryptoService.dart';
import 'package:gic_flutter/src/backend/services/networkService.dart';
import 'package:gic_flutter/src/views/accentButton.dart';
import 'package:gic_flutter/src/views/screen/screenVM.dart';
import 'package:gic_flutter/src/views/screen/screenView.dart';
import 'package:gic_flutter/src/views/screenEditor/screenEditor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:share_plus/share_plus.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:url_launcher/url_launcher.dart';

import 'launcher.dart';

class VersionResponse {
  final String version;

  VersionResponse({this.version});

  factory VersionResponse.fromJson(Map<String, dynamic> json) {
    return VersionResponse(version: json['version']);
  }
}

class ScreenList extends StatefulWidget {
  final List<ScreenListItem> _screens;
  final IntlLauncher _translations;
  final LauncherState _parent;

  ScreenList(this._parent, this._screens, this._translations);

  @override
  State<ScreenList> createState() => _ScreenListState();
}

class _ScreenListState extends State<ScreenList> {
  bool _loadingState = false;
  NetworkResponse test = NetworkResponse.Ok;
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  final List<TextEditingController> _screenNameController =
      <TextEditingController>[];

  @override
  Widget build(BuildContext context) {
    _screenNameController.clear();
    for (var i = 0; i < widget._screens.length; i++) {
      TextEditingController tec = TextEditingController();
      tec.text = widget._screens[i].name;
      _screenNameController.add(tec);
    }

    return _loadingState
        ? Center(child: CircularProgressIndicator())
        : Expanded(
            child: ScrollablePositionedList.builder(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 48),
                itemCount: _screenNameController.length,
                itemScrollController: widget._parent.itemScrollController,
                itemPositionsListener: widget._parent.itemPositionsListener,
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
            children: <Widget>[
              _screenName(index),
              screenButtons(index, context)
            ],
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

  Widget _deleteButton(BuildContext context, int index) {
    IconButton deleteButton = IconButton(
      color: Theme.of(context).errorColor,
      icon: Icon(Icons.delete_forever),
      tooltip: widget._translations.text(LauncherText.buttonDelete),
//                        key: delete,
      onPressed: () {
        _confirmDeleteDialog(index, widget._screens[index].name, context);
      },
    );

    if (index == 0) {
      return Showcase(
          key: widget._parent.deleteKey,
          title: widget._translations.text(LauncherText.buttonDelete),
          description: widget._translations.text(LauncherText.helpDelete),
          child: deleteButton);
    } else {
      return deleteButton;
    }
  }

  Widget _shareButton(int index, BuildContext context) {
    IconButton shareButton = IconButton(
      icon: Icon(Icons.share),
      tooltip: widget._translations.text(LauncherText.buttonExport),
      onPressed: () {
        _export(context, widget._screens[index].id);
      },
    );
    if (index == 0) {
      return Showcase(
          key: widget._parent.shareKey,
          title: widget._translations.text(LauncherText.buttonExport),
          description: widget._translations.text(LauncherText.helpExport),
          child: shareButton);
    } else {
      return shareButton;
    }
  }

  Widget _editButton(int index, BuildContext context) {
    IconButton editButton = IconButton(
      icon: Icon(Icons.edit),
      tooltip: widget._translations.text(LauncherText.buttonEdit),
      onPressed: () {
        _editScreen(index, context);
      },
    );

    if (index == 0) {
      return Showcase(
          key: widget._parent.editKey,
          title: widget._translations.text(LauncherText.buttonEdit),
          description: widget._translations.text(LauncherText.helpEdit),
          child: editButton);
    } else {
      return editButton;
    }
  }

  Widget _startButton(int index, BuildContext context) {
    AccentButton startButton = AccentButton(
      child: Text(widget._translations.text(LauncherText.start)),
      onPressed: () {
        _validateScreen(index, context);
      },
    );

    if (index == 0) {
      return Showcase(
          key: widget._parent.startKey,
          title: widget._translations.text(LauncherText.start),
          description: widget._translations.text(LauncherText.helpStart),
          child: startButton);
    } else {
      return startButton;
    }
  }

  Future<void> _confirmDeleteDialog(
      int index, String name, BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(widget._translations.text(LauncherText.deleteConfirmTitle)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(widget._translations.text(LauncherText.deleteConfirm) +
                    name),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(widget._parent.translation.text(LauncherText.yes)),
              onPressed: () {
                _deleteScreen(index);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(widget._parent.translation.text(LauncherText.no)),
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
        decoration: InputDecoration(
            hintText: widget._translations.text(LauncherText.screenName)),
      ),
    );
  }

  Widget _updateButton(int index) {
    if (index == 0) {
      return Showcase(
          key: widget._parent.updateKey,
          title: widget._translations.text(LauncherText.buttonUpdate),
          description: widget._translations.text(LauncherText.helpUpdate),
          child: _innerUpdateButton(index));
    } else {
      return _innerUpdateButton(index);
    }
  }

  Widget _innerUpdateButton(int index) {
    return IconButton(
      icon: Icon(Icons.save),
      tooltip: widget._translations.text(LauncherText.buttonUpdate),
      onPressed: () {
        _updateScreen(index);
      },
    );
  }

  void _showMessage(String text) {
    var snackBar = SnackBar(content: Text(text));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  _editScreen(int selectedScreenIndex, BuildContext context) async {
    int screenId = widget._screens[selectedScreenIndex].id;

    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ScreenEditor(screenId: screenId)));
  }

  _showResizeDialog(BuildContext context, String optionalText,
      NetworkModel networkModel, int screenId) {
    // set up the buttons
    Widget resizeButton = TextButton(
      child: Text(widget._parent.translation.text(LauncherText.resize)),
      onPressed: () {
        Navigator.pop(context);
        widget._parent.launcherBloc.resize(screenId, context);
        _validateSettings(networkModel, context, screenId);
      },
    );
    Widget continueButton = TextButton(
      child: Text(widget._parent.translation.text(LauncherText.cont)),
      onPressed: () {
        Navigator.pop(context);
        _validateSettings(networkModel, context, screenId);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(widget._parent.translation.text(LauncherText.resizeScreen)),
      content:
          Text(widget._parent.translation.text(LauncherText.resizeScreenText)),
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
    Widget cancelButton = TextButton(
      child: Text(widget._parent.translation.text(LauncherText.ok)),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = ElevatedButton(
        onPressed: () async {
          Email email = Email(
            body:
                "https://github.com/Terence-D/GamingInterfaceCommandServer/releases",
            subject: Intl.of(context).onboardEmailSubject,
          );
          await FlutterEmailSender.send(email);
        },
        child: Text(Intl.of(context).onboardSendLink,
            style: TextStyle(color: Colors.white)));

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(widget._parent.translation.text(LauncherText.upgradeServer)),
      content: Text(widget._translations.text(LauncherText.errorOutOfDate)),
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
      int screenId, NetworkModel networkModel, BuildContext context) async {
    List deviceInfo = widget._parent.launcherBloc.getDimensions(context);
    List screenInfo =
        await widget._parent.launcherBloc.checkScreenSize(screenId);

    bool rotate = false;
    if (deviceInfo[0] != screenInfo[0]) {
      rotate = true;
    }

    bool tooBig = false;
    if (rotate &&
        (deviceInfo[2] + 10 < screenInfo[1] ||
            deviceInfo[2] + 10 < screenInfo[1])) {
      tooBig = true;
    } else if (deviceInfo[1] + 10 < screenInfo[1] ||
        deviceInfo[2] + 10 < screenInfo[2]) {
      tooBig = true;
    }

    //add some buffer for the check
    if (tooBig) {
      await _showResizeDialog(
          context,
          widget._parent.translation.text(LauncherText.recommendResize),
          networkModel,
          screenId);
      return true;
    } else if (rotate) {
      _showMessage(
          widget._parent.translation.text(LauncherText.recommendResize));
    }
    return false;
  }

  _validateScreen(int screenIndex, BuildContext context) async {
    int screenId = widget._screens[screenIndex].id;

    NetworkModel networkModel = NetworkModel();
    await networkModel.init(
        widget._parent.passwordController.text,
        widget._parent.addressController.text,
        widget._parent.portController.text);

    if (await _checkScreenDimensions(screenId, networkModel, context)) {
      return;
    }

    await _validateSettings(networkModel, context, screenId);
  }

  Future _validateSettings(
      NetworkModel networkModel, BuildContext context, int screenId) async {
    if (networkModel.password == null ||
        CryptoService.decrypt(networkModel.password).length < 6) {
      _showMessage(widget._translations.text(LauncherText.errorPassword));
      return;
    }
    if (networkModel.port == null || int.tryParse(networkModel.port) == null) {
      _showMessage(widget._translations.text(LauncherText.errorPort));
      return;
    }
    if (networkModel.address == null || networkModel.address.isEmpty) {
      _showMessage(widget._translations.text(LauncherText.errorServerInvalid));
      return;
    }

    //check network version now
    Future<NetworkResponse> response =
        NetworkService.checkVersion(networkModel);
    _showLoadingDialog(context, _keyLoader); //invoking login

    NetworkResponse test = await response;

    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    switch (test) {
      case NetworkResponse.Ok:
        _startGame(context, screenId, networkModel);
        break;
      case NetworkResponse.OutOfDate:
        _showUpgradeDialog(context);
        break;
      case NetworkResponse.Error:
        _showServerErrorDialog(context);
        break;
      case NetworkResponse.Unauthorized:
        _showMessage(
            "${widget._translations.text(LauncherText.errorUnauthorized)}");
        break;
    }
    setState(() {
      _loadingState = false;
    });
  }

  _showLoadingDialog(BuildContext context, GlobalKey key) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(key: key, children: <Widget>[
                Center(
                  child: Column(children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 10,
                    ),
                    Text(widget._translations.text(LauncherText.connecting))
                  ]),
                )
              ]));
        });
  }

  _startGame(
      BuildContext context, int screenId, NetworkModel networkModel) async {
    widget._parent.launcherBloc.saveConnectionSettings(networkModel);

    ScreenViewModel screen =
        await widget._parent.launcherBloc.loadScreen(screenId);

    ScreenVM viewModel = ScreenVM(
        screen,
        networkModel,
        widget._parent.launcherBloc.getSound(),
        widget._parent.launcherBloc.getVibration(),
        widget._parent.launcherBloc.getKeepScreenOn());
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ScreenViewStatefulWrapper(viewModel: viewModel)));
  }

  void _updateScreen(int index) {
    widget._parent.launcherBloc.updateScreenName(
        widget._screens[index].id, _screenNameController[index].text);
    widget._screens[index].name = _screenNameController[index].text;
    var snackBar = SnackBar(content: Text(widget._translations.text(LauncherText.nameUpdated)));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _deleteScreen(int index) async {
    int deleteResponse = await widget._parent.launcherBloc
        .deleteScreen(widget._screens[index].id);
    if (deleteResponse >= 0) {
      var snackBar = SnackBar(content: Text(widget._translations.text(LauncherText.deleteComplete)));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      var snackBar = SnackBar(content: Text(widget._translations.text(LauncherText.deleteError)));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> _export(BuildContext context, int id) async {
    String path;

    if (Platform.isIOS) {
      Directory iosPath = await getApplicationDocumentsDirectory();
      path = iosPath.path;
    } else {
      Directory exportDirectory = await getApplicationDocumentsDirectory();
      path = exportDirectory.path;
    }

    if (path != null) {
      if (await Permission.storage.request().isGranted) {
        String result = await widget._parent.launcherBloc.export(path, id);
        if (result != null) await Share.shareFiles(["$result.zip"]);
      }
    }
  }

  void _showServerErrorDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(widget._parent.translation.text(LauncherText.ok)),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget downloadButton = ElevatedButton(
        onPressed: () async {
          Email email = Email(
            body:
                "https://github.com/Terence-D/GamingInterfaceCommandServer/releases",
            subject: Intl.of(context).onboardEmailSubject,
          );
          await FlutterEmailSender.send(email);
        },
        child: Text(widget._parent.translation.text(LauncherText.sendDownload),
            style: TextStyle(color: Colors.white)));
    Widget tipsButton = ElevatedButton(
        onPressed: () async {
          String url =
              "https://github.com/Terence-D/GamingInterfaceCommandServer/wiki#Notes";
          if (await canLaunch(url)) {
            await launch(url);
          } else {
            throw 'Could not launch $url';
          }
        },
        child: Text(widget._parent.translation.text(LauncherText.sendTips)));

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(widget._parent.translation.text(LauncherText.serverError)),
      content: Text(widget._translations.text(LauncherText.serverErrorDetails)),
      actions: [cancelButton, downloadButton, tipsButton],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
