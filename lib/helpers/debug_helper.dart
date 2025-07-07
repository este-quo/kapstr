import 'package:flutter/foundation.dart';

printOnDebug(String message) {
  if (kDebugMode) {
    print(message);
  }
}
