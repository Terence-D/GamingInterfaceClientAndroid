import 'package:flutter/material.dart';
import 'package:gic_flutter/src/theme/style.dart';

enum ThemeKeys { LIGHT, DARK }

class MyAppThemes {
  static final lightTheme = ThemeData(
    primaryColor: myDarkTheme().primaryColor,
    brightness: Brightness.light,
  );

  static final darkTheme = ThemeData(
    primaryColor: myLightTheme().primaryColor,
    brightness: Brightness.dark,
  );
}

class Themes {
  static ThemeData getThemeFromKey(ThemeKeys themeKey) {
    switch (themeKey) {
      case ThemeKeys.LIGHT:
        return ThemeData.light();
      case ThemeKeys.DARK:
        return ThemeData.dark();
      default:
        return ThemeData.dark();
    }
  }
}

class _CustomTheme extends InheritedWidget {
  final CustomThemeState data;

  _CustomTheme({
    required this.data,
    Key? key,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_CustomTheme oldWidget) {
    return true;
  }
}

class CustomTheme extends StatefulWidget {
  final Widget child;
  final ThemeKeys initialThemeKey;

  const CustomTheme({
    Key? key,
    required this.initialThemeKey,
    required this.child,
  }) : super(key: key);

  @override
  CustomThemeState createState() => CustomThemeState();

  static ThemeData of(BuildContext context) {
    _CustomTheme? inherited = context.dependOnInheritedWidgetOfExactType<_CustomTheme>();
    return inherited!.data.theme;
  }

  static CustomThemeState instanceOf(BuildContext context) {
    _CustomTheme? inherited = context.dependOnInheritedWidgetOfExactType<_CustomTheme>();
    return inherited!.data;
  }
}

class CustomThemeState extends State<CustomTheme> {
  late ThemeData _theme;

  ThemeData get theme => _theme;

  @override
  void initState() {
    _theme = Themes.getThemeFromKey(widget.initialThemeKey);
    super.initState();
  }

  void changeTheme(ThemeKeys themeKey) {
    setState(() {
      _theme = Themes.getThemeFromKey(themeKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _CustomTheme(
      data: this,
      key: null,
      child: widget.child,
    );
  }
}