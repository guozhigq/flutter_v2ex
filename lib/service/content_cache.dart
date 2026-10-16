import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:flutter_v2ex/utils/storage.dart';

/// Page content is separate from reading history and is isolated per account.
class ContentCache {
  static const boxName = 'contentPages';
  static const maxEntries = 200;
  static const maxAge = Duration(days: 7);

  static String get scope {
    final storage = GStorage();
    return jsonEncode([
      storage.getLoginStatus(),
      storage.getUserInfo()['userName'] ?? '',
    ]);
  }

  static String key(String resource, int page) =>
      jsonEncode([scope, resource, page]);

  static CachedContent? read(String key) {
    try {
      if (!Hive.isBoxOpen(boxName)) return null;
      final value = Hive.box(boxName).get(key);
      if (value is! Map) return null;
      final time = DateTime.fromMillisecondsSinceEpoch(value['savedAt'] as int);
      if (DateTime.now().difference(time) > maxAge) return null;
      return CachedContent(value['data'], time);
    } catch (_) {
      // A corrupt or incompatible cache must not prevent a network request.
      return null;
    }
  }

  static Future<void> write(String key, dynamic data) async {
    try {
      if (!Hive.isBoxOpen(boxName)) return;
      final box = Hive.box(boxName);
      // Reinsert so eviction follows the last successful update.
      await box.delete(key);
      await box.put(key, {
        'savedAt': DateTime.now().millisecondsSinceEpoch,
        'data': data,
      });
      while (box.length > maxEntries) {
        await box.delete(box.keys.first);
      }
    } catch (_) {
      // Cache I/O is best effort; fresh content remains usable.
    }
  }
}

class CachedContent {
  final dynamic data;
  final DateTime savedAt;
  const CachedContent(this.data, this.savedAt);
}
