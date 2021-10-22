import 'package:flutter/material.dart';

class DialogSlider extends StatefulWidget {
  DialogSlider(
      {Key key,
      this.icon,
      this.color,
      this.text,
      this.onChanged,
      this.originalValue})
      : super(key: key);

  final IconData icon;
  final Color color;
  final String text;
  final int originalValue;
  final void Function(double updated) onChanged;

  @override
  _DialogSliderState createState() => _DialogSliderState();
}

class _DialogSliderState extends State<DialogSlider> {
  double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.originalValue.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SimpleDialogOption(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 36.0, color: widget.color),
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 16.0),
                child: Text(widget.text),
              ),
            ],
          ),
        ),
        Slider(
            min: 0,
            max: 256,
            divisions: 8,
            value: _value,
            onChanged: (double newValue) {
              setState(() {
                _value = newValue;
              });
              widget.onChanged(newValue);
            }),
      ],
    );
  }
}
