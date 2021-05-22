import 'dart:collection';

class AutoItKeyMap {
  Map<String, String> map = LinkedHashMap();

  AutoItKeyMap() {
    //add every char in the english alphabet
    int c = "A".codeUnitAt(0);
    int end = "Z".codeUnitAt(0);
    while (c <= end) {
      map[String.fromCharCode(c)] = String.fromCharCode(c);
      c++;
    }

    for (int number = 0; number <= 9; number++) {
      map[number.toString()] = number.toString();
    }
    for (int number = 0; number <= 9; number++) {
      map["NUMPAD $number"] = "Numpad $number";
    }
    map["NUMPADMULT"] = "Numpad *";
    map["NUMPADADD"] = "Numpad +";
    map["NUMPADSUB"] = "Numpad -";
    map["NUMPADDIV"] = "Numpad /";
    map["NUMPADDOT"] = "Numpad .";
    map["NUMPADENTER"] = "Numpad Enter";

    for (int number = 0; number <= 12; number++) {
      map["F$number"] = "F$number";
    }

    map["`"] = "~/`";
    map["!"] = "!";
    map["@"] = "@";
    map["#"] = "#";
    map["\$"] = "\$";
    map["%"] = "%";
    map["^"] = "^";
    map["&"] = "&";
    map["*"] = "*";
    map["("] = "(";
    map[")"] = ")";
    map["-"] = "- / _";
    map["="] = "= / +";
    map["["] = "[ / {";
    map["]"] = "] / }";
    map["\\"] = "\\ / |";
    map[";"] = "; / :";
    map["'"] = "' / ";
    map[","] = "] = / <";
    map["."] = ". / >";
    map["/"] = "/ / ?";

    map["SPACE"] = "Space";
    map["ENTER"] = "Enter";
    map["BACKSPACE"] = "Backspace";
    map["DELETE"] = "Delete";
    map["UP"] = "Up arrow";
    map["DOWN"] = "Down arrow";
    map["LEFT"] = "Left arrow";
    map["RIGHT"] = "Right arrow";
    map["HOME"] = "Home";
    map["END"] = "End";
    map["ESCAPE"] = "Escape";
    map["INSERT"] = "Insert";
    map["PGUP"] = "Page Up";
    map["PGDN"] = "Page Down";
    map["TAB"] = "Tab Key";
    map["PRINTSCREEN"] = "Print Screen";
    map["LWIN"] = "Left Windows key";
    map["RWIN"] = "Right Windows key";
    map["NUMLOCK"] = "Numlock";
    map["CAPSLOCK"] = "Capslock";
    map["SCROLLLOCK"] = "Scroll Lock";
    map["BREAK"] = "Ctrl+Break ";
    map["PAUSE"] = "Pause";
    map["APPSKEY"] = "Windows App key";
    //this seems unnecessary?? map["SLEEP"] = "	Computer SLEEP key";
    //map["LWINDOWN"] = "	Holds the left Windows key down until map["LWINUP"] = "is sent";
    //map["RWINDOWN"] = "	Holds the right Windows key down until map["RWINUP"] = "is sent";

    map["VOLUME_MUTE"] = "Mute the volume";
    map["VOLUME_DOWN"] = "Reduce the volume";
    map["VOLUME_UP"] = "Increase the volume";
    map["MEDIA_NEXT"] = "Select next track in media player";
    map["MEDIA_PREV"] = "Select previous track in media player";
    map["MEDIA_STOP"] = "Stop media player";
    map["MEDIA_PLAY_PAUSE"] = "Play/pause media player";
  }
}