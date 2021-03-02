import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/intl/intlScreenEditor.dart';
import 'package:gic_flutter/src/views/screenEditor/dialogItem.dart';
import 'package:gic_flutter/src/views/screenEditor/screenEditor.dart';

class BackgroundDialog {
  static Widget display(
      BuildContext context, ScreenEditorState screenEditorState) {
    IntlScreenEditor translation = new IntlScreenEditor(context);

    return SimpleDialog(
      title: Text(translation.text(ScreenEditorText.backgroundMenu)),
      children: [
        DialogItem(
          icon: Icons.image,
          color: Colors.blue,
          text: translation.text(ScreenEditorText.backgroundImage),
          onPressed: () {
            screenEditorState.pickBackgroundImage();
          }
        ),
        DialogItem(
          icon: Icons.color_lens,
          color: Colors.green,
          text: translation.text(ScreenEditorText.backgroundColor),
          onPressed: () {
            screenEditorState.pickBackgroundColor();
          },
        ),
      ],
    );
  }
}


