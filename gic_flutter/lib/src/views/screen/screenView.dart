import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gic_flutter/src/backend/models/screen/screen.dart';

class ScreenView extends StatelessWidget {
    final Screen screen;
    final List<Widget> widgets = new List<Widget>();
    
    ScreenView({Key key, @required this.screen}) : super (key:  key) {
        if (screen != null)
            screen.controls.forEach((element) {
               widgets.add(new Positioned(
                   left: element.left,
                   top: element.top,
                   child: new Container(
                       width: element.width.toDouble(),
                       height: element.height.toDouble(),
                       decoration: new BoxDecoration(color: Colors.blue),
                       child: new Text(element.text),
               )));
            });
    }

    @override
    Widget build(BuildContext context) {
        return new Stack(
            children: widgets
        );
    }
}
