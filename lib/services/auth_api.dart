import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../model/login_response.dart';
import '../model/user.dart';

abstract class AuthApi {
  Future<LoginResponse> login({
    required String email,
    required String password,
  });

  Future<LoginResponse> signup({
    required String name,
    required String email,
    required String password,
  });

  Future<User> currentUser();
}

class HttpAuthApi implements AuthApi {
  HttpAuthApi(this._client);

  final ApiClient _client;

  @override
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final json = await _client.post(
      AppConstants.loginEndpoint,
      body: {'email': email, 'password': password},
      authenticated: false,
    );
    return LoginResponse.fromJson(json);
  }

  @override
  Future<LoginResponse> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final json = await _client.post(
      AppConstants.signupEndpoint,
      body: {'name': name, 'email': email, 'password': password},
      authenticated: false,
    );
    return LoginResponse.fromJson(json);
  }

  @override
  Future<User> currentUser() async {
    final json = await _client.get(AppConstants.meEndpoint);
    return User.fromJson(json);
  }
}
