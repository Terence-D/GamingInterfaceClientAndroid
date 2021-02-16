//this service handles the backend work required for screen editor view
//for now going with a simple service layer

import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/screen/controlDefaults.dart';
import 'package:gic_flutter/src/backend/models/screen/screen.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/controlViewModel.dart';
import 'package:gic_flutter/src/backend/models/screen/viewModels/screenViewModel.dart';
import 'package:gic_flutter/src/backend/repositories/screenRepository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScreenService {
    ControlDefaults defaultControls;

    final ScreenViewModel screen;
    double pixelRatio;
    final String _prefGridSize = "prefGridSize";

    int gridSize = 0;

    ScreenService(this.screen);

    Future init() async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        defaultControls = new ControlDefaults(prefs, screen.screenId);
        gridSize = prefs.getInt(_prefGridSize);
        if (gridSize == null)
            gridSize = 0;
    }

    void addControl(Offset localPosition, BuildContext context) {
        pixelRatio = MediaQuery.of(context).devicePixelRatio;
        final double statusBarHeight = MediaQuery.of(context).padding.top;
        final double x = gridSize * (localPosition.dx / gridSize) + statusBarHeight;
        final double y = gridSize * (localPosition.dy / gridSize);

        ControlViewModel toAdd = ControlViewModel.fromModel(defaultControls.defaultButton);
        toAdd.left = x;
        toAdd.top = y;
        screen.controls.add(toAdd);
    }

    Future save() async {
        ScreenRepository repository = new ScreenRepository();
        Screen screenToSave = new Screen();
        //screenToSave.backgroundColor = screen.backgroundColor;

        repository.save(screen: screenToSave);
    }

}