import 'dart:io';
import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive/hive.dart';
import 'package:flutter_v2ex/models/web/item_tab_topic.dart';
import 'package:flutter_v2ex/models/web/item_topic_reply.dart';
import 'package:flutter_v2ex/models/web/item_topic_subtle.dart';
import 'package:flutter_v2ex/models/web/model_topic_detail.dart';
import 'package:flutter_v2ex/service/content_cache.dart';
import 'package:flutter_v2ex/utils/storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;

  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('vvex_content_cache');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (_) async => directory.path,
    );
    await GetStorage('GetStorage', directory.path).initStorage;
    Hive.init(directory.path);
    Hive.registerAdapter(TabTopicItemAdapter());
    Hive.registerAdapter(TopicDetailModelAdapter());
    Hive.registerAdapter(ReplyItemAdapter());
    Hive.registerAdapter(TopicSubtleItemAdapter());
    await Hive.openBox(ContentCache.boxName);
  });

  setUp(() async {
    await Hive.box(ContentCache.boxName).clear();
    await GStorage().setLoginStatus(false);
    await GStorage().setUserInfo({});
  });

  tearDownAll(() async {
    await Hive.close();
    // GetStorage keeps a RandomAccessFile open for the process lifetime on Windows.
    try {
      await directory.delete(recursive: true);
    } on FileSystemException {
      if (!Platform.isWindows) rethrow;
    }
  });

  test('cached list survives closing and reopening the database', () async {
    final key = ContentCache.key('home:recent', 1);
    await ContentCache.write(key, {
      'topicList': [TabTopicItem()..topicId = '42']
    });
    await Hive.box(ContentCache.boxName).close();
    await Hive.openBox(ContentCache.boxName);
    final cached = ContentCache.read(key)!;
    expect((cached.data['topicList'] as List).single.topicId, '42');
    expect(
        cached.savedAt
            .isAfter(DateTime.now().subtract(const Duration(minutes: 1))),
        isTrue);
  });

  test('account and page keys do not expose each others content', () async {
    final anonymous = ContentCache.key('topic:42', 1);
    await ContentCache.write(anonymous, 'anonymous');
    await GStorage().setLoginStatus(true);
    await GStorage().setUserInfo({'userName': 'alice'});
    final alice = ContentCache.key('topic:42', 1);
    await ContentCache.write(alice, 'alice');
    await GStorage().setUserInfo({'userName': 'bob'});
    expect(ContentCache.read(ContentCache.key('topic:42', 1)), isNull);
    expect(ContentCache.read(ContentCache.key('topic:42', 2)), isNull);
    expect(ContentCache.read(alice)!.data, 'alice');
    expect(ContentCache.read(anonymous)!.data, 'anonymous');
  });

  test('detail cache persists body and only the requested comments page',
      () async {
    final model = TopicDetailModel()
      ..topicId = '42'
      ..contentRendered = '<p>Offline body</p>'
      ..replyList = [ReplyItem()];
    final key = ContentCache.key('topic:42', 2);
    await ContentCache.write(key, model);
    await Hive.box(ContentCache.boxName).close();
    await Hive.openBox(ContentCache.boxName);
    final cached = ContentCache.read(key)!.data as TopicDetailModel;
    expect(cached.contentRendered, '<p>Offline body</p>');
    expect(cached.replyList, hasLength(1));
    expect(ContentCache.read(ContentCache.key('topic:42', 1)), isNull);
  });

  test('expired and malformed entries are ignored', () async {
    final box = Hive.box(ContentCache.boxName);
    await box.put('old', {
      'savedAt': DateTime.now()
          .subtract(const Duration(days: 8))
          .millisecondsSinceEpoch,
      'data': 'stale'
    });
    await box.put('broken', {'savedAt': 'invalid'});
    expect(ContentCache.read('old'), isNull);
    expect(ContentCache.read('broken'), isNull);
  });

  test('cache has a bounded number of pages and evicts oldest updates',
      () async {
    for (var i = 0; i <= ContentCache.maxEntries; i++) {
      await ContentCache.write('page:$i', i);
    }
    expect(Hive.box(ContentCache.boxName).length, ContentCache.maxEntries);
    expect(ContentCache.read('page:0'), isNull);
    expect(ContentCache.read('page:${ContentCache.maxEntries}')!.data,
        ContentCache.maxEntries);
  });
}
