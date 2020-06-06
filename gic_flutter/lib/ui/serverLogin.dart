import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gic_flutter/model/intl/intlLauncher.dart';
import 'package:gic_flutter/model/launcherModel.dart';
import 'package:gic_flutter/theme/dimensions.dart' as dim;

class ServerLogin extends StatelessWidget {

  final LauncherModel _viewModel;
  final IntlLauncher _translations;

  final TextEditingController _passwordController = new TextEditingController();
  final TextEditingController _addressController = new TextEditingController();
  final TextEditingController _portController = new TextEditingController();

  ServerLogin(this._viewModel, this._translations);

  @override
  Widget build(BuildContext context) {
    _passwordController.text = _viewModel.password;
    _portController.text = _viewModel.port;
    _addressController.text = _viewModel.address;

    return Expanded(
        child: Column(
          children: <Widget>[
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
            ]),
    );
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