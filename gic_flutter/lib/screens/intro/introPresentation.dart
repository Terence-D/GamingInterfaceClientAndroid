import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:gic_flutter/model/intl/localizations.dart';
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
        body: Intl.of(context).onboardScreenDesc,
        decoration: decoration,
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
//      PageViewModel(
//        title: "Third title page",
//        body: "Text of the third page of this onboarding",
//        decoration: PageDecoration(
//          titleTextStyle: const TextStyle(
//            fontSize: 28.0,
//            fontWeight: FontWeight.w600,
//            color: Colors.red,
//          ),
//          bodyTextStyle: const TextStyle(fontSize: 22.0),
//          dotsDecorator: const DotsDecorator(
//            activeColor: Colors.red,
//            activeSize: Size.fromRadius(8),
//          ),
//          pageColor: Colors.grey[200],
//        ),
//      ),
//      PageViewModel(
//        title: "Fourth title page",
//        bodyWidget: Row(
//          mainAxisAlignment: MainAxisAlignment.center,
//          children: const [
//            Text("Click on "),
//            Icon(Icons.edit),
//            Text(" to edit a post"),
//          ],
//        ),
//        image: _buildImage(),
//      ),
    ];
    if (oldApi != null) {
      pages.add(oldApi);
      debugPrint("added");
    }

  }

  getPages() {
    return pages;
  }

  Widget _buildImage() {
    return Align(
      child: Image.network("https://cdn4.iconfinder.com/data/icons/onboarding-material-color/128/__14-512.png", height: 175.0),
      alignment: Alignment.bottomCenter,
    );

  }
}