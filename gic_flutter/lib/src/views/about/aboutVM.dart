import 'dart:core';

import 'package:gic_flutter/src/backend/models/viewModel.dart';
import 'package:gic_flutter/src/backend/models/viewSection.dart';

class AboutVM implements ViewModel {
  String toolbarTitle;

  String appName = " ";
  String versionText = "";
  String libraryTitle = "";
  String emailTo = "";
  String emailTitle = "";
  String url = "";
  List<ViewSection> libraries;
  ViewSection legal = new ViewSection("","","");
  ViewSection server = new ViewSection("","","");
}

