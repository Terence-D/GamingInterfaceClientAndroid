import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/viewModel.dart';
import 'package:gic_flutter/src/backend/models/viewSection.dart';
import 'package:gic_flutter/src/theme/dimensions.dart' as dim;

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
  AboutVM viewModel = AboutVM();

  @override
  void initState() {
    presentation = AboutPresentation(this);
    super.initState();
  }

  @override
  void onLoadComplete(ViewModel viewModel) {
    setState(() {
      this.viewModel = viewModel as AboutVM;
    });
  }

  @override
  Widget build(BuildContext context) {
    String title = " ";
    title = viewModel.toolbarTitle;
      return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(title),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(dim.activityMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              header(viewModel.appName, Theme.of(context).textTheme.headlineMedium),
              Text(viewModel.versionText),
              link(viewModel.url),
              section(viewModel.server, centered: true),
              section(viewModel.legal, centered: true),
              header(viewModel.libraryTitle),
              _libraries(viewModel.libraries),
            ],
          ),
        ),
      ),
    );
  }

  Widget _libraries(List<ViewSection>? sections) {
    if (sections != null) {
      List<Widget> widgets = <Widget>[];
      TextStyle? textStyle = Theme.of(context).textTheme.titleMedium;
      sections.forEach(
          (s) => widgets.add(section(s, optionalHeaderStyle: textStyle)));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      );
    }
    return Column();
  }

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
