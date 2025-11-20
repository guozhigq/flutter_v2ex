import 'package:flutter/foundation.dart';

void logDebug(Object? message) {
  if (kDebugMode) {
    debugPrint('$message');
  }
}
