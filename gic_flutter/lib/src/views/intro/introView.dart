import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gic_flutter/src/backend/models/intl/localizations.dart';
import 'package:gic_flutter/src/theme/theme.dart';
import 'package:gic_flutter/src/views/launcher/launcher.dart';
import 'package:gic_flutter/src/views/intro/introPresentation.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroView extends StatefulWidget{
  
  const IntroView({Key? key}) : super(key: key);

  @override
  IntroViewState createState() {
    return IntroViewState();
  }
}

class IntroViewState extends State<IntroView> implements IntroViewContract  {
  List<PageViewModel>? _pages;
  Color? _primaryColor;
  @override
  initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    IntroPresentation(this).loadPages(context);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
    );

    _primaryColor = CustomTheme.of(context).primaryColor;
    if (_pages == null) {
      return Stack(
        children: [
          Opacity(
            opacity: 0.3,
            child: const ModalBarrier(dismissible: false, color: Colors.grey),
          ),
          Center(
            child: CircularProgressIndicator(),
          ),
        ],
      );
    } else {
      return IntroductionScreen(
        pages: _pages,
        dotsDecorator: DotsDecorator(
          activeColor: _primaryColor,
        ),
              onDone: () => _onIntroEnd(context),
        //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
        showSkipButton: true,
        skipOrBackFlex: 0,
        nextFlex: 0,
        skip: Text(Intl.of(context)!.onboardSkip),
        next: const Icon(Icons.arrow_forward),
        done: Text(Intl.of(context)!.onboardDone, style: TextStyle(fontWeight: FontWeight.w600)),
      );
    }
  }

  @override
  void onIntroLoadCompleted(List<PageViewModel> pages) {
    setState(() {
      _pages = pages;
    });
  }

  void _onIntroEnd(context) {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => Launcher())
    );
  }
}

