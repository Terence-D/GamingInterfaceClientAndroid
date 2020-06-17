import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gic_flutter/bloc/launcherBloc.dart';
import 'package:gic_flutter/flavor.dart';
import 'package:gic_flutter/model/channel.dart';
import 'package:gic_flutter/model/intl/intlLauncher.dart';
import 'package:gic_flutter/model/launcherModel.dart';
import 'package:gic_flutter/theme/theme.dart';
import 'package:gic_flutter/ui/menuOption.dart';
import 'package:gic_flutter/ui/screenList.dart';
import 'package:gic_flutter/ui/serverLogin.dart';
import 'package:gic_flutter/views/about/aboutView.dart';
import 'package:gic_flutter/views/intro/introView.dart';

class Launcher extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LauncherState();
  }
}

class LauncherState extends State<Launcher> { //}with HelpWidget {

  //  final GlobalKey _fabKey = GlobalObjectKey("fab");
//  final GlobalKey _addressKey = GlobalObjectKey("address");
//  final GlobalKey _portKey = GlobalObjectKey("port");
//  final GlobalKey _passwordKey = GlobalObjectKey("password");
//  final GlobalKey _listKey = GlobalObjectKey("list");

  IntlLauncher translation;
  LauncherModel _viewModel;
  final launcherBloc = LauncherBloc();

  final TextEditingController _passwordController = new TextEditingController();
  final TextEditingController _addressController = new TextEditingController();
  final TextEditingController _portController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    translation = new IntlLauncher(context);
    _passwordController.addListener(_passwordListener);
    launcherBloc.fetchAllPreferences();
  }

  @override
  void dispose() {
    launcherBloc.dispose();
    _passwordController.dispose();
    _portController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _launcherAppBar(),
      body: StreamBuilder(
        stream: launcherBloc.preferences,
        builder: (context, AsyncSnapshot<LauncherModel> snapshot) {
          if (snapshot.hasData) {
            return _buildViews(snapshot);
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
        floatingActionButton: FloatingActionButton.extended(
//            key: _newKey,
            onPressed: () {
              launcherBloc.newScreen();
            },
            backgroundColor: Theme.of(context).primaryColor,
            label: Text(translation.text(LauncherText.buttonNew))
        )
    );
  }

  List<Widget>  _widgets(snapshot, orientation) {
    return <Widget>[
      ServerLogin(
        _addressController,
        _passwordController,
        _portController,
        snapshot.data,
        translation,
        orientation),
      ScreenList(
        launcherBloc,
        _addressController,
        _passwordController,
        _portController,
        snapshot.data.screens,
        translation)
    ];
  }

  Widget _buildViews(AsyncSnapshot<LauncherModel> snapshot) {
    _viewModel = snapshot.data;
    _passwordController.text = _viewModel.password;
    _portController.text = _viewModel.port;
    _addressController.text = _viewModel.address;
    _passwordController.selection = TextSelection.fromPosition(TextPosition(offset: _passwordController.text.length));
    _portController.selection = TextSelection.fromPosition(TextPosition(offset: _portController.text.length));
    _addressController.selection = TextSelection.fromPosition(TextPosition(offset: _addressController.text.length));


    Orientation orientation = MediaQuery.of(context).orientation;
    var widgets;
    if (orientation == Orientation.portrait) {
      widgets = Column(children: _widgets(snapshot, orientation));
    } else {
      widgets = Row(children: _widgets(snapshot, orientation));
    }
    return Scaffold(
      body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: widgets));
  }

  AppBar _launcherAppBar() {
    return AppBar(
      leading: Image.asset("assets/images/icons/app_icon.png", fit: BoxFit.cover),
      title: Text(translation.text(LauncherText.toolbarTitle)),
      actions: <Widget>[
        // action button
//        IconButton(
//            icon: Icon(Icons.help_outline),
//            onPressed: () {
//              buildHelp();
//            }),
        // overflow menu
        menuButtons(),
      ],
    );
  }

  PopupMenuButton<MenuOption> menuButtons () {
    List<MenuOption> rv = <MenuOption>[
      MenuOption(title: translation.text(LauncherText.menuImport), icon: Icons.import_export),
      MenuOption(title: translation.text(LauncherText.menuTheme), icon: Icons.color_lens),
      MenuOption(title: translation.text(LauncherText.menuIntro), icon: Icons.thumb_up),
      MenuOption(title: translation.text(LauncherText.menuAbout), icon: Icons.info_outline),
    ];

    BuildEnvironment.init(flavor: BuildFlavor.gplay);
    assert(env != null);

    if (env.flavor == BuildFlavor.gplay) {
      rv.add(MenuOption(title: translation.text(LauncherText.menuDonate), icon: Icons.present_to_all));
    }

    return PopupMenuButton<MenuOption> (
      onSelected: _menuSelectAction,
      itemBuilder: (BuildContext context) {
        return rv.map((MenuOption choice) {
          return PopupMenuItem<MenuOption>(
            value: choice,
            child: Text( choice.title),
          );
        }).toList();
      },
    );
  }

  //action to take when picking from the menu
  void _menuSelectAction(MenuOption choice) {
    if (choice.title == translation.text(LauncherText.menuDonate))
      _getNewActivity(Channel.actionViewDonate);
    else if (choice.title == translation.text(LauncherText.menuAbout))
      _showUi(context, AboutView());
    else if (choice.title == translation.text(LauncherText.menuIntro)) {
      _showUi(context, IntroView());
    }
    else if (choice.title == translation.text(LauncherText.menuImport)) {
      _import();
    }
    else if (choice.title == translation.text(LauncherText.menuTheme)) {
      if (_viewModel.darkMode) {
        CustomTheme.instanceOf(context).changeTheme(ThemeKeys.LIGHT);
        launcherBloc.setDarkTheme(false);
        _viewModel.darkMode = false;
      }
      else {
        CustomTheme.instanceOf(context).changeTheme(ThemeKeys.DARK);
        launcherBloc.setDarkTheme(true);
        _viewModel.darkMode = true;
      }
    } else {
      debugPrint ("not found");
    }
  }

  _getNewActivity(String activity) async {
    MethodChannel platform = new MethodChannel(Channel.channelView);
    try {
      await platform.invokeMethod(activity);
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  _showUi(BuildContext context, StatefulWidget ui) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ui)); // ManageView()) // AboutView())
  }


