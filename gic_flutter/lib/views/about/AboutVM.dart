import 'dart:core';

class AboutVM {
  String toolbarTitle = "";
  String versionText = "";
  String libraryTitle = "";
  String emailTo = "";
  String emailTitle = "";
  String url = "";
  var libraries;
  AboutModel legal = new AboutModel("","","");
  AboutModel server = new AboutModel("","","");
}

class AboutModel {
  String title = "";
  String text = "";
  String url = "";

  AboutModel (this.title, this.text, this.url);
}
