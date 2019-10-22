class Command {
  static const int KEY_DOWN = 0;
  static const int KEY_UP = 1;
  String key = "a";
  List<String> modifier = new List<String>();
  int activatorType; //key down, key up, etc
}