//  @override
//  void buildHelp() {
//    Queue<HighligherHelp> highlights = new Queue();
//    highlights = new Queue();
//    highlights.add(new HighligherHelp(
//        translation.text(LauncherText.helpIpAddress),
//        _addressKey,
//        .25,
//        MainAxisAlignment.center));
//    highlights.add(new HighligherHelp(
//        translation.text(LauncherText.helpPort),
//        _portKey,
//        1,
//        MainAxisAlignment.center));
//    highlights.add(new HighligherHelp(
//        translation.text(LauncherText.helpPassword),
//        _passwordKey,
//        .25,
//        MainAxisAlignment.center));
//    highlights.add(new HighligherHelp(
//        translation.text(LauncherText.helpScreenList),
//        _listKey,
//        1,
//        MainAxisAlignment.end));
//    highlights.add(new HighligherHelp(
//        translation.text(LauncherText.helpStart),
//        _fabKey,
//        1,
//        MainAxisAlignment.center));
//
//    showHelp();
//  }
//
//  @override
//  Queue get helpQueue => helpQueue;
//
//  @override
//  String get helpTextNext => translation.text(LauncherText.next);

  void _passwordListener() {
    _viewModel.password = _passwordController.text;
  }

  Future<void> _import() async {
    File file = await FilePicker.getFile();
//      type: FileType.custom,
//      allowedExtensions: ['zip'],
//    );
    launcherBloc.import(file);
  }
}