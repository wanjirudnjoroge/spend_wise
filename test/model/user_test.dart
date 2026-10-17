import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/model/login_response.dart';
import 'package:spendwise/model/user.dart';

void main() {
  test('User.fromJson parses fields and exposes the first name', () {
    final user = User.fromJson({
      'id': 7,
      'name': 'Amina Wanjiru',
      'email': 'a@b.co',
    });

    expect(user.id, '7');
    expect(user.firstName, 'Amina');
    expect(user.email, 'a@b.co');
  });

  test('firstName falls back when the name is empty', () {
    expect(const User(id: '1', name: '', email: 'x@y.z').firstName, 'there');
  });

  test('LoginResponse.fromJson reads tokens and user', () {
    final response = LoginResponse.fromJson({
      'access_token': 'abc',
      'refresh_token': 'def',
      'user': {'id': '1', 'name': 'A', 'email': 'a@b.co'},
    });

    expect(response.tokens.accessToken, 'abc');
    expect(response.tokens.refreshToken, 'def');
    expect(response.user.name, 'A');
  });
}
