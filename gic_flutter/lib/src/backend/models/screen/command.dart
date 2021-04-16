class Command {
  static const int KEY_DOWN = 0;
  static const int KEY_UP = 1;

  String key = " ";
  Set<String> modifiers = new Set();
  int activatorType = 0; //key down, key up, etc

  Command.empty();

  Command ({this.key, this.modifiers, this.activatorType}) {
    if (this.modifiers == null)
      this.modifiers = new Set();
  }

  Map<String, dynamic> toJson() =>
  {
    'ActivatorType': activatorType,
    'Key': key,
    'Modifier': modifiers
  };

  factory Command.fromJson(Map<String, dynamic> json) {
    if (json['modifiers'] == null)
      json['modifiers'] = [];
    var jsonMods = json['modifiers'];
    List<String> mods = new List<String>.from(jsonMods);
    String jsonKey = json['key'];
    int jsonActivator = json['activatorType'];

    return Command(
      key: jsonKey,
      modifiers: mods.toSet(),
      activatorType: jsonActivator
    );
  }

}
