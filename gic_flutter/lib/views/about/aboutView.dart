import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:gic_flutter/model/ViewModel.dart';
import 'package:gic_flutter/theme/dimensions.dart' as dim;

import '../BasePage.dart';
import 'AboutVM.dart';
import 'aboutPresentation.dart';

class AboutView extends BasePage {
  @override
  AboutViewState createState() {
    return AboutViewState();
  }
}

class AboutViewState extends BaseState<AboutView> {
  AboutVM viewModel;

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
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text(viewModel.toolbarTitle),
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
                section(viewModel.legal),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton (
          onPressed: () {
          },
          child: Icon(Icons.email)
        )); //
  }

}
