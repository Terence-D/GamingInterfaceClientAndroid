import 'package:flutter/material.dart';
import 'package:gic_flutter/model/channel.dart';
import 'package:gic_flutter/model/mainVM.dart';
import 'package:gic_flutter/screens/main/mainPresentation.dart';
import 'package:gic_flutter/services/setting/settingRepository.dart';
import 'package:gic_flutter/theme/dimensions.dart' as dim;

class MainScreen extends StatefulWidget {
  final SettingRepository repository;

  MainScreen(this.repository, {Key key}) : super(key: key); // {}

  @override
  MainScreenState createState() {
    return MainScreenState();
  }
}

class MainScreenState extends State<MainScreen> {
  MainPresentation presentation;
  ScreenListItem selectedScreen;

  MainScreenState(); // {}

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    presentation = new MainPresentation(this, widget.repository);

    presentation.loadSettings().then((_) {
      // if (presentation.password != null && passwordController.hasListeners)
      //   passwordController.text = presentation.password;
      setState(() {
        if (presentation.screenList.length > 0)
          selectedScreen = presentation.screenList[0];
        else
          selectedScreen = new ScreenListItem(0, "test");
      });
    });
  }

  passwordListener() {
    // if (presentation.password != null)
    //   passwordController.text = presentation.password;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called
    if (presentation.password == null) {
      return new Center(
        child: new CircularProgressIndicator(),
      );
    } else return Scaffold(
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
                    //controller: passwordController,
                    initialValue: presentation.password,
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
                      DropdownButton<ScreenListItem>(
                        value: selectedScreen,
                        items:
                            presentation.screenList.map((ScreenListItem item) {
                          return new DropdownMenuItem<ScreenListItem>(
                            value: item,
                            child: new Text(
                              item.name,
                            ),
                          );
                        }).toList(),
                        onChanged: (ScreenListItem item) {
                          setState(() {
                            selectedScreen = item;
                          });
                        },
                      ),
                      RaisedButton(
                        onPressed: () {
                          presentation.getNewActivity(Channel.actionViewManager);
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
            presentation.getNewActivity(Channel.actionViewStart);
          },
          label: Text('Start'),
        )); //
  }

  //action to take when picking from the menu
  void _select(_MenuOptions choice) {
    if (choice == _choices[2])
      presentation.getNewActivity(Channel.actionViewAbout);
    else if (choice == _choices[1])
      presentation.getNewActivity(Channel.actionViewIntro);
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
