class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  static const int homePostsLimit = 6;
  static const int postsPageSize = 12;
  static const int chatPostOptionsLimit = 100;
}
