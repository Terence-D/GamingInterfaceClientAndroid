import 'package:meta/meta.dart';

enum BuildFlavor { other, gplay }

BuildEnvironment? _env;

BuildEnvironment? get env => _env;

class BuildEnvironment {
  final BuildFlavor flavor;

  BuildEnvironment._init({required this.flavor});

  static void init({@required flavor}) =>
      _env ??= BuildEnvironment._init(flavor: flavor);
}