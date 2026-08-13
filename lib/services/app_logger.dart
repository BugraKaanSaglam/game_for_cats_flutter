import 'package:logger/logger.dart';

/// Small logging facade that isolates the app from the logger package.
class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 100,
    ),
  );

  static void info(String message) => _logger.i(message);

  static void warning(String message) => _logger.w(message);

  // ! Errors accept optional exception + stack trace because startup and persistence paths need both.
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
