import 'package:flutter/cupertino.dart';
import 'package:gic_flutter/model/intl/intlAbout.dart';
import 'package:gic_flutter/model/intl/localizations.dart';
import 'package:gic_flutter/model/viewSection.dart';
import 'package:gic_flutter/views/basePage.dart';
import 'package:package_info/package_info.dart';
import 'package:sprintf/sprintf.dart';

import 'aboutVM.dart';

class AboutPresentation implements BasePresentation {
  BaseState _contract;

  AboutPresentation(BaseState contract) {
    _contract = contract;
  }

  Future<void> buildVM(BuildContext context) async {
    AboutVM _viewModel = new AboutVM();

    _viewModel.toolbarTitle = Intl.of(context).about(AboutText.toolbarTitle);
    _viewModel.emailTo = Intl.of(context).about(AboutText.emailTo);
    _viewModel.libraryTitle = Intl.of(context).about(AboutText.libraryTitle);
    _viewModel.versionText = await _buildVersion(context);

    _viewModel.legal = new ViewSection(
      Intl.of(context).about(AboutText.legalTitle),
      Intl.of(context).about(AboutText.legalText),
      Intl.of(context).about(AboutText.legalUrl),
    );

    _viewModel.server = new ViewSection(
      Intl.of(context).about(AboutText.serverTitle),
      Intl.of(context).about(AboutText.serverText),
      Intl.of(context).about(AboutText.serverUrl),
    );

    _viewModel.libraries = _buildThirdPartyLibraries(context);

    _contract.onLoadComplete(_viewModel);
  }

  Future<String> _buildVersion(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version= packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    return sprintf(Intl.of(context).about(AboutText.versionText), [version, buildNumber]);
  }

  List<ViewSection> _buildThirdPartyLibraries(BuildContext context) {
    List<ViewSection> libraries = new List<ViewSection>();

    libraries.add( new ViewSection(
      Intl.of(context).about(AboutText.cryptoTitle),
      Intl.of(context).about(AboutText.cryptoText),
      Intl.of(context).about(AboutText.cryptoUrl),
    ) );
    libraries.add( new ViewSection(
      Intl.of(context).about(AboutText.colorTitle),
      Intl.of(context).about(AboutText.colorText),
      Intl.of(context).about(AboutText.colorUrl),
    ) );
    libraries.add( new ViewSection(
      Intl.of(context).about(AboutText.permissionsTitle),
      Intl.of(context).about(AboutText.permissionsText),
      Intl.of(context).about(AboutText.permissionsUrl),
    ) );
    libraries.add( new ViewSection(
      Intl.of(context).about(AboutText.onboardingTitle),
      Intl.of(context).about(AboutText.onboardingText),
      Intl.of(context).about(AboutText.onboardingUrl),
    ) );
    libraries.add( new ViewSection(
      Intl.of(context).about(AboutText.helpTitle),
      Intl.of(context).about(AboutText.helpText),
      Intl.of(context).about(AboutText.helpUrl),
    ) );

    return libraries;
  }
}
