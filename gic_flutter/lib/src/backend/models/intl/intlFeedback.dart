enum FeedbackText {
  toolbarTitle,
  details,
  updown,
  email,
  emailTo,
}

class FeedbackDonate {
  static Map<String, Map<FeedbackText, String>> localizedStrings = {
    'en': {
      FeedbackText.toolbarTitle: 'Feedback',
      FeedbackText.details:
          'Feedback is always appreciated!  This will send feedback via an email - I do not share any information provided with anyone else, this is just a hobby not a business!',
      FeedbackText.updown:
          'Tap on one of the images below (optinally) to quickly provide a thumbs up or down!',
      FeedbackText.email: 'Send Email',
      FeedbackText.emailTo: 'mailto:support@coffeeshopstudio.ca?subject=GIC',
    }
  };
}
