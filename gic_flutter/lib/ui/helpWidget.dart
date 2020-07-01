import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:gic_flutter/views/HighlighterHelp.dart';
import 'package:highlighter_coachmark/highlighter_coachmark.dart';

abstract class HelpWidget {
  @protected
  void buildHelp();

  //this is the translated text for the "next" button when viewing help
  @protected
  String get helpTextNext;

  @protected
  Queue get helpQueue;

  @protected
  void showHelp() {
    if (helpQueue.isNotEmpty) {
      HighligherHelp toShow = helpQueue.removeFirst();
      _helpDisplay(toShow.text, toShow.highlight, toShow.highlightSize,
          toShow.alignment);
    }
  }

  void _helpDisplay(String text, GlobalKey key, lengthModifier, MainAxisAlignment alignment) {
    CoachMark coachMark = CoachMark();
    RenderBox target = key.currentContext.findRenderObject();

    Rect markRect = target.localToGlobal(Offset.zero) & target.size;

    double _length = markRect.longestSide;
    if (lengthModifier > 0) _length = markRect.longestSide * lengthModifier;

    markRect = Rect.fromLTWH(markRect.left, markRect.top, _length, markRect.height);
    // markRect = Rect.fromCircle(
    //     center: markRect.centerLeft, radius: _length * 0.6);

    coachMark.show(
        targetContext: key.currentContext,
        markRect: markRect,
        children: [
          Column(
              mainAxisAlignment: alignment,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(text,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    )),
                RaisedButton(
                    child: new Text(helpTextNext),
                    onPressed: () {
                      showHelp();
                    }),
              ])
        ],
        duration: null,
        onClose: () {});
  }
}