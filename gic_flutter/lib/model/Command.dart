class Command {
  static const int KEY_DOWN = 0;
  static const int KEY_UP = 1;

  String key = "a";
  List<String> modifier = new List<String>();
  int activatorType; //key down, key up, etc

  Command (key, modifier, activatorType);

  Command.fromMappedJson(Map<String, dynamic> json)
      : key = json['key'],
        modifier = json['modifier'],
        activatorType = json['activtorType'];

  Map<String, dynamic> toJson() =>
  {
    'activatorType': activatorType,
    'key': key,
    'modifier': modifier
  };

}
