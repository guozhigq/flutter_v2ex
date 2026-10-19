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
import 'package:flutter_v2ex/pages/page_login.dart';
import 'package:flutter_v2ex/pages/search/controller.dart';
import 'package:flutter_v2ex/pages/search/view.dart';
import 'package:flutter_v2ex/utils/global.dart';
import 'package:flutter_v2ex/utils/login.dart';
import 'package:flutter_v2ex/service/content_cache.dart';
import 'package:flutter_v2ex/utils/storage.dart';

class OfflineAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  String? nextPageHtml;
  Completer<ResponseBody>? pendingPage;
  Completer<void>? searchStarted;
  Completer<ResponseBody>? searchResponse;
  Completer<ResponseBody>? loginResponse;
  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    if (options.path == '/signin' && loginResponse != null) {
      return loginResponse!.future;
    }
    if (options.path == '/_captcha' && loginResponse != null) {
      return ResponseBody.fromBytes(
        base64Decode(
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aX1sAAAAASUVORK5CYII='),
        200,
        headers: {
          Headers.contentTypeHeader: ['image/png']
        },
      );
    }
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
    adapter.loginResponse = null;
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

  testWidgets('captcha loading stays inside form and allows closing login',
      (tester) async {
    adapter.loginResponse = Completer<ResponseBody>();
    await tester.pumpWidget(GetMaterialApp(
      home: const Scaffold(body: Text('previous page')),
      getPages: [GetPage(name: '/login', page: () => const LoginPage())],
    ));
    Get.toNamed('/login');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('加载中…'), findsNothing);
    final placeholder = find.byKey(const ValueKey('captcha-loading'));
    expect(placeholder, findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.widget<Semantics>(placeholder).properties.label, '验证码加载中');
    final fieldRect = tester.getRect(find.byType(TextFormField).at(2));
    final placeholderRect = tester.getRect(placeholder);
    expect(placeholderRect.size, const Size(145, 50));
    expect(placeholderRect.top, closeTo(fieldRect.top + 3, 0.1));
    expect(placeholderRect.right, closeTo(fieldRect.right - 3, 0.1));
    expect(placeholderRect.bottom, closeTo(fieldRect.bottom - 3, 0.1));
    expect(SmartDialog.checkExist(), isFalse);
    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull);
    await tester.tap(find.byTooltip('关闭登录'));
    await tester.pumpAndSettle();
    adapter.loginResponse!
        .complete(ResponseBody.fromString('Unavailable', 503));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsNothing);
    expect(find.text('previous page'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    Get.reset();
  });

  testWidgets('captcha failure offers inline retry without blocking close',
      (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: LoginPage()));
    await tester.pumpAndSettle();
    expect(find.text('加载失败，重试'), findsOneWidget);
    adapter.loginResponse = Completer<ResponseBody>();
    await tester.tap(find.text('加载失败，重试'));
    await tester.pump();
    expect(find.byKey(const ValueKey('captcha-loading')), findsOneWidget);
    expect(find.text('加载中…'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    adapter.loginResponse!
        .complete(ResponseBody.fromString('Unavailable', 503));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    Get.reset();
  });

  testWidgets('captcha image stays centered inside its input and refreshes',
      (tester) async {
    adapter.loginResponse = Completer<ResponseBody>();
    adapter.loginResponse!.complete(ResponseBody.fromString(
        '''
<table>
<tr><td>用户名</td><td><input name="username"></td></tr>
<tr><td>密码</td><td><input value="123"><input class="sl" name="password"></td></tr>
<tr><td>机器人</td><td><input name="captcha"><img src="/_captcha"></td></tr>
</table>
''',
        200,
        headers: {
          Headers.contentTypeHeader: ['text/html; charset=utf-8']
        }));
    await tester.pumpWidget(const GetMaterialApp(home: LoginPage()));
    await tester.pumpAndSettle();
    final image = find.descendant(
      of: find.byTooltip('点击刷新验证码'),
      matching: find.byType(Image),
    );
    expect(image, findsOneWidget);
    final imageRect = tester.getRect(image);
    final fieldRect = tester.getRect(find.byType(TextFormField).at(2));
    expect(imageRect.center.dy, closeTo(fieldRect.center.dy, 1));
    expect(imageRect.top, closeTo(fieldRect.top + 3, 0.1));
    expect(imageRect.bottom, closeTo(fieldRect.bottom - 3, 0.1));
    expect(imageRect.right, closeTo(fieldRect.right - 3, 0.1));
    final clip = tester.widget<ClipRRect>(find
        .ancestor(
          of: image,
          matching: find.byType(ClipRRect),
        )
        .first);
    expect(clip.borderRadius, BorderRadius.circular(4));
    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNotNull);
    adapter.loginResponse = Completer<ResponseBody>();
    await tester.tap(image);
    await tester.pump();
    expect(find.byKey(const ValueKey('captcha-loading')), findsOneWidget);
    expect(find.text('加载中…'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    adapter.loginResponse!
        .complete(ResponseBody.fromString('Unavailable', 503));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    Get.reset();
  });

  test('GET failures expose the resolved error message', () async {
    await expectLater(
      Request().get('https://www.sov2ex.com/api/search',
          extra: {'silentError': true}),
      throwsA(
          isA<String>().having((value) => value, 'message', '服务器异常，请稍后重试！')),
    );
  });

  testWidgets(
      'login prompt dismisses on outside tap and keeps the current page',
      (tester) async {
    await tester.pumpWidget(GetMaterialApp(
      navigatorKey: Routes.navigatorKey,
      home: const Scaffold(body: Text('current page')),
    ));
    Login.loginDialog('该操作需要登录');
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('current page'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    Get.reset();
  });

  testWidgets('clear search shows history and focuses the input',
      (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: SearchPage()));
    await tester.pumpAndSettle();
    final controller = Get.find<SSearchController>();
    controller.searchHistoryList.assignAll(['saved query']);
    controller.searchKeyWord.value = 'flutter';
    controller.controller.value.text = 'flutter';
    controller.hasRequest.value = true;
    controller.replyContentFocusNode.value.unfocus();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('清空搜索'));
    await tester.pumpAndSettle();

    expect(find.byType(SearchPage), findsOneWidget);
    expect(find.text('saved query'), findsOneWidget);
    expect(controller.controller.value.text, isEmpty);
    expect(controller.hasRequest.value, isFalse);
    expect(controller.replyContentFocusNode.value.hasFocus, isTrue);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    Get.reset();
  });

  for (final hasQuery in [false, true]) {
    for (final systemBack in [false, true]) {
      testWidgets(
          'search exits on one ${systemBack ? 'system' : 'toolbar'} back with query=$hasQuery',
          (tester) async {
        await tester.pumpWidget(GetMaterialApp(
          home: const Scaffold(body: Text('previous page')),
          getPages: [GetPage(name: '/search', page: () => const SearchPage())],
        ));
        Get.toNamed('/search');
        await tester.pumpAndSettle();
        final controller = Get.find<SSearchController>();
        if (hasQuery) {
          controller.searchKeyWord.value = 'flutter';
          controller.controller.value.text = 'flutter';
          controller.hasRequest.value = true;
        }
        controller.replyContentFocusNode.value.unfocus();
        await tester.pumpAndSettle();
        if (systemBack) {
          await tester.binding.handlePopRoute();
        } else {
          await tester.tap(find.byType(BackButton));
        }
        await tester.pumpAndSettle();
        expect(find.byType(SearchPage), findsNothing);
        expect(find.text('previous page'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        Get.reset();
      });
    }
  }

  for (final reduceMotion in [false, true]) {
    testWidgets(
        'back to top restores the home toolbar (reduceMotion=$reduceMotion)',
        (tester) async {
      Get.testMode = true;
      final home = Get.put(HomeController());
      await tester.pumpWidget(GetMaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
              size: const Size(800, 600), disableAnimations: reduceMotion),
          child: Scaffold(
            drawer: const Drawer(child: Text('menu contents')),
            body: Column(children: [
              CustomAppBar(stream: home.searchBarStream.stream),
              Expanded(
                child: TabBarList(
                    tabItem: TabModel('最新', 'recent', 'recent', true)),
              ),
            ]),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      final scroll = tester.widget<ListView>(find.byType(ListView)).controller!;
      scroll.jumpTo(650);
      await tester.drag(find.byType(ListView), const Offset(0, -80));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(CustomAppBar)).height, 0);
      final offsetBefore = scroll.offset;
      final button = find.byType(FloatingActionButton);
      await tester.tap(button);
      await tester.pump();
      if (!reduceMotion) {
        await tester.pump(const Duration(milliseconds: 140));
        expect(tester.getSize(find.byType(CustomAppBar)).height,
            allOf(greaterThan(0), lessThan(52)));
        expect(scroll.offset, allOf(greaterThan(0), lessThan(offsetBefore)));
        // Keep the button visible until the list has reached the top.
        final opacity =
            find.ancestor(of: button, matching: find.byType(AnimatedOpacity));
        expect(tester.widget<AnimatedOpacity>(opacity).opacity, 1);
      }
      await tester.pumpAndSettle();
      expect(scroll.offset, 0);
      expect(tester.getSize(find.byType(CustomAppBar)).height, 52);
      expect(find.byIcon(Icons.menu).hitTestable(), findsOneWidget);
      expect(
          find
              .descendant(
                  of: find.byType(CustomAppBar),
                  matching: find.byIcon(Icons.person_rounded))
              .hitTestable(),
          findsOneWidget);
      final opacity =
          find.ancestor(of: button, matching: find.byType(AnimatedOpacity));
      expect(tester.widget<AnimatedOpacity>(opacity).opacity, 0);
      // The restored menu remains usable.
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      expect(find.text('menu contents'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await home.searchBarStream.close();
      Get.reset();
    });
  }

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
