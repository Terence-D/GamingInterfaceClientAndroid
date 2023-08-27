import 'package:flutter/material.dart';
import 'package:gic_flutter/src/theme/theme.dart';

class ScreenItem {
  String title;
  bool selected = false;
  ScreenItem(this.title);
}

class ScreenListWidget extends StatefulWidget {
  final List<ScreenItem> _screens;
  ScreenListWidget(this._screens, {Key? key}) : super(key: key);

  @override
  _ScreenListWidgetState createState() => _ScreenListWidgetState();
}

class _ScreenListWidgetState extends State<ScreenListWidget> {
  @override
  Widget build(BuildContext context) {
    Color accent = CustomTheme
        .of(context)
        .primaryColor;
    return SizedBox(
      width: 200.0,
      height: 200.0,
      child: ListView(
        children: [
          Ink(
              color: widget._screens[0].selected ?  accent : Colors.transparent,
              child: ListTile(
                title: Text(widget._screens[0].title),
                onTap: () {
                  setState(() {
                    widget._screens[0].selected = ! widget._screens[0].selected;
                  });
                },
              )
          ),
          Ink(
              color: widget._screens[1].selected ?  accent : Colors.transparent,
              child: ListTile(
                title: Text(widget._screens[1].title),
                onTap: () {
                  setState(() {
                    widget._screens[1].selected = ! widget._screens[1].selected;
                  });
                },
              )
          ),
        ],
      ),
    );
  }
}

