import 'dart:core';

import 'package:gic_flutter/model/viewModel.dart';
import 'package:gic_flutter/model/viewSection.dart';

class AboutVM implements ViewModel {
  String toolbarTitle = "";
  String versionText = "";
  String libraryTitle = "";
  String emailTo = "";
  String emailTitle = "";
  String url = "";
  var libraries;
  ViewSection legal = new ViewSection("","","");
  ViewSection server = new ViewSection("","","");
}

