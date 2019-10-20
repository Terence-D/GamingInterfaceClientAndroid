import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:gic_flutter/model/intl/localizations.dart';
import 'package:gic_flutter/theme/theme.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroPresentation {
  List<PageViewModel> pages;

  loadPages(BuildContext context) async {
    Color accent = CustomTheme.of(context).primaryColor;
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
            Text(Intl.of(context).onboardScreenDesc),
            Text(Intl.of(context).onboardScreenDevice),
            ScreenSizeWidget(),
            Text(Intl.of(context).onboardScreenList),
            ScreenListWidget(),
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

class _Screen {
  String title;
  bool selected = false;
  _Screen(title) {
    this.title = title;
  }
}
class ScreenListWidget extends StatefulWidget {
  ScreenListWidget({Key key}) : super(key: key);

  @override
  _ScreenListWidgetState createState() => _ScreenListWidgetState();
}
class _ScreenListWidgetState extends State<ScreenListWidget> {
  List<_Screen> _screens = <_Screen>[new _Screen("SC"), new _Screen("Elite"), new _Screen("Truck")];

  @override
  Widget build(BuildContext context) {
    Color accent = CustomTheme
        .of(context)
        .primaryColor;
    return SizedBox(
      width: 200.0,
      height: 200.0,
      child: ListView(
        children: [
          Ink(
              color: _screens[0].selected ?  accent : Colors.transparent,
              child: ListTile(
                title: Text(_screens[0].title),
                onTap: () {
                  setState(() {
                    _screens[0].selected = ! _screens[0].selected;
                  });
                },
              )
          ),
          Ink(
              color: _screens[1].selected ?  accent : Colors.transparent,
              child: ListTile(
                title: Text(_screens[1].title),
                onTap: () {
                  setState(() {
                    _screens[1].selected = ! _screens[1].selected;
                  });
                },
              )
          ),
          Ink(
              color: _screens[2].selected ?  accent : Colors.transparent,
              child: ListTile(
                title: Text(_screens[2].title),
                onTap: () {
                  setState(() {
                    _screens[2].selected = ! _screens[2].selected;
                  });
                },
              )
          ),
        ],
      ),
    );
  }
}

class ScreenSizeWidget extends StatefulWidget {
  ScreenSizeWidget({Key key}) : super(key: key);
  @override
  _ScreenSizeWidgetState createState() => _ScreenSizeWidgetState();
}
class _ScreenSizeWidgetState extends State<ScreenSizeWidget> {
  List<String> dropdownItems = <String>['Phone', 'Small Tablet', 'Large Tablet'];
  String dropdownValue;
  _ScreenSizeWidgetState() {
    dropdownValue = dropdownItems[0];
  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150.0,
      height: 100.0,
      child: Center(
          child: getDropdown()
      ),
    );
  }
  DropdownButton getDropdown() {
    return DropdownButton<String>(
      value: dropdownValue,
      elevation: 16,
      underline: Container(
        height: 2,
      ),
      onChanged: (String newValue) {
        setState(() {
          dropdownValue = newValue;
        });
      },
      items: dropdownItems.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
