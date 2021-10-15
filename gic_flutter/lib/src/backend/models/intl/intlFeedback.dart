enum FeedbackText {
  toolbarTitle,
  details,
  updown,
  email,
  emailTo,
  satisfaction,
  githubIssues,
  githubIssuesUrl,
}

class IntlFeedback {
  static Map<String, Map<FeedbackText, String>> localizedStrings = {
    'en': {
      FeedbackText.toolbarTitle: 'Feedback',
      FeedbackText.details:
          'Got an idea for a feature you want?  See something you hate?  Feedback is always appreciated!  You can open an issue directly on GitHub (3rd party website, link below), or if you prefer send me an email.  Although I will not share any information sent, please ensure you do not include any sensitive information, this is just a hobby not a business!',

      FeedbackText.githubIssues: 'Github Issue Tracker',
      FeedbackText.githubIssuesUrl: 'https://github.com/Terence-D/GamingInterfaceClientAndroid/issues',

      FeedbackText.satisfaction: 'Satisfaction',
      FeedbackText.updown:
          'Tap on one of the images below (optionally) to quickly provide a thumbs up or down!',
      FeedbackText.email: 'Send Feedback',
      FeedbackText.emailTo: 'mailto:support@coffeeshopstudio.ca?subject=GIC',
    }
  };
}
