import 'package:flutter/material.dart';
import 'package:gic_flutter/model/intl/localizations.dart';
import 'package:gic_flutter/screens/intro/introPresentation.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroView extends StatefulWidget {
  
  const IntroView({Key key}) : super(key: key);

  @override
  IntroViewState createState() {
    return IntroViewState();
  }
}

class IntroViewState extends State<IntroView> implements IntroViewContract {
  List<PageViewModel> _pages;

  @override
  void initState() {
    super.initState();

    new IntroPresentation(this).loadPages(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_pages == null) {
      return new Stack(
        children: [
          new Opacity(
            opacity: 0.3,
            child: const ModalBarrier(dismissible: false, color: Colors.grey),
          ),
          new Center(
            child: new CircularProgressIndicator(),
          ),
        ],
      );
    } else {
      return IntroductionScreen(
        pages: _pages,
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

  void _onIntroEnd(context) {
    Navigator.pop(context);
  }

  @override
  void onIntroLoadCompleted(List<PageViewModel> pages) {
    _pages = pages;
  }
}

