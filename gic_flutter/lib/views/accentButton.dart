import 'package:flutter/material.dart';

class AccentButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const AccentButton({this.child, this.onPressed, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RaisedButton(
      onPressed: onPressed,
      child: child,
      textColor: theme.accentTextTheme.button.color,
//      highlightColor: Color(0xffF44336),
//      color: Color(0xffF44336),
      highlightColor: theme.accentColor,
      color: theme.accentColor,
    );
  }
}