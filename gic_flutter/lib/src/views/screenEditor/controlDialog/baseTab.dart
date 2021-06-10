import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/intl/intlScreenEditor.dart';
import 'package:gic_flutter/src/views/screen/gicControl.dart';
import 'package:gic_flutter/src/views/screenEditor/gicEditControl.dart';

abstract class BaseTab extends StatefulWidget {
  final IntlScreenEditor translation;
  final GicEditControl gicEditControl;
  final int screenId;

  BaseTab({Key key, this.gicEditControl, this.translation, this.screenId})
      : super(key: key);
}

abstract class BaseTabState extends State<BaseTab> {
  @protected
  double pixelRatio = 1;

  @protected
  Widget preview() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(widget.translation.text(ScreenEditorText.previewHeader),
              style: Theme.of(context).textTheme.headline5),
        ),
        FittedBox(
          child: GicControl(
            pixelRatio: pixelRatio,
            control: widget.gicEditControl.control,
            networkModel: null,
          ),
        ),
      ],
    );
  }
}
