import 'dart:convert';

import 'package:flutter/material.dart';

enum Controls {
    button,
    text,
    image,
    toggle
}

class ControlTypes {

    // static List<String> _buttons;
    // List<String> _toggles;
    //
    // static List<String> get buttons => _buttons;
    //
    // List<String> get toggles => _toggles;
    //
    // //private constructor
    // ControlTypes._create();
    //
    // //public factory
    // static Future<ControlTypes> create(BuildContext context) async {
    //     ControlTypes controlTypes = ControlTypes._create(); //call private constructor
    //
    //     final manifestJson = await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    //     _buttons = json
    //         .decode(manifestJson)
    //         .keys
    //         .where((String key) => key.startsWith('assets/images/controls/button'));
    //     controlTypes._toggles = json
    //         .decode(manifestJson)
    //         .keys
    //         .where((String key) => key.startsWith('assets/images/controls/toggle'));
    //
    //     return controlTypes;
    // }

    static final List<String> buttonDrawables = [
        "button_neon",
        "button_neon_dark",
        "button_blue",
        "button_blue_dark",
        "button_green",
        "button_green_dark",
        "button_green2",
        "button_green2_dark",
        "button_purple",
        "button_purple_dark",
        "button_red",
        "button_red_dark",
        "button_yellow",
        "button_yellow_dark",
        "button_black",
        "button_black_dark",
        "button_black2",
        "button_black2_dark",
        "button_blue2",
        "button_blue2_dark",
        "button_grey",
        "button_grey_dark",
        "button_grey2",
        "button_grey2_dark",
        "button_red2",
        "button_red2_dark",
        "button_white",
        "button_white_dark",
    ];

    static final List<String> toggleDrawables = [
        "switch_off",
        "switch_on",
        "toggle_off.9",
        "toggle_on.9"
    ];

}