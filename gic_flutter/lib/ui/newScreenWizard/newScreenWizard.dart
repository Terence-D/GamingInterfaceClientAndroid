import 'package:flutter/material.dart';
import 'package:gic_flutter/bloc/newScreenWizardBloc.dart';
import 'package:gic_flutter/model/intl/intlNewScreenWizard.dart';
import 'package:gic_flutter/model/newScreenWizardModel.dart';

import 'newScreenWizardControls.dart';
import 'newScreenWizardGeneral.dart';

class NewScreenWizard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NewScreenWizardState();
  }
}

class NewScreenWizardState extends State<NewScreenWizard> {

  IntlNewScreenWizard translation;
  NewScreenWizardModel viewModel = new NewScreenWizardModel();

  //tracks if we are on the general settings view (0)
  //or the create controls view (1)
  int currentView = 0;

  final _bloc = NewScreenWizardBloc();

  final TextEditingController screenNameTextController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    translation = new IntlNewScreenWizard(context);
    screenNameTextController.addListener(() {    viewModel.screenName = screenNameTextController.text;});
  }

  @override
  void dispose() {
    _bloc.dispose();
    screenNameTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _launcherAppBar(),
        body: _mainContent(),
        floatingActionButton: _fab(context)
    );
  }

  AppBar _launcherAppBar() {
    return AppBar(
      leading: Image.asset("assets/images/icons/app_icon.png", fit: BoxFit.cover),
      title: Text(translation.text(NewScreenWizardText.toolbarTitle)),
    );
  }

  /// This determines the main view to return, general settings or controls
  _mainContent() {
    if (currentView == 0)
      return new NewScreenWizardGeneral(this);
    else
      return new NewScreenWizardControls(this);
  }

  Widget _fab(BuildContext context) {
    String text = translation.text(NewScreenWizardText.next);
    if (currentView == 1)
      text = translation.text(NewScreenWizardText.save);
    return FloatingActionButton.extended(

      onPressed: () {
        setState(() {
          currentView++;
        });
      },
      backgroundColor: Theme.of(context).primaryColor,
      label: Text(text)
    );
  }
}
