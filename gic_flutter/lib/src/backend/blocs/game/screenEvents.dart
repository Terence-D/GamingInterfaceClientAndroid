import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/screen/command.dart';

abstract class ScreenEvents extends Equatable {
    const ScreenEvents();
}

class LoadScreen extends ScreenEvents {
  final int screenId;

  LoadScreen({@required this.screenId}) : assert (screenId != null && screenId > -1);

  @override
  List<Object> get props => [screenId];
}

class SendKeystroke extends ScreenEvents {
    final Command command;

    const SendKeystroke({@required this.command}) : assert (command != null);

    @override
    //TODO: implement props
    List<Object> get props => [command];

}