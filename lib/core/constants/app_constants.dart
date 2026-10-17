class AppConstants {
  AppConstants._();

  static const String appName = 'SpendWise';
  static const String currencyCode = 'KES';

  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  static const String authorizationHeader = 'Authorization';
  static const String contentTypeHeader = 'Content-Type';
  static const String acceptHeader = 'Accept';
  static const String jsonContentType = 'application/json';

  static const String loginEndpoint = '/auth/login';
  static const String signupEndpoint = '/auth/signup';
  static const String meEndpoint = '/auth/me';
  static const String expensesEndpoint = '/expenses';
  static const String budgetsEndpoint = '/budgets';
  static const String cardsEndpoint = '/cards';

  static const String demoEmail = 'demo@spendwise.app';
  static const String demoPassword = 'password123';
}
