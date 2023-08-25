import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/intl/intlScreenEditor.dart';
import 'package:gic_flutter/src/backend/models/screen/controlDefaults.dart';
import 'package:gic_flutter/src/views/screen/gicControl.dart';
import 'package:gic_flutter/src/views/screenEditor/gicEditControl.dart';

abstract class BaseTab extends StatefulWidget {
  final IntlScreenEditor translation;
  final GicEditControl gicEditControl;
  final int? screenId;
  final ControlDefaults? defaultControls;

  BaseTab({Key? key, required this.gicEditControl, required this.translation, required this.screenId, this.defaultControls})
      : super(key: key);
}

abstract class BaseTabState extends State<BaseTab> {
  @protected
  double pixelRatio = 1;

  @protected
  Widget preview([BoxConstraints? constraints]) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(widget.translation.text(ScreenEditorText.previewHeader),
              style: Theme.of(context).textTheme.headline5),
        ),
        FittedBox(
          child: GicControl(
            constraints: constraints!,
            pixelRatio: pixelRatio,
            control: widget.gicEditControl.control,
            networkModel: null,
          ),
        ),
      ],
    );
  }
}
