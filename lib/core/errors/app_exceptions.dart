class AppException implements Exception {
  final String message;
  final String? code;
  final String? details;

  const AppException({required this.message, this.code, this.details});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class AppAuthException extends AppException {
  const AppAuthException({required super.message, super.code});
}

class NetworkException extends AppException {
  const NetworkException({required super.message, super.code});
}

class PermissionException extends AppException {
  const PermissionException({required super.message, super.code});
}

class AppValidationException extends AppException {
  const AppValidationException({required super.message, super.code});
}
