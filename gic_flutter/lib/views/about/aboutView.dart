import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:gic_flutter/theme/dimensions.dart' as dim;
import 'package:url_launcher/url_launcher.dart';

import 'AboutVM.dart';
import 'aboutPresentation.dart';

class AboutView extends StatefulWidget {
  AboutView({Key key}) : super(key: key); // {}

  @override
  AboutViewState createState() {
    return AboutViewState();
  }
}

class AboutViewState extends State<AboutView> with WidgetsBindingObserver implements AboutViewContract {
  AboutPresentation _presentation;
  AboutVM _viewModel = new AboutVM();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();

    _presentation = new AboutPresentation(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


  @override
  void didChangeDependencies() {
      _presentation.buildVM(context);
      super.didChangeDependencies();
  }

  @override
  void onLoadComplete(AboutVM viewModel) {
    setState(() {
      this._viewModel = viewModel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text(_viewModel.toolbarTitle),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(dim.activityMargin),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(_viewModel.versionText),
                _link(_viewModel.url),
                _section(_viewModel.server),
                _header(_viewModel.libraryTitle),
                _section(_viewModel.legal),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton (
          onPressed: () {
          },
          child: Icon(Icons.email)
        )); //
  }

  Widget _section(AboutModel model) {
    return
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>
        [_header(model.title),
          Text(
            model.text,
          ),
          _link(model.url)]
      );
  }

  Widget _link(String link) {
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

  Widget _header(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.headline,
    );
  }
}
