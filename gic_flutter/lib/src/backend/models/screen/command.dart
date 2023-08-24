class Command {
  static const int KEY_DOWN = 0;
  static const int KEY_UP = 1;

  String? key = "A";
  List<String>? modifiers = [];
  int? activatorType = 0; //key down, key up, etc

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
    if (json['modifier'] == null && json['Modifier'] == null) {
      json['modifier'] = [];
    }

    //handle both case possibilities
    var jsonMods;
    List<String> mods = [];
    if (json.containsKey('modifier'))
      jsonMods = json['modifier'];
    else if (json.containsKey('Modifier'))
      jsonMods = json['Modifier'];
    if (jsonMods != null)
      mods = List<String>.from(jsonMods);

    String jsonKey = "";
    if (json.containsKey('key'))
      jsonKey = json['key'];
    else if (json.containsKey('Key'))
      jsonKey = json['Key'];

    int jsonActivator=0;
    if (json.containsKey('activatorType'))
      jsonActivator = json['activatorType'];
    else if (json.containsKey('ActivatorType'))
      jsonActivator = json['ActivatorType'];

    return Command(
      key: jsonKey,
      modifiers: mods,
      activatorType: jsonActivator
    );
  }

}
