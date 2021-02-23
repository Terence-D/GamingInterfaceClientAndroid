import 'dart:ui';

class Font {
  int version;
  Color color;
  double size = 36;
  String family;

  Font({this.color, this.size, this.family});

  Font.fromJson(Map<String, dynamic> json)
      : version = json['version'],
        color = new Color(json['color']),
        size = json['size'],
        family = json['family'];

  Map<String, dynamic> toJson() => {
        'version': 2,
        'color': color.value,
        'size': size,
        'family': family
      };
}
