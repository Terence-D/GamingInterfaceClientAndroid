import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gic_flutter/model/viewModel.dart';
import 'package:gic_flutter/model/viewSection.dart';
import 'package:gic_flutter/theme/dimensions.dart' as dim;
import 'package:url_launcher/url_launcher.dart';

import '../basePage.dart';
import 'aboutPresentation.dart';
import 'aboutVM.dart';

class AboutView extends BasePage {
  @override
  AboutViewState createState() {
    return AboutViewState();
  }
}

class AboutViewState extends BaseState<AboutView> {
  AboutVM viewModel = new AboutVM();

  @override
  void initState() {
    presentation = new AboutPresentation(this);
    super.initState();
  }

  @override
  void onLoadComplete(ViewModel viewModel) {
    setState(() {
      this.viewModel = viewModel;
    });
  }

  @override
  Widget build(BuildContext context) {
    String title = " ";
    if (viewModel != null)
      title = viewModel.toolbarTitle;
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text(title),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(dim.activityMargin),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(viewModel.versionText),
                link(viewModel.url),
                section(viewModel.server),
                header(viewModel.libraryTitle),
                _libraries(viewModel.libraries),
                section(viewModel.legal),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton (
          onPressed: () {
            _sendEmail(viewModel.emailTo);
          },
          child: Icon(Icons.email)
        )); //
  }

  void _sendEmail(email) async {
    if (await canLaunch(email)) {
      await launch(email);
    } else {
      throw 'Could not launch $link';
    }
  }

  Widget _libraries(List<ViewSection> sections) {
    if (sections != null) {
      List<Widget> widgets = new List<Widget>();
      TextStyle textStyle = Theme.of(context).textTheme.subtitle1;
      sections.forEach((s) => widgets.add(section(s, textStyle)));

      return Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: widgets,
      );
    }
    return Column();
  }


  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
