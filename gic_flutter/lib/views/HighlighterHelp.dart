import 'package:flutter/material.dart';

class HighligherHelp {
  HighligherHelp(String text, GlobalKey highlight, double highlightSize,
      MainAxisAlignment alignment) {
    this.text = text;
    this.highlight = highlight;
    this.highlightSize = highlightSize;
    this.alignment = alignment;
  }
  String text;
  GlobalKey highlight;
  double highlightSize;
  MainAxisAlignment alignment;
}

