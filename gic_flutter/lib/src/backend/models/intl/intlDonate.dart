enum DonateText {
  toolbarTitle,
  intro,
  title,
  request,
  details,
  note,
  thankyou,
  button
}

class IntlDonate {
  static Map<String, Map<DonateText, String>> localizedStrings = {
    'en': {
      DonateText.toolbarTitle: 'About',
      DonateText.intro: 'Version: ',
      DonateText.title: 'mailto:support@coffeeshopstudio.ca?subject=GIC',
      DonateText.request: 'https://github.com/Terence-D/GamingInterfaceClientAndroid/wiki',

      DonateText.details: 'Legal',
      DonateText.note: 'GIC Client (this software) and the GIC Server are open source products and combined are used to act as a remote control style device for your PC.  Copyright 2020 Terence Doerksen',
      DonateText.thankyou: 'http://www.apache.org/licenses/LICENSE-2.0',

      DonateText.button: 'Server',
    }
  };
}
