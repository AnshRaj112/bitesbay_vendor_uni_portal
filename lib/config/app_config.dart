class AppConfig {

  // Backend URL - from environment variable or fallback
  static const String backendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://localhost:5001',
  );

  // API Endpoints - you can move these to .env if needed, but keeping them here is fine
  static const String uniLoginEndpoint = '/api/uni/auth/login';
  static const String uniRefreshEndpoint = '/api/uni/auth/refresh';
  static const String userLoginEndpoint = '/api/user/auth/login';
  static const String userRefreshEndpoint = '/api/user/auth/refresh';

  // App Routes
  static const String uniDashboardRoute = '/dashboard/uni';
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';

  // Timeouts
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration sessionRefreshInterval = Duration(hours: 1);
} 