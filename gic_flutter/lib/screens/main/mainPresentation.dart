import 'mainRepo.dart';
import 'mainVM.dart';

abstract class MainViewContract {
  void onLoadComplete(MainVM viewModel);
  void showOnboarding();
}

class MainPresentation implements MainRepoContract {
  MainVM _viewModel;
  MainViewContract _view;
  MainRepo _repository;

  MainPresentation(this._view) {
    _repository = new MainRepo(this);
  }

  @override
  void preferencesLoaded(MainVM viewModel) {
    if (viewModel.firstRun)
      _view.showOnboarding();
    else {
      _view.onLoadComplete(_viewModel);
    }
  }

  void loadViewModel() {
    _repository.fetch(); //this will wind up calling the preferencesLoaded above
  }

  setDarkTheme(bool newValue) {
    _repository.setDarkMode(newValue);
  }


  // MainScreenState _state;
  // ScreenListItem selectedScreen;
  // static const String _Version = "\"1.3.0.0\"";

  // String get toolbarTitle => _viewModel.toolbarTitle;
  // String get screenTitle => _viewModel.screenTitle;
  // bool get darkTheme => _viewModel.darkMode;
  // bool get firstRun => _viewModel.firstRun;
  // String get address => _viewModel.address;
  // String get port => _viewModel.port;
  // String get password => _viewModel.password;
  // bool get donate => _viewModel.donate;
  // bool get donateStar => _viewModel.donateStar;
  // List<ScreenListItem> get screenList => _viewModel.screenList;
  // int get selectedScreenID => _viewModel.selectedScreenId;

  // MainPresentation(MainScreenState state, SettingRepository repo) {
  //   _viewModel = new MainVM(repo);
  //   _state = state;
  // }

  // getNewActivity(String activity) async {
  //   MethodChannel platform = new MethodChannel(Channel.channelView);
  //   try {
  //     await platform.invokeMethod(activity);
  //   } on PlatformException catch (e) {
  //     print(e.message);
  //   }
  // }

  // getStartActivity() async {
  //   MethodChannel platform = new MethodChannel(Channel.channelView);
  //   try {
  //     await platform.invokeMethod(Channel.actionViewStart, {"password": password, "address": address, "port":port, "selectedScreenId": selectedScreenID});
  //   } on PlatformException catch (e) {
  //     print(e.message);
  //   }
  // }

  // Future<http.Response> _restGet(String address) async {
  //   try {
  //     return await http.get(address);
  //   } catch (e) {
  //     return Future.error(e);
  //   }
  // }

  // void startGame(String password, String address, String port, int selectedScreenId) async {
  //   _state.setConnectingIndicator(true);
  //   if (password.length < 6) {
  //       _state.showMessage(Intl.mainPasswordError);
  //       _state.setConnectingIndicator(false);
  //       return;
  //   }
  //   if (int.tryParse(port) == null) {
  //       _state.showMessage(Intl.mainInvalidPort);
  //       _state.setConnectingIndicator(false);
  //       return;
  //   }

  //   _viewModel.password = password;
  //   _viewModel.address = address;
  //   _viewModel.port = port;
  //   _viewModel.selectedScreenId = selectedScreenId;
  //   _viewModel.saveSettings();
  //   String url = "http://" + address + ":" + port + "/api/Version";
    
  //   try {
  //     http.Response response = await _restGet(url);    
  //     if (response == null)
  //       _state.showMessage(Intl.mainFirewallError);
  //     else if (response.statusCode == 200) {
  //       if (response.body == _Version) {
  //           _state.startGame();
  //       } else {
  //         _state.showUpgradeWarning();
  //       }
  //     } else {
  //         _state.showMessage(response.statusCode.toString());
  //     }
  //   } catch (e) {
  //         _state.showMessage(e.toString());
  //   } finally {
  //       _state.setConnectingIndicator(false);
  //   }
  // }

  // void loadOnboarding(BuildContext context) async {
  //   IntroPresentation presentation = new IntroPresentation();
  //   await presentation.loadPages(context).then((value) async {
  //     List<PageViewModel> pages = presentation.getPages();
  //     await Navigator.push(context,
  //         MaterialPageRoute(builder: (context) => OnBoardingPage(pages: pages))
  //     );

  //     await _loadData(context, checkEmpty: true);     
  //   });
  // }

  // Future _loadData(BuildContext context, {bool checkEmpty = false}) async {
  //   await _viewModel.loadSettings(context);
  //   _state.loadSettings();
  //   if (_viewModel.screenList.length > 0)
  //     selectedScreen = _viewModel.screenList[0];
  //   else if (checkEmpty) {
  //     Screen newScreen = new Screen();
  //     newScreen.screenId = 0;
  //     newScreen.name = "Screen";
  //     Screens screens = new Screens();
  //     await screens.save(newScreen);
  //     await _viewModel.loadSettings(context); //reload
  //     debugPrint("added empty screen by default");
  //   }

  //   _state.selectedScreen = selectedScreen;     
  // }


}