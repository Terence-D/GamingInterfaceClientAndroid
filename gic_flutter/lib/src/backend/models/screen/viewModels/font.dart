import 'dart:ui';

class Font {
  Color color;
  double size = 36;
  String family;

  Font({this.color, this.size, this.family});

  Font.fromJson(Map<String, dynamic> json)
      : color = new Color(int.parse(json['color'])),
        size = json['size'],
        family = json['family'];

  Map<String, dynamic> toJson() => {
        'version': "2",
        'type': color.value,
        'size': size,
        'family': family
      };
}
