import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';

import '../screen.dart';

class ScreenViewModel {
    int screenId = -1;
    String name;
    List<ControlViewModel> controls = new List<ControlViewModel>();
    int newControlId = -1;
    Color backgroundColor;
    String backgroundPath;

    ScreenViewModel();

    factory ScreenViewModel.fromJson(Map<String, dynamic> json) {
        ScreenViewModel rv = new ScreenViewModel();
        rv.screenId = json['screenId'];
        rv.name = json['name'];
        rv.controls = json['controls'];
        rv.newControlId = json['newControlId'];
        rv.backgroundColor = json['backgroundColor'];
        rv.backgroundPath = json['backgroundPath'];
        return rv;
    }

    Map<String, dynamic> toJson() => {
        'version': "2",
        'screenId': screenId,
        'name': name,
        'controls': controls,
        'newControlId': newControlId,
        'backgroundColor': backgroundColor,
        'backgroundPath': backgroundPath
    };

    /// LEGACY CODE BELOW
    factory ScreenViewModel.fromLegacyModel(Screen model, double pixelRatio) {
        ScreenViewModel rv = new ScreenViewModel();
        rv.screenId = model.screenId;
        rv.name = model.name;
        model.controls.forEach((element) {
            rv.controls.add(new ControlViewModel.fromLegacyModel(element));
        });
        rv.newControlId = model.newControlId;

        if (model.backgroundColor == -1 || model.backgroundColor == null)
            rv.backgroundColor = Colors.black;
        else
            rv.backgroundColor = _convertLegacyColor(model.backgroundColor);
        rv.backgroundPath = model.backgroundPath;
        return rv;
    }

    /// Convert legacy java color to Flutter Color
    static Color _convertLegacyColor (int legacyColor) {
        return Color(legacyColor);
    }
}
