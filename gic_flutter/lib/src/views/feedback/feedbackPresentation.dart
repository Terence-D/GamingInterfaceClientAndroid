import 'package:flutter/cupertino.dart';
import 'package:gic_flutter/src/backend/models/intl/intlFeedback.dart';
import 'package:gic_flutter/src/backend/models/intl/localizations.dart';
import 'package:gic_flutter/src/views/basePage.dart';

import 'feedbackVM.dart';

class FeedbackPresentation implements BasePresentation {
  BaseState _contract;

  FeedbackPresentation(BaseState contract) {
    _contract = contract;
  }

  Future<void> buildVM(BuildContext context) async {
    FeedbackVM _viewModel = FeedbackVM();

    _viewModel.toolbarTitle =
        Intl.of(context).feedback(FeedbackText.toolbarTitle);
    _viewModel.details = Intl.of(context).feedback(FeedbackText.details);
    _viewModel.updown = Intl.of(context).feedback(FeedbackText.updown);
    _viewModel.email = Intl.of(context).feedback(FeedbackText.email);
    _viewModel.emailTo = Intl.of(context).feedback(FeedbackText.emailTo);

    _contract.onLoadComplete(_viewModel);
  }
}
