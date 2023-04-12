import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gic_flutter/src/backend/blocs/newScreenWizardBloc.dart';
import 'package:gic_flutter/src/backend/models/intl/intlNewScreenWizard.dart';
import 'package:gic_flutter/src/backend/models/newScreenWizardModel.dart';

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
  NewScreenWizardModel viewModel = NewScreenWizardModel();

  //tracks if we are on the general settings view (0)
  //or the create controls view (1)
  int currentView = 0;

  final _bloc = NewScreenWizardBloc();

  final TextEditingController screenNameTextController =
      TextEditingController();
  final TextEditingController screenPrimarySizeTextController =
      TextEditingController();
  final TextEditingController screenSecondarySizeTextController =
      TextEditingController();
  List<TextEditingController> keyNameController = [];

  @override
  void initState() {
    super.initState();
    translation = IntlNewScreenWizard(context);
    screenNameTextController.addListener(() {
      viewModel.screenName = screenNameTextController.text;
    });
    screenNameTextController.text = "New Screen";
    //get screen dimensions
    screenSecondarySizeTextController.addListener(() {
      if (viewModel.isLandscape) {
        viewModel.screenHeight = double.parse(screenSecondarySizeTextController.text);
      } else {
        viewModel.screenWidth = double.parse(screenSecondarySizeTextController.text);
      }
    });
    screenPrimarySizeTextController.addListener(() {
      if (viewModel.isLandscape) {
        viewModel.screenWidth = double.parse(screenPrimarySizeTextController.text);
      } else {
        viewModel.screenHeight = double.parse(screenPrimarySizeTextController.text);
      }
    });
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
    Orientation currentOrientation = MediaQuery.of(context).orientation;
    viewModel.isLandscape = (currentOrientation == Orientation.landscape);
    return Scaffold(
        appBar: _launcherAppBar(),
        body: _mainContent(),
        floatingActionButton: _fab(context));
  }

  AppBar _launcherAppBar() {
    return AppBar(
      leading:
          Image.asset("assets/images/icons/app_icon.png", fit: BoxFit.cover),
      title: Text(translation.text(NewScreenWizardText.toolbarTitle)),
    );
  }

  /// This determines the main view to return, general settings or controls
  _mainContent() {
    if (currentView == 0) {
      return NewScreenWizardGeneral(this);
    } else {
      return NewScreenWizardControls(this);
    }
  }

  Widget _fab(BuildContext context) {
    String text = translation.text(NewScreenWizardText.next);
    if (currentView == 1) text = translation.text(NewScreenWizardText.save);

    return FloatingActionButton.extended(
        onPressed: () {
          if (currentView >= 1) {
            //save
            _save();
          } else {
            if (screenNameTextController.text.isEmpty) {
              var snackBar = SnackBar(content: Text(translation.text(NewScreenWizardText.errorEnterScreenName)));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            } else {
              setState(() {
                currentView++;
              });
            }
          }
        },
        backgroundColor: Theme.of(context).primaryColor,
        label: Text(text));
  }

  Future<void> _save() async {
    //add in the text
    for (int i = 0; i < keyNameController.length; i++) {
      viewModel.controls[i].text = keyNameController[i].text;
    }

    if (double.parse(screenSecondarySizeTextController.text) > 0) {
      viewModel.screenHeight = double.parse(screenSecondarySizeTextController.text);
    } else {
    }
    if (double.parse(screenPrimarySizeTextController.text) > 0) {
      viewModel.screenWidth = double.parse(screenPrimarySizeTextController.text);
    }

    await _bloc.saveScreen(viewModel);

    //now lets get out of here
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      await SystemNavigator.pop();
    }
  }
}
