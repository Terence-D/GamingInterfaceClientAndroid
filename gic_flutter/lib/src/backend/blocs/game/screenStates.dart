import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/screen/screen.dart';

abstract class ScreenStates extends Equatable {
    const ScreenStates();

    @override
    List<Object> get props => [];
}

class ScreenLoaded extends ScreenStates {
    final Screen screen;

    ScreenLoaded({@required this.screen}) : assert (screen != null);

    @override
    List<Object> get props => [screen];
}

class ScreenLoading extends ScreenStates {}
class ButtonPressed extends ScreenStates {}
class ButtonReleased extends ScreenStates {}
class ScreenError extends ScreenStates {}