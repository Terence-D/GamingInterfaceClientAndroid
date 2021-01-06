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
             child: dynamicControl(element),
     ));
    }

    Widget dynamicControl(ControlViewModel element) {
        switch (element.type) {
            case ControlViewModelType.Text:
                return gicText(element);
            case ControlViewModelType.Image:
                return gicImage(element);
            default:
                return gicButton(element);
        }
    }

    gicButton(ControlViewModel element) {
        return new MaterialButton(
            onPressed: () {  },
            child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/images/controls/${element.images[0]}.png"),
                        fit: BoxFit.cover)),
                child:
                new Text(
                    element.text, style: TextStyle(
                    color: element.font.color,
                    fontFamily: element.font.family,
                    fontSize: element.font.size,
                ))
            ) );
    }

    gicImage(ControlViewModel element) {
        return new Image.asset("assets/images/controls/${element.images[0]}.png");
    }

    gicText(ControlViewModel element) {
        return new Text(
            element.text, style: TextStyle(
            color: element.font.color,
            fontFamily: element.font.family,
            fontSize: element.font.size,
        ));
    }

    @override
    Widget build(BuildContext context) {
        return new Stack(
            children: widgets
        );
    }
}
