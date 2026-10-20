import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:flutter_v2ex/models/web/model_topic_detail.dart';
import 'package:flutter_v2ex/models/web/item_topic_reply.dart';
import 'package:flutter_v2ex/models/web/item_topic_subtle.dart';
import 'package:flutter_v2ex/utils/storage.dart';

/// Bodies and small cursor records share one bounded, jointly pruned cache.
class ContentCache {
  static const boxName = 'contentPages';
  static const maxEntries = 100;
  static const maxBytes = 20 * 1024 * 1024;
  static const maxAge = Duration(days: 7);
  static Future<void>? _pending;
  static String get scope => jsonEncode([
        GStorage().getLoginStatus(),
        GStorage().getUserInfo()['userName'] ?? ''
      ]);
  static String key(String resource, int page) =>
      jsonEncode([scope, resource, page]);
  static String metadataKey(String key) => 'meta:$key';

  static bool _detailKey(dynamic key) {
    try {
      final parts = jsonDecode(key as String) as List;
      return parts.length == 3 &&
          parts[0] is String &&
          parts[1] is String &&
          (parts[1] as String).startsWith('topic:') &&
          (parts[1] as String).length > 6 &&
          parts[2] == 1;
    } catch (_) {
      return false;
    }
  }

  static bool _valid(dynamic v) =>
      v is Map &&
      (v['version'] == 2 || v['version'] == 3) &&
      v['payload'] is String &&
      v['savedAt'] is int &&
      DateTime.now().millisecondsSinceEpoch - (v['savedAt'] as int) <
          maxAge.inMilliseconds;

  static Future<void> _enqueue(Future<void> Function(Box) action) {
    late Future<void> task;
    task = (_pending ?? Future<void>.value()).then((_) async {
      if (!Hive.isBoxOpen(boxName)) return;
      try {
        await action(Hive.box(boxName));
      } catch (_) {/* Cache I/O is optional. */}
    }).whenComplete(() {
      if (identical(_pending, task)) _pending = null;
    });
    _pending = task;
    return task;
  }

  static Map _metadata(Box box, String key, Map body) {
    final stored = box.get(metadataKey(key));
    if (stored is Map && stored['lastAccess'] is int) return stored;
    return {
      'lastAccess':
          body['lastAccess'] is int ? body['lastAccess'] : body['savedAt'],
      if (body['progress'] != null) 'progress': body['progress'],
    };
  }

  static int _size(String key, Map body, Map metadata) =>
      (body['payloadBytes'] as int? ??
          utf8.encode(body['payload'] as String).length) +
      utf8.encode(jsonEncode(metadata)).length +
      utf8.encode(key).length * 2 +
      256;

  static Future<void> _delete(Box box, String key) =>
      box.deleteAll([key, metadataKey(key)]);

  static Future<int> _fileSize(Box box) async {
    final path = box.path;
    return path == null ? 0 : await File(path).length();
  }

  static Future<void> _prune(Box box) async {
    final entries = <MapEntry<String, Map>>[];
    var bytes = 0;
    var deleted = false;
    for (final key in box.keys.toList()) {
      if (key is String && key.startsWith('meta:')) continue;
      final value = box.get(key);
      if (!_detailKey(key) || !_valid(value)) {
        await box.delete(key);
        if (key is String) await box.delete(metadataKey(key));
        deleted = true;
      } else {
        final body = value as Map;
        final metadata = _metadata(box, key as String, body);
        if (body['version'] == 2) {
          // One-time migration preserves the existing cursor and body TTL.
          await box.put(metadataKey(key), metadata);
          await box.put(key, {
            'version': 3,
            'savedAt': body['savedAt'],
            'payload': body['payload'],
            'payloadBytes': utf8.encode(body['payload'] as String).length,
          });
          deleted = true;
        }
        entries.add(MapEntry(key, metadata));
        bytes += _size(key, box.get(key) as Map, metadata);
      }
    }
    for (final key in box.keys.toList()) {
      if (key is String &&
          key.startsWith('meta:') &&
          (!_detailKey(key.substring(5)) ||
              !_valid(box.get(key.substring(5))))) {
        await box.delete(key);
        deleted = true;
      }
    }
    entries.sort((a, b) =>
        (a.value['lastAccess'] as int).compareTo(b.value['lastAccess'] as int));
    var count = entries.length;
    for (final entry in entries) {
      if (count <= maxEntries && bytes <= maxBytes) break;
      bytes -= _size(entry.key, box.get(entry.key) as Map, entry.value);
      await _delete(box, entry.key);
      count--;
      deleted = true;
    }
    // Hive appends updates. Bound the physical file too, including old versions.
    if (deleted || await _fileSize(box) > maxBytes) await box.compact();
    // Include actual Hive framing overhead if a near-limit record still exceeds it.
    for (final entry in entries) {
      if (await _fileSize(box) <= maxBytes) break;
      if (box.containsKey(entry.key)) {
        await _delete(box, entry.key);
        await box.compact();
      }
    }
  }

