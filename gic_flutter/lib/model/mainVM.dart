import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class MainVM extends Equatable {
  final bool firstRun;

  MainVM({
    @required this.firstRun,
  }) : super ([firstRun]);
}