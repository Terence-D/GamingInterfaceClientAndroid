class Command {
  static const int KEY_DOWN = 0;
  static const int KEY_UP = 1;

  String key = "a";
  List<String> modifiers = new List<String>();
  int activatorType; //key down, key up, etc

  Command ({key, modifiers, activatorType});

  Command.fromMappedJson(Map<String, dynamic> json)
      : key = json['key'],
        modifiers = json['modifiers'],
        activatorType = json['activtorType'];

  Map<String, dynamic> toJson() =>
  {
    'activatorType': activatorType,
    'key': key,
    'modifiers': modifiers
  };

  factory Command.fromJson(Map<String, dynamic> json) {
    return Command(
      key: json['key'],
      modifiers: json['modifiers'],
      activatorType: json['activtorType']
    );
  }

}
