import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gic_flutter/model/intl/intlLauncher.dart';
import 'package:gic_flutter/model/launcherModel.dart';
import 'package:gic_flutter/theme/dimensions.dart' as dim;

class ServerLogin extends StatelessWidget {

  final LauncherModel _viewModel;
  final IntlLauncher _translations;
  final Orientation _orientation;
  final TextEditingController _passwordController;
  final TextEditingController _addressController;
  final TextEditingController _portController;

  ServerLogin(
      this._addressController,
      this._passwordController,
      this._portController,
      this._viewModel,
      this._translations,
      this._orientation);

  @override
  Widget build(BuildContext context) {
    _passwordController.text = _viewModel.password;
    _portController.text = _viewModel.port;
    _addressController.text = _viewModel.address;

    if (_orientation == Orientation.portrait)
      return Wrap(children: _serverInput(context));
    else
      return Expanded(
        child: Column(children: _serverInput(context))
      );
  }

  List<Widget> _serverInput(BuildContext context) {
    return <Widget>[
      bannerRow(context),
      TextFormField(
//              key: _addressKey,
        inputFormatters: [
          new BlacklistingTextInputFormatter(new RegExp('[\\ ]')),
        ],
        controller: _addressController,
        decoration: InputDecoration(hintText: _translations.text(LauncherText.address)),
      ),
      TextFormField(
//              key: _portKey,
        controller: _portController,
        decoration: InputDecoration(hintText: _translations.text(LauncherText.port)),
      ),
      TextFormField(
//              key: _passwordKey,
        controller: _passwordController,
        obscureText: true,
        decoration: InputDecoration(hintText: _translations.text(LauncherText.password)),
      ),
      Padding(
        padding: EdgeInsets.all(dim.activityMargin),
        child: Text(
            _translations.text(LauncherText.passwordWarning)),
      ),
    ];
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
}