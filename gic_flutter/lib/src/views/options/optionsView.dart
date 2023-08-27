import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gic_flutter/src/backend/models/viewModel.dart';
import 'package:gic_flutter/src/theme/theme.dart';

import '../basePage.dart';
import 'optionsPresentation.dart';
import 'optionsVM.dart';

class OptionsView extends BasePage {
  @override
  OptionsViewState createState() {
    return OptionsViewState();
  }
}

class OptionsViewState extends BaseState<OptionsView> {
  OptionsVM _viewModel = OptionsVM();

  @override
  void initState() {
    presentation = OptionsPresentation(this);
    super.initState();
  }

  @override
  void onLoadComplete(ViewModel viewModel) {
    setState(() {
      this._viewModel = viewModel as OptionsVM;
    });
  }

  @override
  Widget build(BuildContext context) {
    String title = "";
    title = _viewModel.toolbarTitle;
      return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(title),
      ),
      body: ListView(children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(_viewModel.darkModeTitle),
            subtitle: Text(_viewModel.darkModelText),
            trailing: Checkbox(
              value: _viewModel.darkMode,
              onChanged: (val) {
                _setTheme(val!);
              },
            ),
            onTap: () {
              setState(() {
                _setTheme(!_viewModel.darkMode);
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(_viewModel.soundTitle),
            subtitle: Text(_viewModel.soundText),
            trailing: Checkbox(
              value: _viewModel.sound,
              onChanged: (val) {
                _setSound(val!);
              },
            ),
            onTap: () {
              setState(() {
                _setSound(!_viewModel.sound);
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(_viewModel.vibrationTitle),
            subtitle: Text(_viewModel.vibrationText),
            trailing: Checkbox(
              value: _viewModel.vibration,
              onChanged: (val) {
                _setVibration(val!);
              },
            ),
            onTap: () {
              setState(() {
                _setVibration(!_viewModel.vibration);
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(_viewModel.keepScreenOnTitle),
            subtitle: Text(_viewModel.keepScreenOnText),
            trailing: Checkbox(
              value: _viewModel.keepScreenOn,
              onChanged: (val) {
                _setScreenOn(val!);
              },
            ),
            onTap: () {
              setState(() {
                _setScreenOn(!_viewModel.keepScreenOn);
              });
            },
          ),
        )
      ]),
    );
  }

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  void _setTheme(bool val) {
    (presentation as OptionsPresentation).setTheme(val);
    if (val) {
      CustomTheme.instanceOf(context).changeTheme(ThemeKeys.DARK);
    } else {
      CustomTheme.instanceOf(context).changeTheme(ThemeKeys.LIGHT);
    }
  }

  void _setSound(bool val) {
    (presentation as OptionsPresentation).setSound(val);
    if (val) {
      AudioPlayer player = new AudioPlayer();
      const alarmAudioPath = "audio/flick.wav";
      player.play(AssetSource(alarmAudioPath));
    }
  }

  void _setVibration(bool val) {
    (presentation as OptionsPresentation).setVibration(val);
    if (val) {
      HapticFeedback.lightImpact();
    }
  }

  void _setScreenOn(bool val) {
    (presentation as OptionsPresentation).setScreenOn(val);
    if (val) {
      HapticFeedback.lightImpact();
    }
  }
}
