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

  IntlNewScreenWizard _translation;
  NewScreenWizardModel _viewModel;

  //tracks if we are on the general settings view (0)
  //or the create controls view (1)
  int _currentView = 0;

  final _bloc = NewScreenWizardBloc();

  final TextEditingController _screenNameTextController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _translation = new IntlNewScreenWizard(context);
    _screenNameTextController.addListener(() {    _viewModel.screenName = _screenNameTextController.text;});
  }

  @override
  void dispose() {
    _bloc.dispose();
    _screenNameTextController.dispose();
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
      title: Text(_translation.text(NewScreenWizardText.toolbarTitle)),
    );
  }

  /// This determines the main view to return, general settings or controls
  _mainContent() {
    if (_currentView == 0)
      return new NewScreenWizardGeneral(this);
    else
      return new NewScreenWizardControls(this);
  }

  Widget _fab(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () { _bloc.saveScreen(_viewModel); },
      backgroundColor: Theme.of(context).primaryColor,
      label: Text(_translation.text(NewScreenWizardText.save))
    );
  }
}
