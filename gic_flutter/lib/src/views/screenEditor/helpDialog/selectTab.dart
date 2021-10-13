import 'package:flutter/material.dart';

/// This class shows a very simple tab containing a title and details below it.
class SimpleTextTab extends StatefulWidget {
  final String title;
  final String details;

  SimpleTextTab({Key key, this.title, this.details}) : super(key: key);

  @override
  _SimpleTextTabState createState() => _SimpleTextTabState();
}

class _SimpleTextTabState extends State<SimpleTextTab> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: LayoutBuilder(
          builder: (BuildContext ctx, BoxConstraints constraints) {
        return Column(
          children: [
            Text(widget.title,
                style: Theme.of(context).textTheme.headline5),
            Text(widget.details)
          ],
        );
      }),
    );
  }
}
