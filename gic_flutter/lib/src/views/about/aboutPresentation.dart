import 'package:flutter/cupertino.dart';
import 'package:gic_flutter/src/backend/models/intl/intlAbout.dart';
import 'package:gic_flutter/src/backend/models/intl/localizations.dart';
import 'package:gic_flutter/src/backend/models/viewSection.dart';
import 'package:gic_flutter/src/views/basePage.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'aboutVM.dart';

class AboutPresentation implements BasePresentation {
  BaseState _contract;

  AboutPresentation(this._contract);

  Future<void> buildVM(BuildContext context) async {
    AboutVM _viewModel = AboutVM();

    _viewModel.toolbarTitle = Intl.of(context)!.about(AboutText.toolbarTitle);
    _viewModel.libraryTitle = Intl.of(context)!.about(AboutText.libraryTitle);
    _viewModel.versionText = await _buildVersion(context);
    _viewModel.appName = await _appName(context);

    _viewModel.legal = ViewSection(
      Intl.of(context)!.about(AboutText.legalTitle),
      Intl.of(context)!.about(AboutText.legalText),
      Intl.of(context)!.about(AboutText.legalUrl),
    );

    _viewModel.server = ViewSection(
      Intl.of(context)!.about(AboutText.serverTitle),
      Intl.of(context)!.about(AboutText.serverText),
      Intl.of(context)!.about(AboutText.serverUrl),
    );

    _viewModel.libraries = _buildThirdPartyLibraries(context);

    _contract.onLoadComplete(_viewModel);
  }

  Future<String> _buildVersion(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    return "${Intl.of(context)!.about(AboutText.versionText)} $version ($buildNumber)";
  }

  Future<String> _appName(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.appName;
  }

  List<ViewSection> _buildThirdPartyLibraries(BuildContext context) {
    List<ViewSection> libraries = <ViewSection>[];

    libraries.add(ViewSection(
      Intl.of(context)!.about(AboutText.oxoTitle),
      Intl.of(context)!.about(AboutText.oxoText),
      Intl.of(context)!.about(AboutText.oxoUrl),
    ));
    libraries.add(ViewSection(
      Intl.of(context)!.about(AboutText.cryptoTitle),
      Intl.of(context)!.about(AboutText.cryptoText),
      Intl.of(context)!.about(AboutText.cryptoUrl),
    ));
    libraries.add(ViewSection(
      Intl.of(context)!.about(AboutText.flutterDevTitle),
      Intl.of(context)!.about(AboutText.flutterDevText),
      Intl.of(context)!.about(AboutText.flutterDevUrl),
    ));
    libraries.add(ViewSection(
      Intl.of(context)!.about(AboutText.httpTitle),
      Intl.of(context)!.about(AboutText.httpText),
      Intl.of(context)!.about(AboutText.httpUrl),
    ));
    libraries.add(ViewSection(
      Intl.of(context)!.about(AboutText.fluttertoastTitle),
      Intl.of(context)!.about(AboutText.fluttertoastText),
      Intl.of(context)!.about(AboutText.fluttertoastUrl),
    ));
    libraries.add(ViewSection(
      Intl.of(context)!.about(AboutText.introductionScreenTitle),
      Intl.of(context)!.about(AboutText.introductionScreenText),
      Intl.of(context)!.about(AboutText.introductionScreenUrl),
    ));
    libraries.add(ViewSection(
      Intl.of(context)!.about(AboutText.flutterEmailSenderTitle),
      Intl.of(context)!.about(AboutText.flutterEmailSenderText),
      Intl.of(context)!.about(AboutText.flutterEmailSenderUrl),
    ));
    libraries.add(ViewSection(
      Intl.of(context)!.about(AboutText.flutterCommunityTitle),
      Intl.of(context)!.about(AboutText.flutterCommunityText),
      Intl.of(context)!.about(AboutText.flutterCommunityUrl),
    ));
    libraries.add(ViewSection(
      Intl.of(context)!.about(AboutText.flutterLinkifyTitle),
      Intl.of(context)!.about(AboutText.flutterLinkifyText),
      Intl.of(context)!.about(AboutText.flutterLinkifyUrl),
    ));
    libraries.add(ViewSection(
      Intl.of(context)!.about(AboutText.archiveTitle),
      Intl.of(context)!.about(AboutText.archiveText),
      Intl.of(context)!.about(AboutText.archiveUrl),
    ));
    libraries.add(ViewSection(
      Intl.of(context)!.about(AboutText.scrollablePositionedListTitle),
      Intl.of(context)!.about(AboutText.scrollablePositionedListText),
      Intl.of(context)!.about(AboutText.scrollablePositionedListUrl),
    ));
    libraries.add(ViewSection(
      Intl.of(context)!.about(AboutText.permissionHandlerTitle),
      Intl.of(context)!.about(AboutText.permissionHandlerText),
      Intl.of(context)!.about(AboutText.permissionHandlerUrl),
    ));
    libraries.add(ViewSection(
      Intl.of(context)!.about(AboutText.filePickerTitle),
      Intl.of(context)!.about(AboutText.filePickerText),
      Intl.of(context)!.about(AboutText.filePickerUrl),
    ));
    libraries.add(ViewSection(
      Intl.of(context)!.about(AboutText.showcaseviewTitle),
      Intl.of(context)!.about(AboutText.showcaseviewText),
      Intl.of(context)!.about(AboutText.showcaseviewUrl),
    ));

    return libraries;
  }
}
