import 'dart:convert';

import 'package:flutter/material.dart';

enum Controls {
    button,
    text,
    image,
    toggle
}

class ControlTypes {

    List<String> _buttons;
    List<String> _toggles;

    List<String> get buttons => _buttons;
    List<String> get toggles => _toggles;

    //private constructor
    ControlTypes._create() {
        //does nothing but block public creation
    }

    //public factory
    static Future<ControlTypes> create(BuildContext context) async {
        ControlTypes controlTypes = ControlTypes._create(); //call private constructor

        final manifestJson = await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
        controlTypes._buttons = json.decode(manifestJson).keys.where((String key) => key.startsWith('assets/images/controls/button'));
        controlTypes._toggles = json.decode(manifestJson).keys.where((String key) => key.startsWith('assets/images/controls/toggle'));

        return controlTypes;
    }


}