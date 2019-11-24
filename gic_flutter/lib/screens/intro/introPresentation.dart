import 'dart:convert';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:gic_flutter/model/intl/localizations.dart';
import 'package:gic_flutter/model/screen/Screens.dart';
import 'package:gic_flutter/screens/intro/screenListWidget.dart';
import 'package:gic_flutter/screens/intro/screenSizeWidget.dart';
import 'package:gic_flutter/theme/theme.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:toast/toast.dart';

abstract class IntroViewContract {
  void onIntroLoadCompleted(List<PageViewModel> _pages);
}

class IntroPresentation {
  IntroViewContract _contract;

  List<PageViewModel> _pages;
  List<ScreenItem> _screens = <ScreenItem>[new ScreenItem("SC"), new ScreenItem("Elite"), new ScreenItem("Truck")];
  String device = "Phone";

  IntroPresentation(IntroViewContract contract) {
    _contract = contract;    
  }

  loadPages(BuildContext context) async {
    Color primaryColor = CustomTheme.of(context).primaryColor;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    PageViewModel oldApi;

    int version = androidInfo.version.sdkInt;

    final PageDecoration decoration = new PageDecoration(
      dotsDecorator: DotsDecorator(
        activeColor: primaryColor,
      ));

    if (version < 19) { //KITKAT
      oldApi = PageViewModel(
        title: Intl.of(context).onboardOldAndroidTitle,
        body: Intl.of(context).onboardOldAndroidDesc,
        image: Icon(Icons.warning, size: 175.0, color: primaryColor),
        decoration: decoration,
      );
    }

    _pages = [
      PageViewModel(
        title: Intl.of(context).onboardIntroTitle,
        body: Intl.of(context).onboardIntroDesc,
        image: Icon(Icons.thumb_up, size: 175.0, color: primaryColor),
        decoration: decoration,
      ),
      PageViewModel(
        title: Intl.of(context).onboardAboutTitle,
        body: Intl.of(context).onboardAboutDesc,
        image: Icon(Icons.info_outline, size: 175.0, color: primaryColor),
        decoration: decoration,
      ),
      PageViewModel(
        title: Intl.of(context).onboardServerTitle,
        body: Intl.of(context).onboardServerDesc,
        image: Icon(Icons.important_devices, size: 175.0, color: primaryColor),
        decoration: decoration,
        footer: RaisedButton(
          onPressed: () async {
            Email email = Email(
              body: "https://github.com/Terence-D/GameInputCommandServer/wiki",
              subject: Intl.of(context).onboardEmailSubject,
            );
            await FlutterEmailSender.send(email);
          },
          child: Text(Intl.of(context).onboardSendLink, style: TextStyle(color: Colors.white)),
          color: primaryColor,
        ),
      ),
      PageViewModel(
        title: Intl.of(context).onboardScreenTitle,
        decoration: decoration,
        bodyWidget: SingleChildScrollView(
          child: Column(
            children: [
              Text(Intl.of(context).onboardScreenDesc),
              Text(Intl.of(context).onboardScreenDevice),
              ScreenSizeWidget(
                  (String selected) {
                    this.device = selected;
                  }
              ),
              Text(Intl.of(context).onboardScreenList),
              ScreenListWidget(_screens),
              RaisedButton(
                onPressed: () {
                  _screens.forEach((screen) =>_importScreen(device, screen, context));
                },
                child: Text(Intl.of(context).onboardImport, style: TextStyle(color: Colors.white)),
                color: primaryColor,
              )
            ],
          ),
        ) // Single child scroll view
      ),
      PageViewModel(
        title: Intl.of(context).onboardLetsGoTitle,
        body: Intl.of(context).onboardLetsGoDesc,
        image: Icon(Icons.help_outline, size: 175.0, color: primaryColor),
        decoration: decoration,
      ),
      PageViewModel(
        title: Intl.of(context).onboardSupportTitle,
        body: Intl.of(context).onboardSupportDesc,
        image: Icon(Icons.free_breakfast, size: 175.0, color: primaryColor),
        decoration: decoration,
      ),
    ];
    if (oldApi != null) {
      _pages.add(oldApi);
    }

    _contract.onIntroLoadCompleted(_pages);
  }

  _importScreen(String device, ScreenItem screen, BuildContext context) async {
    if (!screen.selected)
      return;

    Screens screens = new Screens();
    screens.loadFromJson(screen.title, device, context);

    Toast.show(Intl.of(context).onboardImportSuccess, context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }
}
