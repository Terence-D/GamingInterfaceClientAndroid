import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Game extends StatefulWidget {
    @override
    State<StatefulWidget> createState() {
        return GameState();
    }
}

class GameState extends State<Game> {
    @override
    void dispose() {
        //gameBloc.dispose();
        super.dispose();
    }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
