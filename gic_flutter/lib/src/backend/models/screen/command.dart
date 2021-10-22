class Command {
  static const int KEY_DOWN = 0;
  static const int KEY_UP = 1;

  String key = "A";
  List<String> modifiers = [];
  int activatorType = 0; //key down, key up, etc

  Command.empty();

  Command ({this.key, this.modifiers, this.activatorType}) {
    if (this.modifiers == null) {
      this.modifiers = [];
    }
  }

  Map<String, dynamic> toJson() =>
  {
    'activatorType': activatorType,
    'key': key,
    'modifier': modifiers
  };

  factory Command.fromJson(Map<String, dynamic> json) {
    if (json['modifier'] == null) {
      json['modifier'] = [];
    }
    var jsonMods = json['modifier'];
    List<String> mods = List<String>.from(jsonMods);
    String jsonKey = json['key'];
    int jsonActivator = json['activatorType'];

    return Command(
      key: jsonKey,
      modifiers: mods,
      activatorType: jsonActivator
    );
  }

}
