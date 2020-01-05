import 'package:flutter/cupertino.dart';
import 'package:gic_flutter/model/intl/IntlAbout.dart';
import 'package:gic_flutter/model/intl/localizations.dart';
import 'package:package_info/package_info.dart';
import 'package:sprintf/sprintf.dart';

import 'AboutVM.dart';

abstract class AboutViewContract {
  void onLoadComplete(AboutVM viewModel);
}

class AboutPresentation {
  AboutViewContract _contract;

  AboutPresentation(AboutViewContract contract) {
    _contract = contract;
  }

  Future<void> buildVM(BuildContext context) async {
    AboutVM _viewModel = new AboutVM();

    _viewModel.toolbarTitle = Intl.of(context).about(AboutText.toolbarTitle);
    _viewModel.emailTitle = Intl.of(context).about(AboutText.emailTitle);
    _viewModel.emailTo = Intl.of(context).about(AboutText.emailTo);
    _viewModel.libraryTitle = Intl.of(context).about(AboutText.libraryTitle);

    _viewModel.legal = new AboutModel(
      Intl.of(context).about(AboutText.legalTitle),
      Intl.of(context).about(AboutText.legalText),
      Intl.of(context).about(AboutText.legalUrl),
    );

    _viewModel.server = new AboutModel(
      Intl.of(context).about(AboutText.serverTitle),
      Intl.of(context).about(AboutText.serverText),
      Intl.of(context).about(AboutText.serverUrl),
    );

    _viewModel.versionText = await _buildVersion(context);

    _contract.onLoadComplete(_viewModel);

  }

  Future<String> _buildVersion(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version= packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    return sprintf(Intl.of(context).about(AboutText.versionText), [version, buildNumber]);
  }
}
