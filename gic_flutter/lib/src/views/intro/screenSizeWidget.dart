import 'package:flutter/material.dart';

class ScreenSizeWidget extends StatefulWidget {
  final Function(String) onSelectParam;

  ScreenSizeWidget(this.onSelectParam, {Key? key}) : super(key: key);

  @override
  _ScreenSizeWidgetState createState() => _ScreenSizeWidgetState();
}

class _ScreenSizeWidgetState extends State<ScreenSizeWidget> {
  List<String> dropdownItems = <String>['Phone', 'Small Tablet', 'Large Tablet'];
  String device = "";
  _ScreenSizeWidgetState() {
    device = (dropdownItems[0]);
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
      value: device,
      elevation: 16,
      underline: Container(
        height: 2,
      ),
      onChanged: (String? newValue) {
        setState(() {
          device = newValue!;
          widget.onSelectParam(device);
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
