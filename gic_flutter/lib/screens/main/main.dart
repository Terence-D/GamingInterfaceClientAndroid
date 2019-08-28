import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:gic_flutter/model/channel.dart';
import 'package:gic_flutter/model/mainVM.dart';
import 'package:gic_flutter/screens/main/mainPresentation.dart';
import 'package:gic_flutter/services/setting/settingRepository.dart';
import 'package:gic_flutter/theme/dimensions.dart' as dim;
import 'package:gic_flutter/theme/theme.dart';
import 'package:highlighter_coachmark/highlighter_coachmark.dart';
import 'package:toast/toast.dart';

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
  TextEditingController passwordController = new TextEditingController();
  TextEditingController addressController = new TextEditingController();
  TextEditingController portController = new TextEditingController();
  bool _loading = false;
  GlobalKey _fabKey = GlobalObjectKey("fab");
  GlobalKey _addressKey = GlobalObjectKey("address");
  GlobalKey _portKey = GlobalObjectKey("port");
  GlobalKey _passwordKey = GlobalObjectKey("password");
  GlobalKey _listKey = GlobalObjectKey("list");
  GlobalKey _manageKey = GlobalObjectKey("manage");

  MainScreenState(); // {}

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    presentation = new MainPresentation(this, widget.repository);

    //when control is returned from the legacy android, this will update the screen list
    SystemChannels.lifecycle.setMessageHandler((msg) {
      if (msg == AppLifecycleState.resumed.toString())
        presentation.loadSettings().then((_) {
          setState(() {
            if (presentation.screenList.length > 0)
              selectedScreen = presentation.screenList[0];
          });
        });
    });

    presentation.loadSettings().then((_) {
      setState(() {
        if (presentation.darkTheme) _changeTheme(context, ThemeKeys.DARK);
        if (presentation.screenList.length > 0)
          selectedScreen = presentation.screenList[0];
        passwordController.text = presentation.password;
        portController.text = presentation.port;
        addressController.text = presentation.address;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called
    if (presentation.password == null || _loading) {
      return new Stack(
        children: [
          new Opacity(
            opacity: 0.3,
            child: const ModalBarrier(dismissible: false, color: Colors.grey),
          ),
          new Center(
            child: new CircularProgressIndicator(),
          ),
        ],
      );
    } else
      return Scaffold(
          appBar: AppBar(
            //leading: Icon(Icons.apps),
            title: Text(presentation.toolbarTitle),
            actions: <Widget>[
              // action button
              IconButton(
                  icon: Icon(Icons.help_outline),
                  onPressed: () {
                    _showHelp();
                  }),
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
                      key: _addressKey,
                      controller: addressController,
                      decoration: InputDecoration(hintText: "Address"),
                    ),
                    TextFormField(
                      key: _portKey,
                      controller: portController,
                      decoration: InputDecoration(
                        hintText: "Port",
                      ),
                    ),
                    TextFormField(
                      key: _passwordKey,
                      controller: passwordController,
                      obscureText: true,
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
                          key: _listKey,
                          value: selectedScreen,
                          items: presentation.screenList
                              .map((ScreenListItem item) {
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
                          key: _manageKey,
                          onPressed: () {
                            presentation
                                .getNewActivity(Channel.actionViewManager);
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
            key: _fabKey,
            onPressed: () {
              if (presentation.screenList.length < 1)
                showMessage(
                    "You need to add a screen from the screen manager first!");
              presentation.startGame(
                  passwordController.text,
                  addressController.text,
                  portController.text,
                  selectedScreen.id);
            },
            label: Text('Start'),
          )); //
  }

  void _changeTheme(BuildContext buildContext, ThemeKeys key) {
    CustomTheme.instanceOf(buildContext).changeTheme(key);
  }

  void setConnectingIndicator(bool visible) {
    setState(() {
      _loading = visible;
    });
  }

  //action to take when picking from the menu
  void _select(_MenuOptions choice) {
    if (choice == _choices[2])
      presentation.getNewActivity(Channel.actionViewAbout);
    else if (choice == _choices[1])
      presentation.getNewActivity(Channel.actionViewIntro);
    else if (choice == _choices[0]) {
      if (presentation.darkTheme)
        _changeTheme(context, ThemeKeys.LIGHT);
      else
        _changeTheme(context, ThemeKeys.DARK);
      presentation.darkTheme = !presentation.darkTheme;
    }
  }

  void showMessage(String text) {
    Toast.show("Error " + text, context,
        duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
  }

  void showUpgradeWarning() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Wrong Version"),
            content: new Text(
                "The GIC Server appears to be out of date - please upgrade to the latest version by clicking on the \"Website\" link on the server.  If you did not yet install the server, click the Help button"),
            actions: <Widget>[
              new FlatButton(
                child: new Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  void startGame() {
    presentation.getStartActivity();
  }

  void _showHelp() {
    _helpDisplay("Enter the IP Address of the server here, or tap outside the circle for the next hint (1/4)",
      _addressKey,
      lengthModifier: .25
     );
  }

  void _helpDisplay(String text, GlobalKey key, {double lengthModifier = -1}) {
    CoachMark coachMarkFAB = CoachMark();
    RenderBox target = key.currentContext.findRenderObject();

    Rect markRect = target.localToGlobal(Offset.zero) & target.size;

    double _length = markRect.longestSide;
    if (lengthModifier > 0)
      _length = markRect.longestSide * lengthModifier;


    markRect = Rect.fromLTWH(
      markRect.left, markRect.top, _length, markRect.height);
    // markRect = Rect.fromCircle(
    //     center: markRect.centerLeft, radius: _length * 0.6);

    coachMarkFAB.show(
        targetContext: _fabKey.currentContext,
        markRect: markRect,
        children: [
          Center(
              child: Text(text,
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  )))
        ],
        duration: null,
        onClose: () {
          //Timer(Duration(seconds: 3), () => showCoachMarkTile());
        });
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
