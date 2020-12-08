import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  final TextEditingController screenWidthTextController = new TextEditingController();
  final TextEditingController screenHeightTextController = new TextEditingController();
  List<TextEditingController> keyNameController = new List<TextEditingController>();

  @override
  void initState() {
    super.initState();
    translation = new IntlNewScreenWizard(context);
    screenNameTextController.addListener(() {    viewModel.screenName = screenNameTextController.text;});
    //get screen dimensions
    screenHeightTextController.addListener(() {    viewModel.screenHeight = double.parse(screenHeightTextController.text);});
    screenWidthTextController.addListener(() {    viewModel.screenWidth = double.parse(screenWidthTextController.text);});
  }

  @override
  void dispose() {
    screenNameTextController.dispose();
    for (var value in keyNameController) {
      value.dispose();
    }
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
        if (currentView >= 1) { //save
          _save();
        } else {
          if (screenNameTextController.text.isEmpty) {
            Fluttertoast.showToast(msg: translation.text(NewScreenWizardText.errorEnterScreenName));
          } else {
            setState(() {
              currentView++;
            });
          }
        }
      },
      backgroundColor: Theme.of(context).primaryColor,
      label: Text(text)
    );
  }

  Future<void> _save() async {
    //add in the text
    for (int i=0; i < keyNameController.length; i++) {
      viewModel.controls[i].text = keyNameController[i].text;
    }

    if (double.parse(screenHeightTextController.text) > 0)
      viewModel.screenHeight = double.parse(screenHeightTextController.text);
    if (double.parse(screenWidthTextController.text) > 0)
      viewModel.screenWidth = double.parse(screenWidthTextController.text);

    await _bloc.saveScreen(viewModel);

    //now lets get out of here
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      SystemNavigator.pop();
    }
  }
}
