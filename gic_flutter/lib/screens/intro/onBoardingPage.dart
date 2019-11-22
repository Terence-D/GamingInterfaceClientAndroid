import 'package:flutter/material.dart';
import 'package:gic_flutter/model/intl/localizations.dart';
import 'package:gic_flutter/screens/main/mainPresentation.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnBoardingPage extends StatelessWidget {
  //final IntroPresentation presentation;
  final List<PageViewModel> pages;
  
  const OnBoardingPage({Key key, this.pages}) : super(key: key); 

  void _onIntroEnd(context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: pages,
      onDone: () => _onIntroEnd(context),
      //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: true,
      skipFlex: 0,
      nextFlex: 0,
      skip: Text(Intl.of(context).onboardSkip),
      next: const Icon(Icons.arrow_forward),
      done: Text(Intl.of(context).onboardDone, style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

