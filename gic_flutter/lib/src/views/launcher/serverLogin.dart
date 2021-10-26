import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gic_flutter/src/backend/models/intl/intlLauncher.dart';
import 'package:gic_flutter/src/backend/models/launcherModel.dart';
import 'package:gic_flutter/src/theme/dimensions.dart' as dim;
import 'package:showcaseview/showcaseview.dart';

import 'launcher.dart';

class ServerLogin extends StatefulWidget {
  final LauncherModel _viewModel;
  final IntlLauncher _translations;
  final Orientation _orientation;
  final LauncherState _parent;

  const ServerLogin(
      this._parent, this._viewModel, this._translations, this._orientation);

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
      betaRow(context),
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



  Widget betaRow(BuildContext context) {
    return
      FutureBuilder(
          future: _checkVersion(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data > 30)
                return _warning();
            }
            return SizedBox.shrink();
          });
  }

  Widget _warning() {
    return ExpansionTile(
        title: Row(
          children: [
            Icon(Icons.notification_important, color: Theme.of(context).primaryColor),
            Text(
                "IMPORTANT INFORMATION"),
          ],
        ),
        children:<Widget> [
          ListTile(
              title: Text("On Android 12 you may see an erroneous message stating that GIC is using the clipboard. This is caused by the framework Flutter GIC is built with.  Flutter will be fixing it in a future release.  I am NOT reading from the clipboard.")
          )
        ]);
  }



  Future<int> _checkVersion() async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.sdkInt;
    } else
      return -1;
  }
}
