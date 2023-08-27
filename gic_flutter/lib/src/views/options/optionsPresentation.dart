import 'package:flutter/cupertino.dart';
import 'package:gic_flutter/src/backend/models/intl/intlOptions.dart';
import 'package:gic_flutter/src/backend/models/intl/localizations.dart';
import 'package:gic_flutter/src/backend/models/launcherModel.dart';
import 'package:gic_flutter/src/backend/repositories/launcherRepository.dart';
import 'package:gic_flutter/src/views/basePage.dart';

import 'optionsVM.dart';

class OptionsPresentation implements BasePresentation {
  BaseState _contract;
  LauncherRepository _repository = LauncherRepository();
  OptionsVM? _viewModel;

  OptionsPresentation(this._contract);
  
  Future<void> buildVM(BuildContext context) async {
    _viewModel = OptionsVM();
    _viewModel!.toolbarTitle =
        Intl.of(context)!.options(OptionsText.toolbarTitle);
    _viewModel!.darkModeTitle =
        Intl.of(context)!.options(OptionsText.darkModeTitle);
    _viewModel!.darkModelText =
        Intl.of(context)!.options(OptionsText.darkModeText);
    _viewModel!.soundTitle = Intl.of(context)!.options(OptionsText.soundTitle);
    _viewModel!.soundText = Intl.of(context)!.options(OptionsText.soundText);
    _viewModel!.vibrationTitle =
        Intl.of(context)!.options(OptionsText.vibrationTitle);
    _viewModel!.vibrationText =
        Intl.of(context)!.options(OptionsText.vibrationText);
    _viewModel!.keepScreenOnTitle =
        Intl.of(context)!.options(OptionsText.keepScreenOnTitle);
    _viewModel!.keepScreenOnText =
        Intl.of(context)!.options(OptionsText.keepScreenOnText);
    await _fetchAllPreferences();
    _contract.onLoadComplete(_viewModel!);
  }

  void setTheme(bool isDarkMode) {
    _repository.setDarkMode(isDarkMode);
    _viewModel!.darkMode = isDarkMode;
    _contract.onLoadComplete(_viewModel!);
  }

  void setVibration(bool hapticsEnabled) {
    _repository.setVibration(hapticsEnabled);
    _viewModel!.vibration = hapticsEnabled;
    _contract.onLoadComplete(_viewModel!);
  }

  void setSound(bool soundEnabled) {
    _repository.setSound(soundEnabled);
    _viewModel!.sound = soundEnabled;
    _contract.onLoadComplete(_viewModel!);
  }

  void setScreenOn(bool keepScreenOn) {
    _repository.setScreenOn(keepScreenOn);
    _viewModel!.keepScreenOn = keepScreenOn;
    _contract.onLoadComplete(_viewModel!);
  }

  Future<void> _fetchAllPreferences() async {
    LauncherModel itemModel = await _repository.fetch();
    _viewModel!.darkMode = itemModel.darkMode;
    _viewModel!.vibration = itemModel.vibration;
    _viewModel!.sound = itemModel.sound;
    _viewModel!.keepScreenOn = itemModel.keepScreenOn;
  }
}
