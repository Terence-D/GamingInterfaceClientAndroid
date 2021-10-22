import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gic_flutter/bloc/launcherBloc.dart';
import 'package:gic_flutter/flavor.dart';
import 'package:gic_flutter/model/channel.dart';
import 'package:gic_flutter/model/intl/intlLauncher.dart';
import 'package:gic_flutter/model/launcherModel.dart';
import 'package:gic_flutter/theme/theme.dart';
import 'package:gic_flutter/ui/menuOption.dart';
import 'package:gic_flutter/ui/newScreenWizard/newScreenWizard.dart';
import 'package:gic_flutter/views/about/aboutView.dart';
import 'package:gic_flutter/views/intro/introView.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:showcaseview/showcaseview.dart';

import 'screenList.dart';
import 'serverLogin.dart';
//import 'package:intent/intent.dart' as android_intent;
//import 'package:intent/action.dart' as android_action;
//import 'package:intent/extra.dart' as android_extra;
//import 'package:intent/category.dart' as android_category;
//import 'package:intent/flag.dart' as android_flag;

class Launcher extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LauncherState();
  }
}

class LauncherState extends State<Launcher> { //}with HelpWidget {

  final GlobalKey _fabKey = GlobalKey();
  final GlobalKey addressKey = GlobalKey();
  final GlobalKey portKey = GlobalKey();
  final GlobalKey passwordKey = GlobalKey();
  final GlobalKey updateKey = GlobalKey();
  final GlobalKey startKey = GlobalKey();
  final GlobalKey editKey = GlobalKey();
  final GlobalKey shareKey = GlobalKey();
  final GlobalKey deleteKey = GlobalKey();

  IntlLauncher translation;
  LauncherModel _viewModel;

  int newScreenId = -1;

  final launcherBloc = LauncherBloc();

  final TextEditingController passwordController = new TextEditingController();
  final TextEditingController addressController = new TextEditingController();
  final TextEditingController portController = new TextEditingController();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  BuildContext showcaseContext;

  @override
  void initState() {
    super.initState();
    translation = new IntlLauncher(context);
    passwordController.addListener(_passwordListener);
    addressController.addListener(_addressListener);
    portController.addListener(_portListener);
    launcherBloc.fetchAllPreferences();
  }

  @override
  void dispose() {
    launcherBloc.dispose();
    passwordController.dispose();
    portController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
      ShowCaseWidget(
          builder: Builder(
              builder : (context) {
                showcaseContext = context;
                return Scaffold(
                    appBar: _launcherAppBar(),
                    body: StreamBuilder(
                      stream: launcherBloc.preferences,
                      builder: (context,
                          AsyncSnapshot<LauncherModel> snapshot) {
                        if (snapshot.hasData) {
                          return _buildViews(snapshot);
                        } else if (snapshot.hasError) {
                          return Text(snapshot.error.toString());
                        }
                        return Center(child: CircularProgressIndicator());
                      },
                    ),
                    floatingActionButton: _fab(context)
                );
              }
      )
    );
  }

  Widget _fab(BuildContext context) {
    return Showcase(
        key: _fabKey,
        title: translation.text(LauncherText.buttonNew),
        description: translation.text(LauncherText.helpNew),
        shapeBorder: CircleBorder(),
        child: FloatingActionButton.extended(
                onPressed: () {
                  _newScreen();
                },
                backgroundColor: Theme.of(context).primaryColor,
                label: Text(translation.text(LauncherText.buttonNew))
            )
    );
  }

  List<Widget>  _widgets(snapshot, orientation) {
    return <Widget>[
      ServerLogin(
        this,
        snapshot.data,
        translation,
        orientation),
      ScreenList(
        this,
        snapshot.data.screens,
        translation,
      )
    ];
  }

  Widget _buildViews(AsyncSnapshot<LauncherModel> snapshot) {
    _viewModel = snapshot.data;
    passwordController.text = _viewModel.password;
    portController.text = _viewModel.port;
    addressController.text = _viewModel.address;
    passwordController.selection = TextSelection.fromPosition(TextPosition(offset: passwordController.text.length));
    portController.selection = TextSelection.fromPosition(TextPosition(offset: portController.text.length));
    addressController.selection = TextSelection.fromPosition(TextPosition(offset: addressController.text.length));

    Orientation orientation = MediaQuery.of(context).orientation;
    var widgets;
    if (orientation == Orientation.portrait) {
      widgets = Column(children: _widgets(snapshot, orientation));
    } else {
      widgets = Row(children: _widgets(snapshot, orientation));
    }
    _scrollTo();
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
        IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              _showHelp();
            }),
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
      _showUi(AboutView());
    else if (choice.title == translation.text(LauncherText.menuIntro)) {
      _showUi(IntroView());
    }
    else if (choice.title == translation.text(LauncherText.menuImport)) {
      _import();
    }
    else if (choice.title == translation.text(LauncherText.menuTheme)) {
      if (_viewModel.darkMode) {
        CustomTheme.instanceOf(context).changeTheme(ThemeKeys.LIGHT);
        launcherBloc.setTheme(false);
        _viewModel.darkMode = false;
      }
      else {
        CustomTheme.instanceOf(context).changeTheme(ThemeKeys.DARK);
        launcherBloc.setTheme(true);
        _viewModel.darkMode = true;
      }
    } else {
      debugPrint ("not found");
    }
  }

  /// legacy native code calling
  Future<void> _getNewActivity(String activity) async {
    MethodChannel platform = new MethodChannel(Channel.channelView);
    try {
      await platform.invokeMethod(activity);
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  // call another flutter ui/view
  _showUi(StatefulWidget ui) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => ui)); // ManageView()) // AboutView())
    launcherBloc.fetchAllPreferences();
  }

  void _showHelp() {
    itemScrollController.jumpTo(index: 0);
    ShowCaseWidget.of(showcaseContext).startShowCase([
      _fabKey,
      addressKey,
      portKey,
      passwordKey,
      updateKey,
      startKey,
      editKey,
      shareKey,
      deleteKey
    ]);
  }

  void _passwordListener() {
    _viewModel.password = passwordController.text;
  }

  void _addressListener() {
    _viewModel.address = addressController.text;
  }

  void _portListener() {
    _viewModel.port = portController.text;
  }

  Future<void> _import() async {
    FilePickerResult result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path);
      if (file != null) {
        newScreenId = await launcherBloc.import(file);
        if (newScreenId > 0)
          Fluttertoast.showToast(
            msg: translation.text(LauncherText.importComplete),
          );
      }
    }
    }

  _newScreen() async {
    _showUi(new NewScreenWizard());
    //newScreenId = await launcherBloc.newScreen();
  }

  _scrollTo() {
    if (newScreenId >= 0 && _viewModel.screens.length > 0) {
      for (int i=0; i < _viewModel.screens.length; i++) {
        if (_viewModel.screens[i].id == newScreenId)
          itemScrollController.scrollTo(
              index: i,
              duration: Duration(seconds: 2),
              curve: Curves.easeInOutCubic);
      }
      newScreenId = -1;
    }
  }
}