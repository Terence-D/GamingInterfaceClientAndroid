import 'dart:core';

import 'package:gic_flutter/src/backend/models/networkModel.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/screenViewModel.dart';
import 'package:gic_flutter/src/backend/models/viewModel.dart';
import 'package:gic_flutter/src/backend/models/viewSection.dart';

class ScreenVM implements ViewModel {
  final ScreenViewModel screen;
  final NetworkModel networkModel;
  final bool playSound;
  final bool vibration;

  ScreenVM(this.screen, this.networkModel, this.playSound, this.vibration);

  @override
  // TODO: implement toolbarTitle
  String get toolbarTitle => throw UnimplementedError();

}