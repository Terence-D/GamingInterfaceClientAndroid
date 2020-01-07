enum AboutText {
  toolbarTitle,
  versionText,
  libraryTitle,
  emailTo,
  legalTitle,
  legalText,
  legalUrl,
  url,
  serverTitle,
  serverText,
  serverUrl,
  cryptoTitle,
  cryptoText,
  cryptoUrl,
  colorTitle,
  colorText,
  colorUrl,
  permissionsTitle,
  permissionsText,
  permissionsUrl,
  onboardingTitle,
  onboardingText,
  onboardingUrl,
  helpTitle,
  helpText,
  helpUrl
}

class IntlAbout {
  static Map<String, Map<AboutText, String>> localizedStrings = {
    'en': {
      AboutText.toolbarTitle: 'About',
      AboutText.versionText: 'Version: %s (build %s)',
      AboutText.emailTo: 'mailto:support@coffeeshopstudio.ca?subject=GIC',
      AboutText.url: 'https://github.com/Terence-D/GamingInterfaceClientAndroid/wiki',

      AboutText.legalTitle: 'Legal',
      AboutText.legalText: 'GIC Client (this software) and the GIC Server are open source products and combined are used to act as a remote control style device for your PC.  Copyright 2019 Terence Doerksen',
      AboutText.legalUrl: 'http://www.apache.org/licenses/LICENSE-2.0',

      AboutText.serverTitle: 'Server',
      AboutText.serverText: 'To use this you need to run GIC Server (also Open Source) on your Windows computer where the game resides.  Please visit the link below for further information',
      AboutText.serverUrl: 'https://github.com/Terence-D/GameInputCommandServer',

      AboutText.libraryTitle: '3rd Party Libraries',
      AboutText.cryptoTitle: 'Encryption library by Mataprasad',
      AboutText.cryptoText: 'Licensed under the MIT License.  See below for details',
      AboutText.cryptoUrl: 'https://github.com/mataprasad/Cross-platform-AES-encryption-128bit/blob/master/LICENSE',
      AboutText.colorTitle: 'Color Picker',
      AboutText.colorText: 'Licensed under the Apache 2.0 license.  See below for details',
      AboutText.colorUrl: 'https://android-arsenal.com/details/1/1693',
      AboutText.permissionsTitle: 'Easy Permissions Library',
      AboutText.permissionsText: 'Licensed under the Apache 2.0 License.  See below for details',
      AboutText.permissionsUrl: 'https://github.com/googlesamples/easypermissions',
      AboutText.onboardingTitle: 'Material Intro',
      AboutText.onboardingText: 'Licensed under the MIT License.  See below for details',
      AboutText.onboardingUrl: 'https://github.com/heinrichreimer/material-intro#left-back-button',
      AboutText.helpTitle: 'Material Tap Target Prompt',
      AboutText.helpText: 'Licensed under the Apache 2.0 License.  See below for details',
      AboutText.helpUrl:'https://github.com/sjwall/MaterialTapTargetPrompt'
    }
  };
}
