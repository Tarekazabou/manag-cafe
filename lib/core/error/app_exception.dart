abstract class AppException implements Exception {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppException({
    required this.message,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException({
    required super.message,
    super.originalError,
    super.stackTrace,
  });
}

class TimeoutException extends AppException {
  TimeoutException({
    required super.message,
    super.originalError,
    super.stackTrace,
  });
}

class AuthException extends AppException {
  AuthException({
    required super.message,
    super.originalError,
    super.stackTrace,
  });
}

class PermissionException extends AppException {
  PermissionException({
    required super.message,
    super.originalError,
    super.stackTrace,
  });
}

class SyncException extends AppException {
  SyncException({
    required super.message,
    super.originalError,
    super.stackTrace,
  });
}

class ValidationException extends AppException {
  ValidationException({
    required super.message,
    super.originalError,
    super.stackTrace,
  });
}

class InsufficientStockException extends AppException {
  final String itemName;
  final double available;
  final double requested;

  InsufficientStockException({
    required this.itemName,
    required this.available,
    required this.requested,
  }) : super(
    message: '$itemName: Only $available available, but $requested requested',
  );
}

class TransactionFailedException extends AppException {
  TransactionFailedException(String message) : super(message: message);
}

class DataVerificationException extends AppException {
  DataVerificationException(String message) : super(message: message);
}
