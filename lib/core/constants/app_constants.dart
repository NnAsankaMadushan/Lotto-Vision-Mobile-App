class AppConstants {
  // App Info
  static const String appName = 'LottoVision';
  static const String appVersion = '1.0.0';

  // API Endpoints (Sri Lankan Lottery Results)
  static const String nlbBaseUrl = 'https://www.nlb.lk';
  static const String resultsEndpoint = '/english/results/';

  // Local Storage Keys
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';
  static const String userKey = 'user_data';

  // Hive Box Names
  static const String ticketsBox = 'tickets';
  static const String resultsBox = 'results';
  static const String settingsBox = 'settings';

  // Image Processing
  static const double maxImageSize = 1920.0;
  static const int jpegQuality = 85;
  static const double ocrConfidenceThreshold = 0.7;

  // Animation Durations
  static const int animationDuration = 300;
  static const int splashDuration = 2000;

  // Pagination
  static const int ticketsPerPage = 20;
  static const int resultsPerPage = 10;
}

class ValidationConstants {
  static const int minTicketNumberLength = 6;
  static const int maxTicketNumberLength = 10;
  static const int minDrawNumber = 1;
  static const int maxDrawNumber = 10000;
}
