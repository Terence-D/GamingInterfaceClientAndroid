import 'package:flutter/material.dart';

/// This class shows a very simple tab containing a title and details below it.
class SimpleTextTab extends StatefulWidget {
  final String title;
  final String details;

  SimpleTextTab({Key? key, required this.title, required this.details}) : super(key: key);

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
                style: Theme.of(context).textTheme.headlineSmall),
            Divider(
              height: 10,
              thickness: 2,
            ),
            Text(widget.details, textScaleFactor: 1.2,)
          ],
        );
      }),
    );
  }
}
