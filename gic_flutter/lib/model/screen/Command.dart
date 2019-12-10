class Command {
  static const int KEY_DOWN = 0;
  static const int KEY_UP = 1;

  String key = "a";
  List<String> modifiers = new List<String>();
  int activatorType; //key down, key up, etc

  Command ({this.key, this.modifiers, this.activatorType});

  Map<String, dynamic> toJson() =>
  {
    'activatorType': activatorType,
    'key': key,
    'modifiers': modifiers
  };

  factory Command.fromJson(Map<String, dynamic> json) {
    var jsonMods = json['modifiers'];
    List<String> mods = new List<String>.from(jsonMods);
    String jsonKey = json['key'];
    int jsonActivator = json['activatorType'];

    return Command(
      key: jsonKey,
      modifiers: mods,
      activatorType: jsonActivator
    );
  }

}
