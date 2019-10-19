import 'package:flutter/material.dart';
import 'package:gic_flutter/model/intl/localizations.dart';
import 'package:gic_flutter/screens/intro/introPresentation.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnBoardingPage extends StatelessWidget {
  final IntroPresentation presentation;
  final List<PageViewModel> pages;

  const OnBoardingPage({Key key, this.presentation, this.pages}) : super(key: key);

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

class ScreenList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 100.0,
        height: 200.0,
        child: _myListView(context),
      );
  }
}
class BodyLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _myListView(context);
  }
}

// replace this function with the code in the examples
Widget _myListView(BuildContext context) {
  return ListView(
    children: ListTile.divideTiles(
      context: context,
      tiles: [
        ListTile(
          title: Text('SC'),
        ),
        ListTile(
          title: Text('Elite'),
        ),
        ListTile(
          title: Text('Truck'),
        ),
      ],
    ).toList(),
  );
}


class ScreenSizeWidget extends StatefulWidget {
  ScreenSizeWidget({Key key}) : super(key: key);
  @override
  _ScreenSizeWidgetState createState() => _ScreenSizeWidgetState();
}

class _ScreenSizeWidgetState extends State<ScreenSizeWidget> {
  List<String> dropdownItems = <String>['Phone', 'Small Tablet', 'Large Tablet'];
  String dropdownValue;
  _ScreenSizeWidgetState() {
    dropdownValue = dropdownItems[0];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150.0,
      height: 100.0,
      child: Center(
        child: getDropdown()
      ),
    );
  }

  DropdownButton getDropdown() {
    return DropdownButton<String>(
      value: dropdownValue,
      elevation: 16,
      underline: Container(
        height: 2,
      ),
      onChanged: (String newValue) {
        setState(() {
          dropdownValue = newValue;
        });
      },
      items: dropdownItems.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
