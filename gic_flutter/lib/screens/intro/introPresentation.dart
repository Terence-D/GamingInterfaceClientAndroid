import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:gic_flutter/model/intl/localizations.dart';
import 'package:gic_flutter/screens/intro/intro.dart';
import 'package:gic_flutter/theme/theme.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroPresentation {
  List<PageViewModel> pages;

  loadPages(BuildContext context) async {
    Color accent = CustomTheme
        .of(context)
        .accentColor;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    PageViewModel oldApi;

    int version = androidInfo.version.sdkInt;

    final PageDecoration decoration = new PageDecoration(
        dotsDecorator: DotsDecorator(
          activeColor: accent,
        ));

    if (version < 19) { //KITKAT
      oldApi = PageViewModel(
        title: Intl.of(context).onboardOldAndroidTitle,
        body: Intl.of(context).onboardOldAndroidDesc,
        image: Icon(Icons.warning, size: 175.0, color: accent),
        decoration: decoration,
      );
    }

    pages = [
      PageViewModel(
        title: Intl.of(context).onboardIntroTitle,
        body: Intl.of(context).onboardIntroDesc,
        image: Icon(Icons.thumb_up, size: 175.0, color: accent),
        decoration: decoration,
      ),
      PageViewModel(
        title: Intl.of(context).onboardAboutTitle,
        body: Intl.of(context).onboardAboutDesc,
        image: Icon(Icons.info_outline, size: 175.0, color: accent),
        decoration: decoration,
      ),
      PageViewModel(
        title: Intl.of(context).onboardServerTitle,
        body: Intl.of(context).onboardServerDesc,
        image: Icon(Icons.important_devices, size: 175.0, color: accent),
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
          color: accent,
        ),
      ),
      PageViewModel(
        title: Intl.of(context).onboardScreenTitle,
        decoration: decoration,
        bodyWidget: Column(
          children: [
            ScreenSizeWidget(),
            ScreenList(),
            Text(Intl.of(context).onboardScreenDesc)
          ],
        )
      ),
      PageViewModel(
        title: Intl.of(context).onboardLetsGoTitle,
        body: Intl.of(context).onboardLetsGoDesc,
        image: Icon(Icons.help_outline, size: 175.0, color: accent),
        decoration: decoration,
      ),
      PageViewModel(
        title: Intl.of(context).onboardSupportTitle,
        body: Intl.of(context).onboardSupportDesc,
        image: Icon(Icons.free_breakfast, size: 175.0, color: accent),
        decoration: decoration,
      ),
    ];
    if (oldApi != null) {
      pages.add(oldApi);
      debugPrint("added");
    }

  }

  getPages() {
    return pages;
  }
}