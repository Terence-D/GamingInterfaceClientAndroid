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
    'ActivatorType': activatorType,
    'Key': key,
    'Modifier': modifiers
  };

  factory Command.fromJson(Map<String, dynamic> json) {
    if (json['Modifier'] == null) {
      json['Modifier'] = [];
    }
    var jsonMods = json['Modifier'];
    List<String> mods = List<String>.from(jsonMods);
    String jsonKey = json['Key'];
    int jsonActivator = json['ActivatorType'];

    return Command(
      key: jsonKey,
      modifiers: mods,
      activatorType: jsonActivator
    );
  }

}
