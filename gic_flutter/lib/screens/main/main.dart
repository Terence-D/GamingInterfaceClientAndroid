import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gic_flutter/flavor.dart';

import 'package:gic_flutter/model/channel.dart';
import 'package:gic_flutter/model/intl/localizations.dart';
import 'package:gic_flutter/model/mainVM.dart';
import 'package:gic_flutter/screens/intro/intro.dart';
import 'package:gic_flutter/screens/intro/introPresentation.dart';
import 'package:gic_flutter/screens/main/mainPresentation.dart';
import 'package:gic_flutter/services/setting/settingRepository.dart';
import 'package:gic_flutter/theme/dimensions.dart' as dim;
import 'package:gic_flutter/theme/theme.dart';
import 'package:highlighter_coachmark/highlighter_coachmark.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:toast/toast.dart';

class MainScreen extends StatefulWidget {
  final SettingRepository repository;

  MainScreen(this.repository, {Key key}) : super(key: key); // {}

  @override
  MainScreenState createState() {
    return MainScreenState();
  }
}

class HighligherHelp {
  HighligherHelp(String text, GlobalKey highlight, double highlightSize,
      MainAxisAlignment alignment) {
    this.text = text;
    this.highlight = highlight;
    this.highlightSize = highlightSize;
    this.alignment = alignment;
  }
  String text;
  GlobalKey highlight;
  double highlightSize;
  MainAxisAlignment alignment;
}

class MainScreenState extends State<MainScreen> {
  MainPresentation presentation;
  ScreenListItem selectedScreen;
  TextEditingController passwordController = new TextEditingController();
  TextEditingController addressController = new TextEditingController();
  TextEditingController portController = new TextEditingController();
  bool _loading = false;
  bool donate = false;
  bool donateStar = false;
  GlobalKey _fabKey = GlobalObjectKey("fab");
  GlobalKey _addressKey = GlobalObjectKey("address");
  GlobalKey _portKey = GlobalObjectKey("port");
  GlobalKey _passwordKey = GlobalObjectKey("password");
  GlobalKey _listKey = GlobalObjectKey("list");
  GlobalKey _manageKey = GlobalObjectKey("manage");

  Queue<HighligherHelp> highlights = new Queue();

  MainScreenState(); // {}

  @override
  void dispose() {
    super.dispose();
  }