  /// Removes expired data, old list/page records and the previous cache schema.
  static Future<void> cleanUp() => _enqueue(_prune);

  static CachedContent? read(String key) {
    if (!Hive.isBoxOpen(boxName)) return null;
    try {
      final v = Hive.box(boxName).get(key);
      if (!_detailKey(key) || !_valid(v)) {
        unawaited(cleanUp());
        return null;
      }
      final model = _decode(jsonDecode(v['payload'] as String) as Map);
      unawaited(_enqueue((box) async {
        final current = box.get(key);
        if (_valid(current)) {
          final metadata = _metadata(box, key, current as Map);
          final now = DateTime.now().millisecondsSinceEpoch;
          if (now - (metadata['lastAccess'] as int) >= 60000) {
            await box.put(
                metadataKey(key), Map.of(metadata)..['lastAccess'] = now);
          }
          await _prune(box);
        }
      }));
      return CachedContent(
          model,
          DateTime.fromMillisecondsSinceEpoch(v['savedAt'] as int),
          ReadingProgress.fromMap(
              _metadata(Hive.box(boxName), key, v as Map)['progress']));
    } catch (_) {
      unawaited(_enqueue((box) async {
        await _delete(box, key);
        await _prune(box);
      }));
      return null;
    }
  }

  static Future<void> write(String key, dynamic data,
          {bool cacheReplies = true}) =>
      _enqueue((box) async {
        await _prune(box);
        if (!_detailKey(key) || data is! TopicDetailModel) return;
        final old = box.get(key);
        // Later pages can seed a body, but cannot overwrite cached first-page replies.
        if (!cacheReplies && _valid(old)) return;
        final now = DateTime.now().millisecondsSinceEpoch;
        final oldMetadata =
            _valid(old) ? _metadata(box, key, old as Map) : null;
        final payload = jsonEncode(_encode(data, cacheReplies));
        final value = <String, dynamic>{
          'version': 3,
          'savedAt': now,
          'payload': payload,
          'payloadBytes': utf8.encode(payload).length,
        };
        final metadata = {
          'lastAccess': now,
          if (oldMetadata?['progress'] != null)
            'progress': oldMetadata!['progress'],
        };
        if (_size(key, value, metadata) > maxBytes) {
          await _delete(box, key);
          await box.compact();
          return;
        }
        await box.put(key, value);
        await box.put(metadataKey(key), metadata);
        await _prune(box);
      });

  static Future<void> saveProgress(String key, ReadingProgress progress) =>
      _enqueue((box) async {
        final v = box.get(key);
        if (!_detailKey(key) || !_valid(v)) {
          await _prune(box);
          return;
        }
        // Saving a cursor never refreshes the cached body's expiry date.
        final metadata = _metadata(box, key, v as Map);
        final next = progress.toMap();
        if (jsonEncode(metadata['progress']) != jsonEncode(next)) {
          await box.put(metadataKey(key), {
            'progress': next,
            'lastAccess': DateTime.now().millisecondsSinceEpoch,
          });
        }
        await _prune(box);
      });

