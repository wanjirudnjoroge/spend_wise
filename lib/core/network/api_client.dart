import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';
import '../security/token_storage.dart';

class ApiClient {
  ApiClient({required this._tokenStorage, http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  final TokenStorage _tokenStorage;
  final http.Client _client;
  final String _baseUrl;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) async {
    final headers = await _headers(authenticated);
    final response = await _send(
      () => _client.get(_uri(path, queryParameters), headers: headers),
    );
    return _parse(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Object? body,
    bool authenticated = true,
  }) async {
    final headers = await _headers(authenticated);
    final response = await _send(
      () => _client.post(
        _uri(path),
        headers: headers,
        body: body == null ? null : jsonEncode(body),
      ),
    );
    return _parse(response);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Object? body,
    bool authenticated = true,
  }) async {
    final headers = await _headers(authenticated);
    final response = await _send(
      () => _client.put(
        _uri(path),
        headers: headers,
        body: body == null ? null : jsonEncode(body),
      ),
    );
    return _parse(response);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Object? body,
    bool authenticated = true,
  }) async {
    final headers = await _headers(authenticated);
    final response = await _send(
      () => _client.patch(
        _uri(path),
        headers: headers,
        body: body == null ? null : jsonEncode(body),
      ),
    );
    return _parse(response);
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    bool authenticated = true,
  }) async {
    final headers = await _headers(authenticated);
    final response = await _send(
      () => _client.delete(_uri(path), headers: headers),
    );
    return _parse(response);
  }

  Future<Map<String, String>> _headers(bool authenticated) async {
    final token = authenticated ? await _tokenStorage.getAccessToken() : null;
    return {
      AppConstants.contentTypeHeader: AppConstants.jsonContentType,
      AppConstants.acceptHeader: AppConstants.jsonContentType,
      if (token != null && token.isNotEmpty)
        AppConstants.authorizationHeader: 'Bearer $token',
    };
  }

  Uri _uri(String path, [Map<String, String>? queryParameters]) {
    final base = Uri.parse(_baseUrl);
    final normalized = path.startsWith('/') ? path : '/$path';
    final uri = base.resolve(normalized);
    if (queryParameters == null || queryParameters.isEmpty) return uri;
    return uri.replace(queryParameters: queryParameters);
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(AppConfig.requestTimeout);
    } on TimeoutException {
      throw const NetworkException(
        message: 'The request timed out. Please try again.',
        code: 'REQUEST_TIMEOUT',
      );
    } on http.ClientException {
      throw const NetworkException();
    }
  }

  Map<String, dynamic> _parse(http.Response response) {
    final status = response.statusCode;
    var data = <String, dynamic>{};

    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        data = decoded is Map<String, dynamic> ? decoded : {'data': decoded};
      } on FormatException {
        throw AppException(
          message: 'The server returned an invalid response.',
          statusCode: status,
          code: 'INVALID_RESPONSE',
        );
      }
    }

    if (status >= 200 && status < 300) return data;

    final message = _errorMessage(data);
    if (status == 401 || status == 403) {
      throw AuthenticationException(message: message, statusCode: status);
    }
    if (status == 404) throw NotFoundException(message: message);
    if (status == 400 || status == 422) {
      throw ValidationException(message: message, statusCode: status);
    }
    if (status >= 500) {
      throw ServerException(message: message, statusCode: status);
    }
    throw AppException(
      message: message,
      statusCode: status,
      code: 'HTTP_ERROR',
    );
  }

  String _errorMessage(Map<String, dynamic> data) {
    for (final key in ['detail', 'message', 'error']) {
      final value = data[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return 'The request failed. Please try again.';
  }

  void close() => _client.close();
}