  void loadSettings() {
    if (presentation.screenList.length > 0)
      selectedScreen = presentation.screenList[0];
    passwordController.text = presentation.password;
    portController.text = presentation.port;
    addressController.text = presentation.address;
    donate = presentation.donate;
    donateStar = presentation.donateStar;
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
            loadSettings();
          });
        });
    });

    presentation.loadSettings().then((_) {
      setState(() {
        if (presentation.darkTheme) _changeTheme(context, ThemeKeys.DARK);
        loadSettings();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called
    // This if statement breaks themeing?!?!
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
                    _loadHelp();
                  }),
              // overflow menu
              PopupMenuButton<_MenuOptions>(
                onSelected: _select,
                itemBuilder: (BuildContext context) {
                  BuildEnvironment.init(flavor: BuildFlavor.gplay);
                  assert(env != null);

                  List<_MenuOptions> rv;
                  if (env.flavor == BuildFlavor.gplay) {
                    rv = _choices;
                  }  else {
                    rv = _choicesOther;
                  }
                  return rv.map((_MenuOptions choice) {
                    return PopupMenuItem<_MenuOptions>(
                      value: choice,
                      child: Text( Intl.of(context).getText(choice.title)),
                    );
                  }).toList();
                },
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.all(dim.activityMargin),
              child: Column(
                children: <Widget>[
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(
                      presentation.screenTitle,
                      style: Theme.of(context).textTheme.title,
                    ),
                    Visibility(
                      visible: donate,
                      child: Icon(
                        Icons.free_breakfast,
                        color: Colors.green,
                        size: 30.0,
                      ),
                    ),
                    Visibility(
                      visible: donateStar,
                      child: Icon(
                        Icons.star,
                        color: Colors.yellow,
                        size: 30.0,
                      ),
                    ),
                  ]),
                  TextFormField(
                    key: _addressKey,
                    controller: addressController,
                    decoration: InputDecoration(hintText: Intl.of(context).mainAddress),
                  ),
                  TextFormField(
                    key: _portKey,
                    controller: portController,
                    decoration: InputDecoration(
                      hintText: Intl.of(context).mainPort,
                    ),
                  ),
                  TextFormField(
                    key: _passwordKey,
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: Intl.of(context).mainPassword,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(dim.activityMargin),
                    child: Text(
                      Intl.of(context).mainPasswordWarning,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      DropdownButton<ScreenListItem>(
                        key: _listKey,
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
                        key: _manageKey,
                        onPressed: () {
                          presentation
                              .getNewActivity(Channel.actionViewManager);
                        },
                        child: Text(Intl.of(context).mainScreenManager),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            key: _fabKey,
            onPressed: () {
              if (presentation.screenList.length < 1)
                showMessage(
                    Intl.of(context).mainErrorNoScreen);
              presentation.startGame(
                  passwordController.text,
                  addressController.text,
                  portController.text,
                  selectedScreen.id);
            },
            label: Text(Intl.of(context).mainStart),
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
    if (choice == _choices[3])
      presentation.getNewActivity(Channel.actionViewDonate);
    if (choice == _choices[2])
      presentation.getNewActivity(Channel.actionViewAbout);
    else if (choice == _choices[1]) {
      presentation.loadOnboarding(context);
    }
    else if (choice == _choices[0]) {
      if (presentation.darkTheme)
        _changeTheme(context, ThemeKeys.LIGHT);
      else
        _changeTheme(context, ThemeKeys.DARK);
      presentation.darkTheme = !presentation.darkTheme;
    }
  }

  void showMessage(String text) {
    Toast.show(Intl.of(context).getText(text), context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }

  void showUpgradeWarning() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text(Intl.of(context).mainWrongVersion),
            content: new Text(Intl.of(context).mainOutOfDate),
            actions: <Widget>[
              new FlatButton(
                child: new Text(Intl.of(context).mainClose),
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

  void _loadHelp() {
    highlights = new Queue();
    highlights.add(new HighligherHelp(
        Intl.of(context).mainHelpIpAddress,
        _addressKey,
        .25,
        MainAxisAlignment.center));
    highlights.add(new HighligherHelp(
        Intl.of(context).mainHelpPassword,
        _passwordKey,
        .25,
        MainAxisAlignment.center));
    highlights.add(new HighligherHelp(
        Intl.of(context).mainHelpScreenList,
        _listKey,
        1,
        MainAxisAlignment.end));
    highlights.add(new HighligherHelp(
        Intl.of(context).mainHelpScreenManager,
        _manageKey,
        1,
        MainAxisAlignment.end));
    highlights.add(new HighligherHelp(
        Intl.of(context).mainHelpStart,
        _fabKey,
        1,
        MainAxisAlignment.center));

    _showHelp();
  }

  void _showHelp() {
    if (highlights.isNotEmpty) {
      HighligherHelp toShow = highlights.removeFirst();
      _helpDisplay(toShow.text, toShow.highlight, toShow.highlightSize,
          toShow.alignment);
    }
  }

  void _helpDisplay(
      String text, GlobalKey key, lengthModifier, MainAxisAlignment alignment) {
    CoachMark coachMarkFAB = CoachMark();
    RenderBox target = key.currentContext.findRenderObject();

    Rect markRect = target.localToGlobal(Offset.zero) & target.size;

    double _length = markRect.longestSide;
    if (lengthModifier > 0) _length = markRect.longestSide * lengthModifier;

    markRect =
        Rect.fromLTWH(markRect.left, markRect.top, _length, markRect.height);
    // markRect = Rect.fromCircle(
    //     center: markRect.centerLeft, radius: _length * 0.6);

    coachMarkFAB.show(
        targetContext: _fabKey.currentContext,
        markRect: markRect,
        children: [
          Column(
              mainAxisAlignment: alignment,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(text,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    )),
                RaisedButton(
                    child: new Text(Intl.of(context).mainNext),
                    onPressed: () {
                      _showHelp();
                    }),
              ])
        ],
        duration: null,
        onClose: () {});
  }
}

class _MenuOptions {
  const _MenuOptions({this.title, this.icon});

  final String title;
  final IconData icon;
}

List<_MenuOptions> _choices = <_MenuOptions>[
  _MenuOptions(title: Intl.menuTheme, icon: Icons.color_lens),
  _MenuOptions(title: Intl.menuIntro, icon: Icons.thumb_up),
  _MenuOptions(title: Intl.menuAbout, icon: Icons.info_outline),
  _MenuOptions(title: Intl.menuDonate, icon: Icons.present_to_all),
];

 List<_MenuOptions> _choicesOther = <_MenuOptions>[
  _MenuOptions(title: Intl.menuTheme, icon: Icons.color_lens),
  _MenuOptions(title: Intl.menuIntro, icon: Icons.thumb_up),
  _MenuOptions(title: Intl.menuAbout, icon: Icons.info_outline),
];
