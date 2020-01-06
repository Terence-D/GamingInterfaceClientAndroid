import 'dart:core';

import 'package:gic_flutter/model/ViewModel.dart';
import 'package:gic_flutter/model/ViewSection.dart';

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

