import 'dart:core';

import 'package:gic_flutter/src/backend/models/networkModel.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/screenViewModel.dart';
import 'package:gic_flutter/src/backend/models/viewModel.dart';

class ScreenVM implements ViewModel {
  final ScreenViewModel screen;
  final NetworkModel networkModel;
  final bool playSound;
  final bool vibration;
  final bool keepScreenOn;

  ScreenVM(this.screen, this.networkModel, this.playSound, this.vibration,
      this.keepScreenOn);

  @override
  // TODO: implement toolbarTitle
  String get toolbarTitle => throw UnimplementedError();
}
