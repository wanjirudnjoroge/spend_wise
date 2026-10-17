import 'token_response.dart';
import 'user.dart';

class LoginResponse {
  const LoginResponse({required this.tokens, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      tokens: TokenResponse.fromJson(json),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  final TokenResponse tokens;
  final User user;
}
