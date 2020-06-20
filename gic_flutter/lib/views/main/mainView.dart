import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gic_flutter/flavor.dart';
import 'package:gic_flutter/model/channel.dart';
import 'package:gic_flutter/model/intl/localizations.dart';
import 'package:gic_flutter/theme/dimensions.dart' as dim;
import 'package:gic_flutter/theme/theme.dart';
import 'package:gic_flutter/views/HighlighterHelp.dart';
import 'package:gic_flutter/views/main/mainPresentation.dart';
import 'package:gic_flutter/views/main/mainVM.dart';
import 'package:highlighter_coachmark/highlighter_coachmark.dart';

class MainView extends StatefulWidget {
  MainView({Key key}) : super(key: key); // {}

  @override
  MainViewState createState() {
    return MainViewState();
  }
}

class MainViewState extends State<MainView> with WidgetsBindingObserver implements MainViewContract {
  TextEditingController passwordController = new TextEditingController();
  TextEditingController addressController = new TextEditingController();
  TextEditingController portController = new TextEditingController();

  MainVM _viewModel;
  MainPresentation presentation;
  bool _loading = false;

  GlobalKey _fabKey = GlobalObjectKey("fab");
  GlobalKey _addressKey = GlobalObjectKey("address");
  GlobalKey _portKey = GlobalObjectKey("port");
  GlobalKey _passwordKey = GlobalObjectKey("password");
  GlobalKey _listKey = GlobalObjectKey("list");
  GlobalKey _manageKey = GlobalObjectKey("manage");

  Queue<HighligherHelp> highlights = new Queue();

  MainViewState(); // {}

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();

    presentation = new MainPresentation(this);
    presentation.loadViewModel();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      presentation.loadViewModel();
    }
  }

  @override
  void onLoadComplete(MainVM viewModel) {
    this._viewModel = viewModel;
    setState(() {
      if (viewModel.screenList.length > 0)
        viewModel.selectedScreen = viewModel.screenList[0];
      passwordController.text = viewModel.password;
      portController.text = viewModel.port;
      addressController.text = viewModel.address;
      if (viewModel.darkMode)
        _changeTheme(context, ThemeKeys.DARK);
      else
        _changeTheme(context, ThemeKeys.LIGHT);
      _loading = false;
    });
  }

  @override
  void setConnectingIndicator(bool show) {
    setState(() {
      _loading = show;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called
    // This if statement breaks themeing?!?!
    if (_viewModel == null || _loading) {
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
            leading: Image.asset("assets/images/icons/app_icon.png", fit: BoxFit.cover),
            title: Text(_viewModel.toolbarTitle),
            actions: <Widget>[
              // action button
              IconButton(
                  icon: Icon(Icons.help_outline),
                  onPressed: () {
                    _loadHelp();
                  }),
              // overflow menu
              PopupMenuButton<_MenuOptions>(
                onSelected: _menuSelectAction,
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
                      _viewModel.screenTitle,
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    Visibility(
                      visible: _viewModel.donate,
                      child: Icon(
                        Icons.free_breakfast,
                        color: Colors.green,
                        size: 30.0,
                      ),
                    ),
                    Visibility(
                      visible: _viewModel.donateStar,
                      child: Icon(
                        Icons.star,
                        color: Colors.yellow,
                        size: 30.0,
                      ),
                    ),
                  ]),
                  TextFormField(
                    key: _addressKey,
                    inputFormatters: [
                      new BlacklistingTextInputFormatter(new RegExp('[\\ ]')),
                    ],
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
                        value: _viewModel.selectedScreen,
                        items:
                            _viewModel.screenList.map((ScreenListItem item) {
                          return new DropdownMenuItem<ScreenListItem>(
                            value: item,
                            child: new Text(
                              item.name,
                            ),
                          );
                        }).toList(),
                        onChanged: (ScreenListItem item) {
                          setState(() {
                            _viewModel.selectedScreen = item;
                          });
                        },
                      ),
                      RaisedButton(
                        key: _manageKey,
                        onPressed: () {
                          presentation.getNewActivity(Channel.actionViewManager);
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
              if (_viewModel.selectedScreen == null)
                showMessage(Intl.of(context).mainErrorNoScreen);
              else
                presentation.startGame(
                    passwordController.text,
                    addressController.text,
                    portController.text,
                    _viewModel.selectedScreen.id);
            },
            label: Text(Intl.of(context).mainStart),
          )); //
  }

  void _changeTheme(BuildContext buildContext, ThemeKeys key) {
    CustomTheme.instanceOf(buildContext).changeTheme(key);
  }

  // void setConnectingIndicator(bool visible) {
  // }

  //action to take when picking from the menu
  void _menuSelectAction(_MenuOptions choice) {
    if (choice.title == Intl.menuDonate)
      presentation.getNewActivity(Channel.actionViewDonate);
    else if (choice.title == Intl.menuAbout)
      presentation.showAbout(context);
    else if (choice.title == Intl.menuIntro) {
      presentation.showIntro(context);
    }
    else if (choice.title == Intl.menuTheme) {
      if (_viewModel.darkMode) {
        _changeTheme(context, ThemeKeys.LIGHT);
        presentation.setDarkTheme(false);
      }
      else {
        _changeTheme(context, ThemeKeys.DARK);
        presentation.setDarkTheme(true);
      }
    } else {
      debugPrint ("not found");
    }
  }

  void showMessage(String text) {
    Fluttertoast.showToast(
        msg: text,
    );
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