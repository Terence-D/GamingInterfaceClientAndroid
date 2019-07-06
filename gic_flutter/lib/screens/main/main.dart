import 'package:flutter/material.dart';
import 'package:gic_flutter/model/channel.dart';
import 'package:gic_flutter/services/setting/settingRepository.dart';
import 'package:gic_flutter/theme/dimensions.dart' as dim;
import 'dart:async';
import 'package:flutter/services.dart';

class MainScreen extends StatefulWidget {
  final String title = "Gaming Interface Client";
  SettingRepository _settingRepo;

  MainScreen(SettingRepository settingRepo, {Key key}) : super(key: key) {
    _settingRepo = settingRepo;
  }

  @override
  _MainScreenState createState() => _MainScreenState(_settingRepo);
}

class _MainScreenState extends State<MainScreen> {
  String password;
  String address;
  String port;

  _MainScreenState(SettingRepository settingRepo) {
    getPreferences(settingRepo);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.apps),
          title: Text(widget.title),
          actions: <Widget>[
            // action button
            IconButton(icon: Icon(Icons.help_outline), onPressed: () {}),
            // overflow menu
            PopupMenuButton<MenuOptions>(
              onSelected: _select,
              itemBuilder: (BuildContext context) {
                return choices.map((MenuOptions choice) {
                  return PopupMenuItem<MenuOptions>(
                    value: choice,
                    child: Text(choice.title),
                  );
                }).toList();
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              margin: EdgeInsets.all(dim.activityMargin),
              child: Column(
                children: <Widget>[
                  Text(
                    'GIC',
                    style: Theme.of(context).textTheme.title,
                  ),
                  TextFormField(
                    initialValue: address,
                    decoration: InputDecoration(hintText: "Address"),
                  ),
                  TextFormField(
                    initialValue: port,
                    decoration: InputDecoration(
                      hintText: "Port",
                    ),
                  ),
                  TextFormField(
                    obscureText: true,
                    initialValue: password,
                    decoration: InputDecoration(
                      hintText: "Password",
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(dim.activityMargin),
                    child: Text(
                      'Warning - do NOT use an existing password that you use ANYWHERE else',
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      DropdownButton<String>(
                        items: <String>[
                          'Screen A',
                          'Screen B',
                          'Screen C',
                          'Screen D'
                        ].map((String value) {
                          return new DropdownMenuItem<String>(
                            value: value,
                            child: new Text(value),
                          );
                        }).toList(),
                        onChanged: (_) {},
                      ),
                      RaisedButton(
                        onPressed: () {
                          _getNewActivity(Channel.viewAbout);
                        },
                        child: Text('Screen Manager'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            _getNewActivity(Channel.viewAbout);
          },
          label: Text('Start'),
        )); //
  }

  _getNewActivity(String channel) async {
    MethodChannel platform = new MethodChannel(channel);
    try {
      await platform.invokeMethod('startNewActivity');
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  //action to take when picking from the menu
  void _select(MenuOptions choice) {
    if (choice == choices[2]) _getNewActivity(Channel.viewAbout);
  }

  void getPreferences(SettingRepository settingRepo) async {
    await settingRepo.getPassword();
    address = settingRepo.getAddress();
    port = settingRepo.getPort();
  }
}

class MenuOptions {
  const MenuOptions({this.title, this.icon});

  final String title;
  final IconData icon;
}

const List<MenuOptions> choices = const <MenuOptions>[
  const MenuOptions(title: 'Toggle Theme', icon: Icons.color_lens),
  const MenuOptions(title: 'Show Intro', icon: Icons.thumb_up),
  const MenuOptions(title: 'About', icon: Icons.info_outline),
];
