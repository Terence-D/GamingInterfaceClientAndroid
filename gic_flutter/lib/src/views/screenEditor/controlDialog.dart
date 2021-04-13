import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gic_flutter/src/views/screenEditor/gicEditControl.dart';

class ControlDialog extends StatefulWidget {
  final GicEditControl control;

  const ControlDialog({Key key, this.control}) : super(key: key);

  @override
  _ControlDialogState createState() => _ControlDialogState();
}

class _ControlDialogState extends State<ControlDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(),
        elevation: 0,
        child: DefaultTabController(
            length: 4,
            child: Scaffold(
              appBar: AppBar(
                bottom: TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.build)),
                    Tab(icon: Icon(Icons.image)),
                    Tab(icon: Icon(Icons.text_fields)),
                    Tab(icon: Icon(Icons.straighten)),
                  ],
                ),
                title: widget.control,
              ),
              body: TabBarView(
                children: [
                  commandTab(context),
                  textTab(context),
                  imageTab(context),
                  sizingTab(context),
                ],
              ),
            ))); // child:,
  }

  commandTab(context) {
    return Column(
      children: <Widget>[
      ],
    );
  }

  textTab(context) {
    return Column(
      children: <Widget>[
      ],
    );
  }

  imageTab(context) {
    return Column(
      children: <Widget>[
      ],
    );
  }

  sizingTab(context) {
    return Column(
      children: <Widget>[
      ],
    );
  }
}
