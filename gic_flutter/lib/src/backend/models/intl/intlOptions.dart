enum OptionsText {
  toolbarTitle,
  darkModeTitle,
  darkModeText,
  soundTitle,
  soundText,
  vibrationTitle,
  vibrationText,
  keepScreenOnTitle,
  keepScreenOnText,
}

class IntlOptions {
  static Map<String, Map<OptionsText, String>> localizedStrings = {
    'en': {
      OptionsText.toolbarTitle: 'Options',
      OptionsText.darkModeTitle: 'Dark Mode',
      OptionsText.darkModeText:
          'Enable this for the Dark Theme, disable this for the Light Theme',
      OptionsText.soundTitle: 'Sound',
      OptionsText.soundText:
          'Enable this an audio sound to be played when a Button or Toggle is activated.  Ensure audio is not muted on your device before enabling!',
      OptionsText.vibrationTitle: 'Vibration',
      OptionsText.vibrationText:
          'Enable this for the device to perform a light vibration when a Button or Toggle is activated',
      OptionsText.keepScreenOnTitle: 'Keep Screen On',
      OptionsText.keepScreenOnText:
          'Enable this to keep the screen on when in game',
    }
  };
}
