class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',

    // defaultValue: 'http://localhost:3100',

    defaultValue: 'https://vactracker-cpl9.onrender.com',
    
    // defaultValue: 'https://vactrackerintership-production.up.railway.app',
  );
}
