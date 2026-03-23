import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
  ),
);

extension LoggerExtension on Logger {
  void info(String message) {
    log(Level.info, message);
  }

  void error(String message, {Object? error}) {
    log(Level.error, message, error: error);
  }

  void warning(String message) {
    log(Level.warning, message);
  }

  void debug(String message) {
    log(Level.debug, message);
  }
}
