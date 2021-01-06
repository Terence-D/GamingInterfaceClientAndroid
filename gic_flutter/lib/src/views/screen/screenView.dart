import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/font.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/screenViewModel.dart';

class ScreenView extends StatelessWidget {
    final ScreenViewModel screen;
    final List<Widget> widgets = new List<Widget>();
    final BorderRadius buttonBorder = new BorderRadius.all(Radius.circular(5));

    ScreenView({Key key, @required this.screen}) : super (key:  key) {
        if (screen != null)
            screen.controls.forEach((element) {
               widgets.add(_buildGicControl(element));
            });

    }

    @override
    Widget build(BuildContext context) {
        return Material(
            child: Stack(
                children: widgets
            ),
        );
    }

    onTapDown(ControlViewModel element) {

    }

    onTapUp(ControlViewModel element) {

    }

    Widget _buildGicControl(ControlViewModel element) {
        return Positioned(
            left: element.left,
            top: element.top,
            child: _dynamicControl(element),
            );
    }

    Widget _dynamicControl(ControlViewModel element) {
        switch (element.type) {
            case ControlViewModelType.Text:
                return _gicText(element);
            case ControlViewModelType.Image:
                return _gicImage(element);
            default:
                return _gicButton(element);
        }
    }

    Widget _gicButton(ControlViewModel element) {
        return GestureDetector(
           onTapDown: onTapDown(element),
           onTapUp: onTapUp(element),
           child: Container(
               width: element.width,
               height: element.height,
               decoration: _getDesign(element),
               child: Center(child: Text(
                   element.text,
                   textAlign: TextAlign.center,
                   style: _getTextStyle(element.font)
               )),
           )
        );
    }

    Widget _gicImage(ControlViewModel element) {
        return Image.asset("assets/images/controls/${element.images[0]}");
    }

    Widget _gicText(ControlViewModel element) {
        return new Container(
            width: element.width,
            child: Text(
                element.text,
                style: _getTextStyle(element.font)
            ));
    }

    TextStyle _getTextStyle(Font font) {
        return TextStyle(
            color: font.color,
            fontFamily: font.family,
            fontSize: font.size);
    }

    BoxDecoration _getDesign(ControlViewModel element) {
      if (element.design == ControlDesignType.UpDownGradient) {
          return BoxDecoration(
              borderRadius: buttonBorder,
              gradient: LinearGradient(colors: element.colors,
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
              )
          );
      } else {
          return BoxDecoration(
              borderRadius: buttonBorder,
              image: DecorationImage(
                  image: AssetImage("assets/images/controls/${element.images[0]}.png"),
                  fit: BoxFit.cover));
      }
    }
}
