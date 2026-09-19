class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    // defaultValue: 'http://localhost:3100',
    defaultValue: 'https://vactrackerintership-production.up.railway.app',
  );
}
