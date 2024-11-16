import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:gic_flutter/src/backend/models/viewModel.dart';
import 'package:gic_flutter/src/backend/models/viewSection.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class BasePresentation {
  void buildVM(BuildContext context);
}

abstract class BasePage extends StatefulWidget {
  BasePage({Key? key}) : super(key: key);
}

abstract class BaseState<Page extends BasePage> extends State<Page> with WidgetsBindingObserver {
  BasePresentation? presentation;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    presentation?.buildVM(context);
    super.didChangeDependencies();
  }

//  void onLoadComplete(ViewModel viewModel);
//
//  void onError(int errorType);
//
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Widget section(ViewSection model, {TextStyle? optionalHeaderStyle, bool centered = false}) {
    var align = CrossAxisAlignment.start;
    if (centered) {
      align = CrossAxisAlignment.center;
    }
    return
      Column(
          crossAxisAlignment: align,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 2),
              child: header(model.title, optionalHeaderStyle),
            ),
            Text(model.text),
            link(model.url)]
      );
  }

  Widget link(String link) {
    return Linkify(
        onOpen: (link) async {
          if (await canLaunch(link.url)) {
            await launch(link.url);
          } else {
            throw 'Could not launch $link';
          }
        },
        text: link
    );
  }

  Widget header(String text, [TextStyle? textStyle]) {
    if (textStyle == null) {
      textStyle = Theme.of(context).textTheme.headlineSmall;
    }
    return Text(
      text,
      style: textStyle,
    );
  }

  void onLoadComplete(ViewModel viewModel) {}

  void onError(int i) {}
}