  static Map<String, dynamic> _encode(TopicDetailModel m, bool replies) => {
        'topicId': m.topicId,
        'nodeId': m.nodeId,
        'nodeName': m.nodeName,
        'topicTitle': m.topicTitle,
        'createdId': m.createdId,
        'avatar': m.avatar,
        'replyCount': m.replyCount,
        'createdTime': m.createdTime,
        'visitorCount': m.visitorCount,
        'content': m.content,
        'contentRendered': m.contentRendered,
        'subtleList': m.subtleList.map((s) => [s.fade, s.content]).toList(),
        'imgCount': m.imgCount,
        'imgList': m.imgList,
        'isAuth': m.isAuth,
        'token': m.token,
        'isFavorite': m.isFavorite,
        'favoriteCount': m.favoriteCount,
        'isThank': m.isThank,
        'isAPPEND': m.isAPPEND,
        'isEDIT': m.isEDIT,
        'isMOVE': m.isMOVE,
        'totalPage': m.totalPage,
        'replyList': replies
            ? m.replyList
                .map((r) => [
                      r.isOwner,
                      r.avatar,
                      r.userName,
                      r.lastReplyTime,
                      r.content,
                      r.contentRendered,
                      r.replyId,
                      r.favorites,
                      r.favoritesStatus,
                      r.number,
                      r.floorNumber,
                      r.platform,
                      r.isChoose,
                      r.replyMemberList,
                      r.imgList,
                      r.isMod
                    ])
                .toList()
            : [],
      };
  static TopicDetailModel _decode(Map m) => TopicDetailModel()
    ..topicId = m['topicId']
    ..nodeId = m['nodeId']
    ..nodeName = m['nodeName']
    ..topicTitle = m['topicTitle']
    ..createdId = m['createdId']
    ..avatar = m['avatar']
    ..replyCount = m['replyCount']
    ..createdTime = m['createdTime']
    ..visitorCount = m['visitorCount']
    ..content = m['content']
    ..contentRendered = m['contentRendered']
    ..subtleList = (m['subtleList'] as List)
        .map((s) => TopicSubtleItem()
          ..fade = s[0]
          ..content = s[1])
        .toList()
    ..imgCount = m['imgCount']
    ..imgList = List.from(m['imgList'])
    ..isAuth = m['isAuth']
    ..token = m['token']
    ..isFavorite = m['isFavorite']
    ..favoriteCount = m['favoriteCount']
    ..isThank = m['isThank']
    ..isAPPEND = m['isAPPEND']
    ..isEDIT = m['isEDIT']
    ..isMOVE = m['isMOVE']
    ..totalPage = m['totalPage']
    ..replyList = (m['replyList'] as List)
        .map((r) => ReplyItem()
          ..isOwner = r[0]
          ..avatar = r[1]
          ..userName = r[2]
          ..lastReplyTime = r[3]
          ..content = r[4]
          ..contentRendered = r[5]
          ..replyId = r[6]
          ..favorites = r[7]
          ..favoritesStatus = r[8]
          ..number = r[9]
          ..floorNumber = r[10]
          ..platform = r[11]
          ..isChoose = r[12]
          ..replyMemberList = List.from(r[13])
          ..imgList = List.from(r[14])
          ..isMod = r[15])
        .toList();
}

class ReadingProgress {
  final String replyId;
  final int floorNumber;
  final int page;
  final double offsetWithinReply;
  const ReadingProgress(
      {required this.replyId,
      required this.floorNumber,
      required this.page,
      this.offsetWithinReply = 0});
  static int pageForFloor(int floor) => floor <= 0 ? 1 : (floor - 1) ~/ 100 + 1;
  int? indexIn(List<ReplyItem> replies) {
    if (replies.isEmpty) return null;
    if (replyId.isNotEmpty) {
      final exact = replies.indexWhere((r) => r.replyId == replyId);
      if (exact >= 0) return exact;
    }
    var nearest = 0;
    for (var i = 0; i < replies.length; i++) {
      if ((replies[i].floorNumber - floorNumber).abs() <
          (replies[nearest].floorNumber - floorNumber).abs()) {
        nearest = i;
      }
    }
    return nearest;
  }

  Map<String, dynamic> toMap() => {
        'replyId': replyId,
        'floor': floorNumber,
        'page': page,
        'offset': offsetWithinReply
      };
  static ReadingProgress? fromMap(dynamic v) {
    if (v is! Map ||
        v['replyId'] is! String ||
        v['floor'] is! int ||
        v['page'] is! int ||
        v['floor'] < 1 ||
        v['page'] < 1) {
      return null;
    }
    final offset = v['offset'];
    return ReadingProgress(
        replyId: v['replyId'],
        floorNumber: v['floor'],
        page: v['page'],
        offsetWithinReply: offset is num && offset.isFinite && offset >= 0
            ? offset.toDouble()
            : 0);
  }
}

class CachedContent {
  final TopicDetailModel data;
  final DateTime savedAt;
  final ReadingProgress? progress;
  const CachedContent(this.data, this.savedAt, [this.progress]);
}
