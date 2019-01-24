package ca.coffeeshopstudio.gaminginterfaceclient.models;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * TODO: HEADER COMMENT HERE.
 */
public class AutoItKeyMap {

    private Map<String, String> map = new LinkedHashMap<>();

    public AutoItKeyMap() {
        for (char letter = 'A'; letter <= 'Z'; letter++) {
            map.put(String.valueOf(letter), String.valueOf(letter));
        }
        for (int number = 0; number <= 9; number++) {
            map.put(String.valueOf(number), String.valueOf(number));
        }
        for (int number = 0; number <= 9; number++) {
            map.put("NUMPAD" + String.valueOf(number), "Numpad " + String.valueOf(number));
        }
        map.put("NUMPADMULT", "Numpad *");
        map.put("NUMPADADD", "Numpad +");
        map.put("NUMPADSUB", "Numpad -");
        map.put("NUMPADDIV", "Numpad /");
        map.put("NUMPADDOT", "Numpad .");
        map.put("NUMPADENTER", "Numpad Enter");

        for (int number = 0; number <= 12; number++) {
            map.put("F" + String.valueOf(number), "F" + String.valueOf(number));
        }

        map.put("`", "~/`");
        map.put("!", "!");
        map.put("@", "@");
        map.put("#", "#");
        map.put("$", "$");
        map.put("%", "%");
        map.put("^", "^");
        map.put("&", "&");
        map.put("*", "*");
        map.put("(", "(");
        map.put(")", ")");
        map.put("-", "- / _");
        map.put("=", "= / +");
        map.put("[", "[ / {");
        map.put("]", "] / }");
        map.put("\\", "\\ / |");
        map.put(";", "; / :");
        map.put("'", "' / ");
        map.put(",", ", / <");
        map.put(".", ". / >");
        map.put("/", "/ / ?");

        map.put("SPACE", "Space");
        map.put("ENTER", "Enter");
        map.put("BACKSPACE", "Backspace");
        map.put("DELETE", "Delete");
        map.put("UP", "Up arrow");
        map.put("DOWN", "Down arrow");
        map.put("LEFT", "Left arrow");
        map.put("RIGHT", "Right arrow");
        map.put("HOME", "Home");
        map.put("END", "End");
        map.put("ESCAPE", "Escape");
        map.put("INSERT", "Insert");
        map.put("PGUP", "Page Up");
        map.put("PGDN", "Page Down");
        map.put("TAB", "Tab Key");
        map.put("PRINTSCREEN", "Print Screen");
        map.put("LWIN", "Left Windows key");
        map.put("RWIN", "Right Windows key");
        map.put("NUMLOCK", "Numlock");
        map.put("CAPSLOCK", "Capslock");
        map.put("SCROLLLOCK", "Scroll Lock");
        map.put("BREAK", "Ctrl+Break ");
        map.put("PAUSE", "Pause");
        map.put("APPSKEY", "Windows App key");
        //this seems unnecessary?? map.put("SLEEP", "	Computer SLEEP key");
        //map.put("LWINDOWN", "	Holds the left Windows key down until map.put("LWINUP", "is sent");
        //map.put("RWINDOWN", "	Holds the right Windows key down until map.put("RWINUP", "is sent");

        map.put("VOLUME_MUTE", "Mute the volume");
        map.put("VOLUME_DOWN", "Reduce the volume");
        map.put("VOLUME_UP", "Increase the volume");
        map.put("MEDIA_NEXT", "Select next track in media player");
        map.put("MEDIA_PREV", "Select previous track in media player");
        map.put("MEDIA_STOP", "Stop media player");
        map.put("MEDIA_PLAY_PAUSE", "Play/pause media player");
    }

    public Map<String, String> getKeys() {
        return map;
    }
}
