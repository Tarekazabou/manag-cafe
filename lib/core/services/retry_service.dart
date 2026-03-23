import '../error/app_exception.dart';
import '../utils/logger.dart';

class RetryService {
  static const Duration _baseDelay = Duration(milliseconds: 100);
  static const int _maxRetries = 3;

  static Future<T> retry<T>({
    required Future<T> Function() action,
    required String operationName,
    int maxRetries = _maxRetries,
    Duration baseDelay = _baseDelay,
    bool Function(Object error)? shouldRetry,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    int attempt = 0;
    Object? lastError;

    while (attempt < maxRetries) {
      try {
        return await action().timeout(
          timeout,
          onTimeout: () => throw TimeoutException(
            message: '$operationName timed out after ${timeout.inSeconds} seconds',
          ),
        );
      } catch (e) {
        lastError = e;
        attempt++;

        if (shouldRetry != null && !shouldRetry(e)) {
          rethrow;
        }

        logger.warning(
          '⚠️ $operationName attempt $attempt failed: $e. '
          '${attempt < maxRetries ? 'Retrying...' : 'Max retries reached.'}',
        );

        if (attempt < maxRetries) {
          final delay = baseDelay * (2 << (attempt - 1)); // Exponential backoff
          await Future.delayed(delay);
        }
      }
    }

    throw SyncException(
      message: '$operationName failed after $maxRetries attempts',
      originalError: lastError,
    );
  }
}
