import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gic_flutter/src/backend/models/intl/intlLauncher.dart';
import 'package:gic_flutter/src/backend/models/launcherModel.dart';
import 'package:gic_flutter/src/theme/dimensions.dart' as dim;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

import 'launcher.dart';

class ServerLogin extends StatefulWidget {
  final LauncherModel _viewModel;
  final IntlLauncher _translations;
  final Orientation _orientation;
  final LauncherState _parent;
  final int _length;

  const ServerLogin(
      this._parent, this._viewModel, this._translations, this._orientation, this._length);

  @override
  State<StatefulWidget> createState() =>
      _ServerLoginState(_parent, _viewModel, _translations, _orientation);
}

class _ServerLoginState extends State<ServerLogin> {
  final LauncherModel _viewModel;
  final IntlLauncher _translations;
  final Orientation _orientation;
  final LauncherState _parent;

  _ServerLoginState(
      this._parent, this._viewModel, this._translations, this._orientation);

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () => showFiveFourWarning(context));

    if (_orientation == Orientation.portrait) {
      return SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _serverInput(context)));
    } else {
      return Expanded(
          child: SingleChildScrollView(
              child: Column(children: _serverInput(context))));
    }
  }

  List<Widget> _serverInput(BuildContext context) {
    return <Widget>[
      bannerRow(context),
      _warning(),
      _noScreenWarning(),
      _addressTextWidget(),
      _portTextWidget(),
      _passwordTextWidget(),
      Padding(
        padding: EdgeInsets.all(dim.activityMargin),
        child: Text(_translations.text(LauncherText.passwordWarning)),
      ),
    ];
  }

  Widget _passwordTextWidget() {
    return Showcase(
        key: _parent.passwordKey,
        title: _translations.text(LauncherText.password),
        description: _translations.text(LauncherText.helpPassword),
        child:TextFormField(
      controller: _parent.passwordController,
      obscureText: true,
      decoration:
          InputDecoration(hintText: _translations.text(LauncherText.password)),
    ));
  }

  Widget _portTextWidget() {
    return Showcase(
        key: _parent.portKey,
        title: _translations.text(LauncherText.port),
        description: _translations.text(LauncherText.helpPort),
        child: TextFormField(
          controller: _parent.portController,
          decoration:
              InputDecoration(hintText: _translations.text(LauncherText.port)),
        ));
  }

  Widget _addressTextWidget() {
    return Showcase(
        key: _parent.addressKey,
        title: _translations.text(LauncherText.address),
        description: _translations.text(LauncherText.helpIpAddress),
        child: TextFormField(
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp('[\\ ]')),
          ],
          controller: _parent.addressController,
          decoration: InputDecoration(
              hintText: _translations.text(LauncherText.address)),
        ));
  }

  Row bannerRow(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Visibility(
        visible: _viewModel.donate,
        child: Icon(
          Icons.free_breakfast,
          color: Colors.green,
          size: 30.0,
        ),
      ),
      Visibility(
        visible: _viewModel.donateStar,
        child: Icon(
          Icons.star,
          color: Colors.yellow,
          size: 30.0,
        ),
      ),
    ]);
  }


  Widget _warning() {
    return
      FutureBuilder(
          future: _checkVersion(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data as int > 30)
                return ExpansionTile(
                    title: Row(
                      children: [
                        Icon(Icons.notification_important, color: Theme.of(context).primaryColor),
                        Text(
                            _translations.text(LauncherText.warningTitle)),
                      ],
                    ),
                    children:<Widget> [
                      ListTile(
                          title: Text(_translations.text(LauncherText.warningText))
                      )
                    ]);
            }
            return SizedBox.shrink();
          });
  }

  Widget _noScreenWarning() {
    if (widget._length == 1 && _viewModel.screens[0].name == "New Screen 0")
      return ExpansionTile(
          initiallyExpanded: true,
          title: Row(
            children: [
              Icon(Icons.notification_important, color: Theme.of(context).primaryColor),
              Text(
                  _translations.text(LauncherText.emptyWarningTitle)),
            ],
          ),
          children:<Widget> [
            ListTile(
                title: Text( _translations.text(LauncherText.emptyWarningText))
            )
          ]);
    else
      return SizedBox.shrink();
  }

  Future<int> _checkVersion() async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.sdkInt;
    } else
      return -1;
  }

  final fiveFourWarning= 'five_four_first_loaded_warning';

  showFiveFourWarning(BuildContext context) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? isFirstLoaded = prefs.getBool(fiveFourWarning);
      if (isFirstLoaded == null) {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: new Text("Warning"),
              content: new Text("I had to make signficant 'under the hood' changes - although I've tested on my own devices that it works, if you run into problems please let me know by using the Feedback menu option.  Thank you for your support and understanding."),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                new ElevatedButton(
                  child: new Text("Dismiss"),
                  onPressed: () {
                    // Close the dialog
                    Navigator.of(context).pop();
                    prefs.setBool(fiveFourWarning, false);
                  },
                ),
              ],
            );
          },
        );
      }
    }
}
