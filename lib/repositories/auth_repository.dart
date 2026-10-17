import '../core/errors/app_exception.dart';
import '../core/security/token_storage.dart';
import '../model/auth_exception.dart';
import '../model/login_response.dart';
import '../model/user.dart';
import '../services/auth_api.dart';

class AuthRepository {
  AuthRepository({required this._api, required this._tokenStorage});

  final AuthApi _api;
  final TokenStorage _tokenStorage;

  Future<User> login({required String email, required String password}) async {
    try {
      final response = await _api.login(email: email, password: password);
      return _persist(response);
    } on AppException catch (error) {
      throw AuthException(error.message);
    }
  }

  Future<User> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.signup(
        name: name,
        email: email,
        password: password,
      );
      return _persist(response);
    } on AppException catch (error) {
      throw AuthException(error.message);
    }
  }

  Future<User?> restoreSession() async {
    if (!await _tokenStorage.hasAccessToken()) return null;
    try {
      return await _api.currentUser();
    } on AuthenticationException {
      await _tokenStorage.clearTokens();
      return null;
    } on AppException {
      return null;
    }
  }

  Future<void> logout() => _tokenStorage.clearTokens();

  Future<User> _persist(LoginResponse response) async {
    await _tokenStorage.saveTokens(
      accessToken: response.tokens.accessToken,
      refreshToken: response.tokens.refreshToken,
    );
    return response.user;
  }
}
