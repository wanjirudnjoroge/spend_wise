import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendwise/core/dependencies.dart';
import 'package:spendwise/core/security/token_storage.dart';
import 'package:spendwise/core/theme/app_theme.dart';
import 'package:spendwise/services/mock_apis.dart';

class InMemoryTokenStorage implements TokenStorage {
  String? access;
  String? refresh;

  @override
  Future<void> saveAccessToken(String token) async => access = token;

  @override
  Future<String?> getAccessToken() async => access;

  @override
  Future<void> saveRefreshToken(String token) async => refresh = token;

  @override
  Future<String?> getRefreshToken() async => refresh;

  @override
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    access = accessToken;
    if (refreshToken != null) refresh = refreshToken;
  }

  @override
  Future<void> clearTokens() async {
    access = null;
    refresh = null;
  }

  @override
  Future<bool> hasAccessToken() async => access != null && access!.isNotEmpty;
}

Widget buildTestApp(Widget home) {
  return ProviderScope(
    overrides: [
      tokenStorageProvider.overrideWithValue(InMemoryTokenStorage()),
      authApiProvider.overrideWithValue(MockAuthApi(latency: Duration.zero)),
      expenseApiProvider.overrideWithValue(
        MockExpenseApi(latency: Duration.zero),
      ),
      budgetApiProvider.overrideWithValue(
        MockBudgetApi(latency: Duration.zero),
      ),
      cardApiProvider.overrideWithValue(MockCardApi(latency: Duration.zero)),
    ],
    child: MaterialApp(theme: AppTheme.light(), home: home),
  );
}
