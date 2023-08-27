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
  String _feedback = "";
  List<bool> _isSelected = [false, false, false];

  @override
  void initState() {
    presentation = FeedbackPresentation(this);
    super.initState();
  }

  @override
  void onLoadComplete(ViewModel viewModel) {
    setState(() {
      this.viewModel = viewModel as FeedbackVM;
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
                ElevatedButton(
                  child: Text(viewModel.githubIssues),
                  onPressed: () async {
                  String url =
                      viewModel.githubIssuesUrl;
                  if (await canLaunch(url))
                    await launch(url);
                  else
                    // can't launch url, there is some error
                    throw "Could not launch $url";
                },),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0,32,0,0),
                  child: header(viewModel.satisfaction),
                ),
                Text(viewModel.updown),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32.0, 0, 32.0, 0),
                  child: ToggleButtons(
                    children: <Widget>[
                      Icon(Icons.sentiment_satisfied, size: 64),
                      Icon(Icons.sentiment_neutral, size: 64),
                      Icon(Icons.sentiment_dissatisfied, size: 64),
                    ],
                    onPressed: (int index) {
                      setState(() {
                        for (int buttonIndex = 0; buttonIndex < _isSelected.length; buttonIndex++) {
                          if (buttonIndex == index) {
                            _isSelected[buttonIndex] = true;
                          } else {
                            _isSelected[buttonIndex] = false;
                          }
                        }
                        _pickSatisfaction();
                      });
                    },
                    isSelected: _isSelected,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: ElevatedButton(
                      // onPressed: ,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(viewModel.email),
                          Padding(padding: const EdgeInsets.all(8.0)),
                          Icon(Icons.email),
                        ],
                      ), onPressed: () {
                    _sendEmail(viewModel.emailTo);
                  },),
                )
              ],
            ),
          ),
        ));
  }

  _sendEmail(email) async {
    if (await canLaunch(email)) {
      await launch("$email$_feedback");
    } else {
      throw 'Could not launch $link';
    }
  }

  _pickSatisfaction() {
    if (_isSelected[0])
      _feedback = " :)";
    else     if (_isSelected[1])
      _feedback = " :|";
    else
      _feedback = " :(";
  }

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
