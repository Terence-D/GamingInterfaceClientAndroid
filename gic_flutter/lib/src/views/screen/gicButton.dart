import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';
import 'package:http/http.dart' as http;

class GicButton extends StatefulWidget {
  final ControlViewModel control;
  final TextStyle textStyle;
  final String password;
  final String port;
  final String address;

  GicButton({Key key, @required this.control, @required this.textStyle, @required this.password, @required this.port, @required this.address}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return GicButtonState(control: control, textStyle: textStyle, password: password, port: port, address: address);
  }
}

class GicButtonState extends State<GicButton> {
  final ControlViewModel control;
  final TextStyle textStyle;
  final BorderRadius buttonBorder = new BorderRadius.all(Radius.circular(5));
  final String password;
  final String port;
  final String address;

  BoxDecoration unpressed;
  BoxDecoration pressed;
  BoxDecoration active;

  GicButtonState({@required this.control, @required this.textStyle, @required this.password, @required this.port, @required this.address}) {
    unpressed = _buildDesign(false);
    pressed = _buildDesign(true);
    active = unpressed;
  }

  onTap() {
    setState(() {
      switch (control.type) {
        case ControlViewModelType.Toggle:
          sendCommand("toggle");
          if (active == pressed)
            active = unpressed;
          else
            active = pressed;
          break;
        case ControlViewModelType.QuickButton:
        case ControlViewModelType.Button:
          sendCommand("key");
          active = pressed;
      }
    });
  }

  onTapUp() {
    if (control.type != ControlViewModelType.Toggle)
      setState(() {
        active = unpressed;
      });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTapDown: (TapDownDetails details) => onTap(),
        onTapUp: (TapUpDetails details) => onTapUp(),
        child: Container(
          width: control.width,
          height: control.height,
          decoration: active,
          child: Center(
              child: Text(control.text,
                textAlign: TextAlign.center,
                style: textStyle
              )),
        ));
  }

  BoxDecoration _buildDesign(bool isPressed) {
    int imageIndex = 0;
    Alignment begin = Alignment.bottomCenter;
    Alignment end = Alignment.topCenter;

    if (isPressed) {
      imageIndex++;
      begin = Alignment.topCenter;
      end = Alignment.bottomCenter;
    }

    if (control.design == ControlDesignType.UpDownGradient) {
      return BoxDecoration(
          borderRadius: buttonBorder,
          gradient: LinearGradient(
            colors: control.colors,
            begin: begin,
            end: end,
          ));
    } else {
      return BoxDecoration(
          borderRadius: buttonBorder,
          image: DecorationImage(
              image: AssetImage("assets/images/controls/${control.images[imageIndex]}.png"),
              fit: BoxFit.cover));
    }
  }

  Future<void> sendCommand(String command) async {
    String basicAuth = base64Encode(Latin1Codec().encode('gic:$password'));
    Map<String, String> headers = new Map();
    headers["Authorization"] = 'Basic $basicAuth';
    String body = json.encode(control.commands[0].toJson());
    await http.post(new Uri.http("$address:$port", "/api/$command"),
        body: body,
        headers:headers).timeout(const Duration(seconds: 30)).then((response) {
      log(response.statusCode.toString());
      if(response.statusCode == 200) {
      }
      else {
      }
    }).catchError((err) {
      log(err.toString());
    });

  }
}
