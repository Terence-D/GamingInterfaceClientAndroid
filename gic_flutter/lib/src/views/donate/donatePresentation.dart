import 'package:flutter/cupertino.dart';
import 'package:gic_flutter/src/backend/models/intl/intlDonate.dart';
import 'package:gic_flutter/src/backend/models/intl/localizations.dart';
import 'package:gic_flutter/src/views/basePage.dart';

import 'donateVM.dart';

class DonatePresentation implements BasePresentation {
  BaseState _contract;

  DonatePresentation(BaseState contract) {
    _contract = contract;
  }

  Future<void> buildVM(BuildContext context) async {
    DonateVM _viewModel = DonateVM();

    _viewModel.toolbarTitle = Intl.of(context).donate(DonateText.toolbarTitle);
    _viewModel.intro = Intl.of(context).donate(DonateText.intro);
    _viewModel.title = Intl.of(context).donate(DonateText.title);
    _viewModel.request = Intl.of(context).donate(DonateText.request);
    _viewModel.details = Intl.of(context).donate(DonateText.details);
    _viewModel.note = Intl.of(context).donate(DonateText.note);
    _viewModel.thankyou = Intl.of(context).donate(DonateText.thankyou);
    _viewModel.button = Intl.of(context).donate(DonateText.button);

    _contract.onLoadComplete(_viewModel);
  }
}
