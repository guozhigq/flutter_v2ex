import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive/hive.dart';
import 'package:flutter_v2ex/components/home/tab_bar_list.dart';
import 'package:flutter_v2ex/http/init.dart';
import 'package:flutter_v2ex/http/interceptor.dart';
import 'package:flutter_v2ex/models/tabs.dart';
import 'package:flutter_v2ex/models/web/item_tab_topic.dart';
import 'package:flutter_v2ex/pages/page_home.dart';
import 'package:flutter_v2ex/pages/search/controller.dart';
import 'package:flutter_v2ex/service/content_cache.dart';
import 'package:flutter_v2ex/utils/storage.dart';

class OfflineAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  String? nextPageHtml;
  Completer<ResponseBody>? pendingPage;
  Completer<void>? searchStarted;
  Completer<ResponseBody>? searchResponse;
  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    if (options.uri.host == 'www.sov2ex.com' && searchResponse != null) {
      if (!searchStarted!.isCompleted) searchStarted!.complete();
      return searchResponse!.future;
    }
    if (options.queryParameters['p'] == 2 && pendingPage != null) {
      return pendingPage!.future;
    }
    if (options.queryParameters['p'] == 2 && nextPageHtml != null) {
      return ResponseBody.fromString(nextPageHtml!, 200, headers: {
        Headers.contentTypeHeader: ['text/html; charset=utf-8']
      });
    }
    return ResponseBody.fromString('Unavailable', 503);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late OfflineAdapter adapter;

  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('vvex_network_feedback');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (_) async => directory.path);
    await GetStorage('GetStorage', directory.path).initStorage;
    await GStorage().setLoginStatus(false);
    await GStorage().setUserInfo({});
    Hive.init(directory.path);
    Hive.registerAdapter(TabTopicItemAdapter());
    await Hive.openBox(ContentCache.boxName);
    await Hive.openBox('recentSearchBox');
    Request();
    await Request().setCookie();
    Request.dio.interceptors.clear();
    Request.dio.interceptors.add(ApiInterceptor());
    adapter = OfflineAdapter();
    Request.dio.httpClientAdapter = adapter;
  });

  setUp(() async {
    adapter.requests.clear();
    adapter.nextPageHtml = null;
    adapter.pendingPage = null;
    adapter.searchStarted = null;
    adapter.searchResponse = null;
    await Hive.box(ContentCache.boxName).clear();
    await ContentCache.write(ContentCache.key('home:recent:recent', 1), {
      'topicList': List.generate(
          20,
          (i) => TabTopicItem()
            ..topicId = '$i'
            ..topicTitle = '第一页 $i'
            ..memberId = 'reader'),
      'childNodeList': [],
    });
  });

  tearDownAll(() async {
    Request.dio.close(force: true);
    await Hive.close();
    try {
      await directory.delete(recursive: true);
    } on FileSystemException {
      if (!Platform.isWindows) rethrow;
    }
  });

  testWidgets(
      'cached launch is quiet, refresh and pagination toast once without a footer',
      (tester) async {
    Get.testMode = true;
    Get.put(HomeController());
    final cached = List.generate(
        20,
        (i) => TabTopicItem()
          ..topicId = '$i'
          ..topicTitle = '已保存的帖子 $i'
          ..memberId = 'reader');
    await tester.runAsync(() => ContentCache.write(
        ContentCache.key('home:recent:recent', 1),
        {'topicList': cached, 'childNodeList': []}));
    final messages = <String>[];
    final cachedTitle = find.byWidgetPredicate((widget) =>
        widget is Text && widget.data?.replaceAll('\u200B', '') == '已保存的帖子 0');
    await tester.pumpWidget(GetMaterialApp(
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(toastBuilder: (message) {
        messages.add(message);
        return Text(message);
      }),
      home: Scaffold(
          body: TabBarList(tabItem: TabModel('最新', 'recent', 'recent', true))),
    ));
    await tester.pumpAndSettle();
    expect(cachedTitle, findsOneWidget);
    expect(find.textContaining('缓存'), findsNothing);
    expect(messages, isEmpty);
    expect(adapter.requests, hasLength(1));

    final refresh = tester
        .state<RefreshIndicatorState>(find.byType(RefreshIndicator))
        .show();
    await tester.pumpAndSettle();
    await refresh;
    expect(cachedTitle, findsOneWidget);
    expect(messages, ['刷新失败，已保留当前内容']);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    final scroll = tester.widget<ListView>(find.byType(ListView)).controller!;
    scroll.jumpTo(scroll.position.maxScrollExtent);
    await tester.pumpAndSettle();
    expect(find.text('加载失败，上滑重试'), findsNothing);
    expect(messages, ['刷新失败，已保留当前内容', '加载失败，请上滑重试']);
    expect(adapter.requests.map((r) => r.queryParameters['p']), [1, 1, 2]);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('加载失败，请上滑重试'), findsNothing);
    expect(adapter.requests, hasLength(3));
    await tester.drag(find.byType(ListView), const Offset(0, -160));
    await tester.pumpAndSettle();
    expect(adapter.requests.map((r) => r.queryParameters['p']), [1, 1, 2, 2]);
    expect(find.text('加载失败，上滑重试'), findsNothing);
    expect(messages, ['刷新失败，已保留当前内容', '加载失败，请上滑重试', '加载失败，请上滑重试']);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('加载失败，请上滑重试'), findsNothing);
    expect(
        adapter.requests.every((r) => r.extra['silentError'] == true), isTrue);
    await tester.pumpWidget(const SizedBox());
    Get.reset();
  });

  testWidgets(
      'prefetch failure stays quiet and never appends a disk cached next page',
      (tester) async {
    adapter.requests.clear();
    Get.testMode = true;
    Get.put(HomeController());
    await tester.runAsync(() => ContentCache.write(
          ContentCache.key('home:recent:recent', 1),
          {
            'topicList': List.generate(
                20,
                (i) => TabTopicItem()
                  ..topicId = '$i'
                  ..topicTitle = '第一页 $i'
                  ..memberId = 'reader'),
            'childNodeList': []
          },
        ));
    await tester.runAsync(() => ContentCache.write(
          ContentCache.key('home:recent:recent', 2),
          {
            'topicList': List.generate(
                20,
                (i) => TabTopicItem()
                  ..topicId = '${i + 20}'
                  ..topicTitle = '离线的下一页 ${i + 20}'
                  ..memberId = 'reader'),
            'childNodeList': []
          },
        ));
    final messages = <String>[];
    await tester.pumpWidget(GetMaterialApp(
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(toastBuilder: (message) {
        messages.add(message);
        return Text(message);
      }),
      home: Scaffold(
          body: TabBarList(tabItem: TabModel('最新', 'recent', 'recent', true))),
    ));
    await tester.pumpAndSettle();
    final scroll = tester.widget<ListView>(find.byType(ListView)).controller!;
    scroll.jumpTo(scroll.position.maxScrollExtent - 400);
    await tester.pumpAndSettle();
    final delegate =
        tester.widget<ListView>(find.byType(ListView)).childrenDelegate;
    expect(delegate.estimatedChildCount, 21);
    expect(adapter.requests.map((r) => r.queryParameters['p']), [1, 2]);
    expect(messages, isEmpty);
    scroll.jumpTo(scroll.offset + 20);
    await tester.pumpAndSettle();
    expect(adapter.requests, hasLength(2));
    scroll.jumpTo(scroll.position.maxScrollExtent);
    await tester.pumpAndSettle();
    expect(adapter.requests.map((r) => r.queryParameters['p']), [1, 2, 2]);
    expect(
        tester
            .widget<ListView>(find.byType(ListView))
            .childrenDelegate
            .estimatedChildCount,
        21);
    expect(messages, ['加载失败，请上滑重试']);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('加载失败，请上滑重试'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    Get.reset();
  });
  testWidgets(
      'successful prefetch appends immediately without persisting page 2',
      (tester) async {
    adapter.requests.clear();
    adapter.nextPageHtml = List.generate(
            20,
            (i) =>
                '<div class="cell item"><span class="item_title"><a href="/t/${100 + i}">新帖子 $i</a></span></div>')
        .join();
    await tester.runAsync(() => Hive.box(ContentCache.boxName)
        .delete(ContentCache.key('home:recent:recent', 2)));
    Get.testMode = true;
    Get.put(HomeController());
    final messages = <String>[];
    await tester.pumpWidget(GetMaterialApp(
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(toastBuilder: (message) {
        messages.add(message);
        return Text(message);
      }),
      home: Scaffold(
          body: TabBarList(tabItem: TabModel('最新', 'recent', 'recent', true))),
    ));
    await tester.pumpAndSettle();
    final scroll = tester.widget<ListView>(find.byType(ListView)).controller!;
    scroll.jumpTo(scroll.position.maxScrollExtent - 400);
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<ListView>(find.byType(ListView))
            .childrenDelegate
            .estimatedChildCount,
        41);
    expect(adapter.requests.map((r) => r.queryParameters['p']), [1, 2]);
    expect(messages, isEmpty);
    expect(
        ContentCache.read(ContentCache.key('home:recent:recent', 2)), isNull);
    await tester.pumpWidget(const SizedBox());
    adapter.nextPageHtml = null;
    Get.reset();
  });
  testWidgets(
      'reaching the end during prefetch shares its request and reports failure',
      (tester) async {
    adapter.pendingPage = Completer<ResponseBody>();
    Get.testMode = true;
    Get.put(HomeController());
    final messages = <String>[];
    await tester.pumpWidget(GetMaterialApp(
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(toastBuilder: (message) {
        messages.add(message);
        return Text(message);
      }),
      home: Scaffold(
          body: TabBarList(tabItem: TabModel('最新', 'recent', 'recent', true))),
    ));
    await tester.pumpAndSettle();
    final scroll = tester.widget<ListView>(find.byType(ListView)).controller!;
    scroll.jumpTo(scroll.position.maxScrollExtent - 400);
    await tester.pumpAndSettle();
    expect(adapter.requests.map((r) => r.queryParameters['p']), [1, 2]);
    expect(messages, isEmpty);
    scroll.jumpTo(scroll.position.maxScrollExtent);
    await tester.pump();
    adapter.pendingPage!.complete(ResponseBody.fromString('Unavailable', 503));
    await tester.pumpAndSettle();
    expect(adapter.requests.map((r) => r.queryParameters['p']), [1, 2]);
    expect(messages, ['加载失败，请上滑重试']);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    Get.reset();
  });
  testWidgets(
      'queued prefetch promoted before starting makes one request and one toast',
      (tester) async {
    adapter.pendingPage = Completer<ResponseBody>();
    Get.testMode = true;
    Get.put(HomeController());
    final messages = <String>[];
    await tester.pumpWidget(GetMaterialApp(
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(toastBuilder: (message) {
        messages.add(message);
        return Text(message);
      }),
      home: Scaffold(
          body: TabBarList(tabItem: TabModel('最新', 'recent', 'recent', true))),
    ));
    await tester.pumpAndSettle();
    final scroll = tester.widget<ListView>(find.byType(ListView)).controller!;
    scroll.jumpTo(scroll.position.maxScrollExtent - 400);
    // Both scroll updates happen before PageRequest's deferred callback starts.
    scroll.jumpTo(scroll.position.maxScrollExtent);
    await tester.pump();
    adapter.pendingPage!.complete(ResponseBody.fromString('Unavailable', 503));
    await tester.pumpAndSettle();
    expect(adapter.requests.map((r) => r.queryParameters['p']), [1, 2]);
    expect(messages, ['加载失败，请上滑重试']);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    Get.reset();
  });
  for (final keyword in ['', '   ']) {
    test('submitting "$keyword" leaves search idle without a request',
        () async {
      final controller = SSearchController();
      addTearDown(controller.onClose);
      controller.errorMessage.value = '旧错误';
      controller.submit(keyword);
      await Future<void>.delayed(Duration.zero);
      expect(controller.isLoading.value, isFalse);
      expect(controller.hasRequest.value, isFalse);
      expect(controller.errorMessage.value, isEmpty);
      expect(adapter.requests, isEmpty);
    });
  }

  for (final succeeds in [true, false]) {
    test('empty submission ignores a late ${succeeds ? 'success' : 'failure'}',
        () async {
      final controller = SSearchController();
      addTearDown(controller.onClose);
      adapter.searchStarted = Completer<void>();
      adapter.searchResponse = Completer<ResponseBody>();
      controller.searchKeyWord.value = 'old query';
      final pending = controller.search();
      await adapter.searchStarted!.future;
      controller.submit('');
      final body = jsonEncode({
        'took': 1,
        'timed_out': false,
        'total': 1,
        'hits': [
          {
            '_index': 'topics',
            '_type': 'topic',
            '_id': '123',
            '_score': 1.0,
            'highlight': <String, dynamic>{},
            '_source': {
              'created': '2026-10-16T00:00:00',
              'member': 'reader',
              'title': 'old result',
              'content': '',
              'node': 1,
              'replies': 0,
              'id': 123,
            },
          },
        ],
      });
      adapter.searchResponse!.complete(ResponseBody.fromString(
          succeeds ? body : jsonEncode({'error': 'Unavailable'}),
          succeeds ? 200 : 503,
          headers: {
            Headers.contentTypeHeader: ['application/json']
          }));
      await pending;
      expect(controller.resultsList, isEmpty);
      expect(controller.currentPage.value, 0);
      expect(controller.isLoading.value, isFalse);
      expect(controller.hasRequest.value, isFalse);
      expect(controller.errorMessage.value, isEmpty);
      expect(adapter.requests, hasLength(1));
    });
  }
}
