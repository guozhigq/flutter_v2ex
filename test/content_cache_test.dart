import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive/hive.dart';
import 'package:flutter_v2ex/models/web/model_topic_detail.dart';
import 'package:flutter_v2ex/models/web/item_topic_reply.dart';
import 'package:flutter_v2ex/service/content_cache.dart';
import 'package:flutter_v2ex/utils/storage.dart';

TopicDetailModel detail(String id, {String body = '<p>正文</p>'}) =>
    TopicDetailModel()
      ..topicId = id
      ..contentRendered = body
      ..replyList = [
        ReplyItem()
          ..replyId = 'r100'
          ..floorNumber = 100
          ..contentRendered = '<p>回复</p>'
      ];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  Box getBox() => Hive.box(ContentCache.boxName);
  int bodyCount() => getBox()
      .keys
      .where((key) => key is String && !key.startsWith('meta:'))
      .length;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('vvex_detail_cache');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (_) async => directory.path);
    await GetStorage('GetStorage', directory.path).initStorage;
    Hive.init(directory.path);
    await Hive.openBox(ContentCache.boxName);
  });
  setUp(() async {
    await ContentCache.cleanUp();
    await getBox().clear();
    GetStorage().writeInMemory(StoreKeys.loginStatus.toString(), false);
    GetStorage().writeInMemory(StoreKeys.userInfo.toString(), {});
  });
  tearDownAll(() async {
    await ContentCache.cleanUp();
    await Hive.close();
    try {
      await directory.delete(recursive: true);
    } on FileSystemException {
      if (!Platform.isWindows) rethrow;
    }
  });

  test('list data and later reply pages are never persisted', () async {
    await ContentCache.write(
        ContentCache.key('home:recent', 1), {'topicList': []});
    await ContentCache.write(
        ContentCache.key('search:test', 1), {'results': []});
    await ContentCache.write(ContentCache.key('topic:42', 2), detail('42'));
    expect(getBox().isEmpty, isTrue);
  });
  test('detail and its cursor survive closing and reopening the database',
      () async {
    final key = ContentCache.key('topic:42', 1);
    await ContentCache.write(key, detail('42'));
    await ContentCache.saveProgress(
        key, const ReadingProgress(replyId: 'r100', floorNumber: 100, page: 1));
    await getBox().close();
    await Hive.openBox(ContentCache.boxName);
    final cached = ContentCache.read(key)!;
    expect(cached.data.contentRendered, '<p>正文</p>');
    expect(cached.data.replyList.single.floorNumber, 100);
    expect(cached.progress!.replyId, 'r100');
  });
  test('accounts have separate topic records', () async {
    final guest = ContentCache.key('topic:42', 1);
    await ContentCache.write(guest, detail('42', body: 'guest'));
    GetStorage().writeInMemory(StoreKeys.loginStatus.toString(), true);
    GetStorage()
        .writeInMemory(StoreKeys.userInfo.toString(), {'userName': 'alice'});
    final alice = ContentCache.key('topic:42', 1);
    expect(ContentCache.read(alice), isNull);
    await ContentCache.write(alice, detail('42', body: 'alice'));
    expect(ContentCache.read(guest)!.data.contentRendered, 'guest');
    expect(ContentCache.read(alice)!.data.contentRendered, 'alice');
  });
  test(
      'cursor writes never refresh body expiration, body refresh retains cursor',
      () async {
    final key = ContentCache.key('topic:42', 1);
    await ContentCache.write(key, detail('42'));
    final time =
        DateTime.now().subtract(const Duration(days: 6)).millisecondsSinceEpoch;
    await getBox()
        .put(key, Map.of(getBox().get(key) as Map)..['savedAt'] = time);
    await ContentCache.saveProgress(
        key, const ReadingProgress(replyId: 'r100', floorNumber: 100, page: 1));
    expect((getBox().get(key) as Map)['savedAt'], time);
    await ContentCache.write(key, detail('42', body: 'fresh'));
    expect(ContentCache.read(key)!.progress!.floorNumber, 100);
    expect(ContentCache.read(key)!.data.contentRendered, 'fresh');
  });
  test('expired details are physically removed together with their cursors',
      () async {
    final key = ContentCache.key('topic:42', 1);
    await ContentCache.write(key, detail('42'));
    await ContentCache.saveProgress(
        key, const ReadingProgress(replyId: 'r100', floorNumber: 100, page: 1));
    await getBox().put(
        key,
        Map.of(getBox().get(key) as Map)
          ..['savedAt'] = DateTime.now()
              .subtract(const Duration(days: 8))
              .millisecondsSinceEpoch);
    expect(ContentCache.read(key), isNull);
    await ContentCache.cleanUp();
    expect(getBox().containsKey(key), isFalse);
  });
  test('startup cleanup removes old list data and incompatible cache schema',
      () async {
    await getBox()
        .put(ContentCache.key('home:recent', 1), {'savedAt': 1, 'data': []});
    await getBox()
        .put(ContentCache.key('topic:old', 1), {'savedAt': 1, 'data': 'old'});
    await getBox().put('broken', {'savedAt': 'invalid'});
    await ContentCache.cleanUp();
    expect(getBox().isEmpty, isTrue);
  });
  test('least recently accessed topic is evicted at the global count limit',
      () async {
    for (var i = 0; i < ContentCache.maxEntries; i++) {
      await ContentCache.write(ContentCache.key('topic:$i', 1), detail('$i'));
      await getBox().put(
          ContentCache.metadataKey(ContentCache.key('topic:$i', 1)),
          Map.of(getBox().get(
              ContentCache.metadataKey(ContentCache.key('topic:$i', 1))) as Map)
            ..['lastAccess'] = i);
    }
    ContentCache.read(ContentCache.key('topic:0', 1));
    await ContentCache.write(ContentCache.key('topic:new', 1), detail('new'));
    expect(bodyCount(), ContentCache.maxEntries);
    expect(ContentCache.read(ContentCache.key('topic:0', 1)), isNotNull);
    expect(ContentCache.read(ContentCache.key('topic:1', 1)), isNull);
  });
  test('byte limit evicts old bodies and an oversized body is not stored',
      () async {
    final body = 'x' * (11 * 1024 * 1024);
    await ContentCache.write(
        ContentCache.key('topic:1', 1), detail('1', body: body));
    await ContentCache.write(
        ContentCache.key('topic:2', 1), detail('2', body: body));
    expect(bodyCount(), 1);
    expect(ContentCache.read(ContentCache.key('topic:1', 1)), isNull);
    await ContentCache.write(ContentCache.key('topic:large', 1),
        detail('large', body: 'x' * ContentCache.maxBytes));
    expect(bodyCount(), 1);
    expect(ContentCache.read(ContentCache.key('topic:large', 1)), isNull);
  });
  test('later pages seed only the body without replacing first-page replies',
      () async {
    final key = ContentCache.key('topic:42', 1);
    await ContentCache.write(key, detail('42'), cacheReplies: false);
    expect(ContentCache.read(key)!.data.replyList, isEmpty);
    await ContentCache.write(key, detail('42'));
    await ContentCache.write(key, detail('42', body: 'page 9'),
        cacheReplies: false);
    expect(ContentCache.read(key)!.data.replyList.single.floorNumber, 100);
    expect(ContentCache.read(key)!.data.contentRendered, '<p>正文</p>');
  });
  test('cursor without a cached body never creates an orphan record', () async {
    await ContentCache.saveProgress(ContentCache.key('topic:42', 1),
        const ReadingProgress(replyId: 'r100', floorNumber: 100, page: 1));
    expect(getBox().isEmpty, isTrue);
  });
  test('floor boundaries and deleted replies resolve to valid local indices',
      () {
    expect([1, 100, 101, 200, 201].map(ReadingProgress.pageForFloor),
        [1, 1, 2, 2, 3]);
    final replies = [
      ReplyItem()
        ..replyId = 'a'
        ..floorNumber = 100,
      ReplyItem()
        ..replyId = 'b'
        ..floorNumber = 101
    ];
    expect(
        const ReadingProgress(replyId: 'a', floorNumber: 101, page: 1)
            .indexIn(replies),
        0);
    expect(
        const ReadingProgress(replyId: 'deleted', floorNumber: 101, page: 2)
            .indexIn(replies),
        1);
    expect(
        const ReadingProgress(replyId: '', floorNumber: 100, page: 1)
            .indexIn([]),
        isNull);
  });

  test('reading and saving cursors do not rewrite or duplicate cached bodies',
      () async {
    final key = ContentCache.key('topic:42', 1);
    await ContentCache.write(key, detail('42', body: 'x' * (3 * 1024 * 1024)));
    await getBox().flush();
    final file = File(getBox().path!);
    final initialBytes = await file.length();
    final bodyWrites = <BoxEvent>[];
    final subscription = getBox().watch(key: key).listen(bodyWrites.add);
    for (var i = 0; i < 12; i++) {
      expect(ContentCache.read(key), isNotNull);
      await ContentCache.saveProgress(
          key, ReadingProgress(replyId: 'r$i', floorNumber: i + 1, page: 1));
    }
    await ContentCache.cleanUp();
    await getBox().flush();
    await subscription.cancel();
    expect(bodyWrites, isEmpty);
    expect(await file.length(), lessThan(initialBytes + 128 * 1024));
    expect(await file.length(), lessThanOrEqualTo(ContentCache.maxBytes));
  });

  test(
      'replacing a large body compacts the physical cache below its size limit',
      () async {
    final key = ContentCache.key('topic:42', 1);
    await ContentCache.write(key, detail('42', body: 'x' * (11 * 1024 * 1024)));
    await ContentCache.write(key, detail('42', body: 'y' * (11 * 1024 * 1024)));
    await getBox().flush();
    expect(await File(getBox().path!).length(),
        lessThanOrEqualTo(ContentCache.maxBytes));
    expect(
        ContentCache.read(key)!.data.contentRendered.startsWith('y'), isTrue);
  });

  test(
      'version 2 migration preserves body expiration and cursor, and removes orphan metadata',
      () async {
    final key = ContentCache.key('topic:42', 1);
    await ContentCache.write(key, detail('42'));
    final timestamp =
        DateTime.now().subtract(const Duration(days: 6)).millisecondsSinceEpoch;
    await getBox().put(
        key,
        Map.of(getBox().get(key) as Map)
          ..['version'] = 2
          ..['savedAt'] = timestamp
          ..['lastAccess'] = timestamp
          ..['progress'] =
              const ReadingProgress(replyId: 'r100', floorNumber: 100, page: 1)
                  .toMap());
    await getBox().delete(ContentCache.metadataKey(key));
    await getBox().put(
        ContentCache.metadataKey(ContentCache.key('topic:orphan', 1)),
        {'lastAccess': timestamp});
    await ContentCache.cleanUp();
    expect((getBox().get(key) as Map)['version'], 3);
    expect((getBox().get(key) as Map)['savedAt'], timestamp);
    expect((getBox().get(key) as Map).containsKey('progress'), isFalse);
    expect(ContentCache.read(key)!.progress!.floorNumber, 100);
    expect(
        getBox().containsKey(
            ContentCache.metadataKey(ContentCache.key('topic:orphan', 1))),
        isFalse);
    await getBox().put(
        key,
        Map.of(getBox().get(key) as Map)
          ..['savedAt'] = DateTime.now()
              .subtract(const Duration(days: 8))
              .millisecondsSinceEpoch);
    await ContentCache.cleanUp();
    expect(getBox().containsKey(key), isFalse);
    expect(getBox().containsKey(ContentCache.metadataKey(key)), isFalse);
  });
}
