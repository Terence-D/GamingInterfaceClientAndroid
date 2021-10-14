enum DonateText {
  toolbarTitle,
  intro,
  title,
  details,
  note,
  thankyou,
  refresh,
  button,
  tryingToConnect,
  notConnected,
  unableToPurchase,
  searching,
  donationOptions,
  restorePurchase
}

class IntlDonate {
  static Map<String, Map<DonateText, String>> localizedStrings = {
    'en': {
      DonateText.toolbarTitle: 'Donation',
      DonateText.title: 'Support Me',
      DonateText.intro:
          'GIC on android will remain free and open source, and you can find more details at the link below! However, if you like the work that I\'ve done and would like to support continued development and features, you can send me a donation using one of the options below! As a small way of saying thank you, you will also see a icon on the main screen showing off your support!',
      DonateText.thankyou: 'Thank you - Terence',
      DonateText.button: 'More Information on GIC',
      DonateText.refresh: 'Refresh Purchases',
      DonateText.tryingToConnect: 'Trying to connect...',
      DonateText.notConnected: 'Not connected',
      DonateText.unableToPurchase:
          'Unable to complete purchase.  Please try later, or contact the Developer.',
      DonateText.searching: 'Searching...',
      DonateText.donationOptions: 'Donation Options',
      DonateText.restorePurchase: 'Restore purchases'
    }
  };
}
