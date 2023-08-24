import 'package:flutter/cupertino.dart';
import 'package:gic_flutter/src/backend/models/intl/intlFeedback.dart';
import 'package:gic_flutter/src/backend/models/intl/localizations.dart';
import 'package:gic_flutter/src/views/basePage.dart';

import 'feedbackVM.dart';

class FeedbackPresentation implements BasePresentation {
  BaseState _contract;

  FeedbackPresentation(this._contract);

  Future<void> buildVM(BuildContext context) async {
    FeedbackVM _viewModel = FeedbackVM();

    _viewModel.toolbarTitle =
        Intl.of(context)!.feedback(FeedbackText.toolbarTitle);
    _viewModel.details = Intl.of(context)!.feedback(FeedbackText.details);
    _viewModel.updown = Intl.of(context)!.feedback(FeedbackText.updown);
    _viewModel.email = Intl.of(context)!.feedback(FeedbackText.email);
    _viewModel.emailTo = Intl.of(context)!.feedback(FeedbackText.emailTo);
    _viewModel.satisfaction = Intl.of(context)!.feedback(FeedbackText.satisfaction);
    _viewModel.githubIssues = Intl.of(context)!.feedback(FeedbackText.githubIssues);
    _viewModel.githubIssuesUrl = Intl.of(context)!.feedback(FeedbackText.githubIssuesUrl);

    _contract.onLoadComplete(_viewModel);
  }
}
