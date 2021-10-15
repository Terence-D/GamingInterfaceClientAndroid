import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gic_flutter/src/backend/models/viewModel.dart';
import 'package:gic_flutter/src/theme/dimensions.dart' as dim;
import 'package:gic_flutter/src/views/feedback/feedbackVM.dart';
import 'package:url_launcher/url_launcher.dart';

import '../basePage.dart';
import 'FeedbackPresentation.dart';

class FeedbackView extends BasePage {
  @override
  FeedbackViewState createState() {
    return FeedbackViewState();
  }
}

class FeedbackViewState extends BaseState<FeedbackView> {
  FeedbackVM viewModel = FeedbackVM();
  String feedback = "";

  @override
  void initState() {
    presentation = FeedbackPresentation(this);
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
    String title = " ";
    if (viewModel != null && viewModel.toolbarTitle != null) {
      title = viewModel.toolbarTitle;
    }
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
                Text(viewModel.details),
                Text(viewModel.updown),
                Row(
                  children: [
                    IconButton(
                        onPressed: _pickSatisfaction(" :)"),
                        icon: Icon(Icons.sentiment_satisfied)),
                    IconButton(
                        onPressed: _pickSatisfaction(" :|"),
                        icon: Icon(Icons.sentiment_neutral)),
                    IconButton(
                        onPressed: _pickSatisfaction(" :("),
                        icon: Icon(Icons.sentiment_dissatisfied)),
                  ],
                ),
                IconButton(
                    onPressed: _sendEmail(viewModel.emailTo),
                    icon: Icon(Icons.email))
              ],
            ),
          ),
        ));
  }

  _sendEmail(email) async {
    if (await canLaunch(email)) {
      await launch("$email$feedback");
    } else {
      throw 'Could not launch $link';
    }
  }

  _pickSatisfaction(String satisfaction) {
    feedback = satisfaction;
  }

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
