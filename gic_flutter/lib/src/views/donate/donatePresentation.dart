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
    _viewModel.thankyou = Intl.of(context).donate(DonateText.thankyou);
    _viewModel.button = Intl.of(context).donate(DonateText.button);
    _viewModel.donationOptions =
        Intl.of(context).donate(DonateText.donationOptions);
    _viewModel.tryingToConnect =
        Intl.of(context).donate(DonateText.tryingToConnect);
    _viewModel.notConnected = Intl.of(context).donate(DonateText.notConnected);
    _viewModel.unableToPurchase =
        Intl.of(context).donate(DonateText.unableToPurchase);
    _viewModel.searching = Intl.of(context).donate(DonateText.searching);
    _viewModel.restorePurchases =
        Intl.of(context).donate(DonateText.restorePurchase);
    _viewModel.restoreHelp = Intl.of(context).donate(DonateText.restoreHelp);
    _contract.onLoadComplete(_viewModel);
  }
}
