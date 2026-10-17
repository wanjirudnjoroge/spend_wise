class AppException implements Exception {
  const AppException({required this.message, this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final String? code;

  @override
  String toString() =>
      code != null ? 'AppException($code): $message' : 'AppException: $message';
}

class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Unable to connect to the server.',
    super.code = 'NETWORK_ERROR',
  });
}

class AuthenticationException extends AppException {
  const AuthenticationException({
    super.message = 'Authentication failed.',
    super.statusCode = 401,
    super.code = 'AUTHENTICATION_ERROR',
  });
}

class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.statusCode = 422,
    super.code = 'VALIDATION_ERROR',
  });
}

class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'The requested resource was not found.',
    super.statusCode = 404,
    super.code = 'NOT_FOUND',
  });
}

class ServerException extends AppException {
  const ServerException({
    super.message = 'An unexpected server error occurred.',
    super.statusCode = 500,
    super.code = 'SERVER_ERROR',
  });
}

String errorMessage(Object error) {
  if (error is AppException) return error.message;
  return 'Something went wrong. Please try again.';
}
