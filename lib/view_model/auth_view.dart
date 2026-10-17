import 'package:flutter/foundation.dart';

import '../core/errors/app_exception.dart';
import '../core/utils/safe_notifier.dart';
import '../model/auth_exception.dart';
import '../model/user.dart';
import '../repositories/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthViewModel extends ChangeNotifier with SafeNotifier {
  AuthViewModel(this._repository);

  final AuthRepository _repository;

  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  bool _isLoading = false;
  String? _error;

  AuthStatus get status => _status;
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> restoreSession() async {
    try {
      _user = await _repository.restoreSession();
    } catch (_) {
      _user = null;
    }
    _status = _user == null
        ? AuthStatus.unauthenticated
        : AuthStatus.authenticated;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) {
    return _authenticate(
      () => _repository.login(email: email, password: password),
    );
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
  }) {
    return _authenticate(
      () => _repository.signup(name: name, email: email, password: password),
    );
  }

  Future<void> logout() async {
    await _repository.logout();
    _user = null;
    _error = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  Future<bool> _authenticate(Future<User> Function() action) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await action();
      _status = AuthStatus.authenticated;
      return true;
    } on AuthException catch (error) {
      _error = error.message;
      return false;
    } catch (error) {
      _error = errorMessage(error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
