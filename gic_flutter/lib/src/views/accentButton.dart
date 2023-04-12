import 'package:flutter/material.dart';

class AccentButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const AccentButton({this.child, this.onPressed, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton(
      onPressed: onPressed,
      child: child,
      style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.secondary,
      ),
//      textColor: theme.accentTextTheme.button.color,
//      highlightColor: theme.accentColor,
    );
  }
}