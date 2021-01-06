import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/screenViewModel.dart';

class ScreenView extends StatelessWidget {
    final ScreenViewModel screen;
    final List<Widget> widgets = new List<Widget>();
    
    ScreenView({Key key, @required this.screen}) : super (key:  key) {
        if (screen != null)
            screen.controls.forEach((element) {
               widgets.add(_buildGicControl(element));
            });
    }

    Positioned _buildGicControl(ControlViewModel element) {
      return new Positioned(
         left: element.left,
         top: element.top,
         child: new Container(
             width: element.width,
             height: element.height,
             child: new RaisedButton(
                 child: new                  Text(
                     element.text)             ),
     ));
    }

    @override
    Widget build(BuildContext context) {
        return new Stack(
            children: widgets
        );
    }
}
