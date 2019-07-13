import 'package:flutter/material.dart';
import 'package:gic_flutter/model/channel.dart';
import 'package:gic_flutter/screens/main/mainPresentation.dart';
import 'package:gic_flutter/services/setting/settingRepository.dart';
import 'package:gic_flutter/theme/dimensions.dart' as dim;

class MainScreen extends StatefulWidget {
  final SettingRepository repository;

  MainScreen(this.repository, {Key key}) : super(key: key) {}

  @override
  MainScreenState createState() {
    return MainScreenState();
  }
}

class MainScreenState extends State<MainScreen> {
  MainPresentation presentation;
  TextEditingController passwordController = TextEditingController();

  MainScreenState() {}

  @override
  void dispose() {
    super.dispose();
    passwordController.dispose();
  }

  @override
  void initState() {
    super.initState();

    presentation = new MainPresentation(this, widget.repository);

    passwordController.addListener(passwordListener());
    presentation.loadSettings().then((_) {
      setState(() {
        passwordListener();
      });
    });
  }

  passwordListener() {
    if (presentation.password != null)
      passwordController.text = presentation.password;
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
          title: Text(presentation.toolbarTitle),
          actions: <Widget>[
            // action button
            IconButton(icon: Icon(Icons.help_outline), onPressed: () {}),
            // overflow menu
            PopupMenuButton<_MenuOptions>(
              onSelected: _select,
              itemBuilder: (BuildContext context) {
                return _choices.map((_MenuOptions choice) {
                  return PopupMenuItem<_MenuOptions>(
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
                    presentation.screenTitle,
                    style: Theme.of(context).textTheme.title,
                  ),
                  TextFormField(
                    initialValue: presentation.address,
                    decoration: InputDecoration(hintText: "Address"),
                  ),
                  TextFormField(
                    initialValue: presentation.port,
                    decoration: InputDecoration(
                      hintText: "Port",
                    ),
                  ),
                  TextFormField(
                    controller: passwordController,
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
                          presentation.getNewActivity(Channel.actionViewAbout);
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
            presentation.getNewActivity(Channel.actionViewAbout);
          },
          label: Text('Start'),
        )); //
  }

  //action to take when picking from the menu
  void _select(_MenuOptions choice) {
    if (choice == _choices[2])
      presentation.getNewActivity(Channel.actionViewAbout);
  }
}

class _MenuOptions {
  const _MenuOptions({this.title, this.icon});

  final String title;
  final IconData icon;
}

const List<_MenuOptions> _choices = const <_MenuOptions>[
  const _MenuOptions(title: 'Toggle Theme', icon: Icons.color_lens),
  const _MenuOptions(title: 'Show Intro', icon: Icons.thumb_up),
  const _MenuOptions(title: 'About', icon: Icons.info_outline),
];
