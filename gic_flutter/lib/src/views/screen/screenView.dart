import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gic_flutter/src/backend/models/screen/gicControl.dart';
import 'package:gic_flutter/src/backend/models/screen/screen.dart';

class ScreenView extends StatelessWidget {
    final Screen screen;
    final List<Widget> widgets = new List<Widget>();
    
    ScreenView({Key key, @required this.screen}) : super (key:  key) {
        if (screen != null)
            screen.controls.forEach((element) {
               widgets.add(_buildGicControl(element));
            });
    }

    Positioned _buildGicControl(GicControl element) {
      return new Positioned(
         left: element.left,
         top: element.top,
         child: new Container(
             width: element.width.toDouble(),
             height: element.height.toDouble(),
             decoration: new BoxDecoration(color: Colors.blue),
             child: new Text(
                 element.text, style: TextStyle(
                  color: _convertJavaColor(element.fontColor),
                  fontFamily: element.fontName,
                  fontSize: element.fontSize.toDouble(),
             )),
     ));
    }

    @override
    Widget build(BuildContext context) {
        return new Stack(
            children: widgets
        );
    }


    /// Convert legacy java color to Flutter Color
    Color _convertJavaColor (int legacyColor) {
        int r = (legacyColor >> 16) & 0xFF;
        int g = (legacyColor >> 8) & 0xFF;
        int b = legacyColor & 0xFF;

        return Color.fromARGB(1, r, g, b);
    }
}
