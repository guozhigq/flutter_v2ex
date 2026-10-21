import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive/hive.dart';
import 'package:flutter_v2ex/models/web/model_topic_detail.dart';
import 'package:flutter_v2ex/models/web/item_topic_reply.dart';
import 'package:flutter_v2ex/models/web/item_tab_topic.dart';
import 'package:flutter_v2ex/pages/t/topic_id.dart';
import 'package:flutter_v2ex/components/topic/main.dart';
import 'package:flutter_v2ex/components/topic/reply_item.dart';
import 'package:flutter_v2ex/components/topic/skeleton_main.dart';
import 'package:flutter_v2ex/service/content_cache.dart';
import 'package:flutter_v2ex/utils/storage.dart';

TopicDetailModel page(int p) => TopicDetailModel()
  ..topicId = '42'
  ..createdId = 'author'
  ..topicTitle = '阅读测试主题'
  ..contentRendered = '<p>正文内容</p>'
  ..replyCount = 205
  ..totalPage = 3
  ..replyList =
      (p == 3 ? [201, 203, 205] : [(p - 1) * 100 + 1, p * 100 - 50, p * 100])
          .map((floor) {
    return ReplyItem()
      ..replyId = 'r$floor'
      ..floorNumber = floor
      ..number = '$floor'
      ..userName = 'reader'
      ..contentRendered = '<p>第 $floor 楼的测试回复</p>';
  }).toList();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  final requests = <int>[];
  final messages = <String>[];
  bool failJump = false;
  Future<TopicDetailModel> Function(int)? response;

  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('vvex_reading_resume');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (_) async => directory.path);
    await GetStorage('GetStorage', directory.path).initStorage;
    Hive.init(directory.path);
    Hive.registerAdapter(TabTopicItemAdapter());
  });
  setUp(() async {
    await Hive.openBox(ContentCache.boxName, bytes: Uint8List(0));
    await Hive.openBox('recentTopicsBox', bytes: Uint8List(0));
    GetStorage().writeInMemory(StoreKeys.loginStatus.toString(), false);
    GetStorage().writeInMemory(StoreKeys.userInfo.toString(), {});
    GetStorage().writeInMemory(StoreKeys.expendAppBar.toString(), false);
    requests.clear();
    messages.clear();
    failJump = false;
    response = null;
  });
  tearDown(() {
    Get.reset();
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

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await settle(tester);
    await ContentCache.cleanUp();
    await Hive.close();
  }

  Future<void> mount(WidgetTester tester,
      {int? explicitFloor, bool settlePage = true}) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    Get.testMode = true;
    await tester.pumpWidget(GetMaterialApp(
      home: const Scaffold(body: Text('start')),
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(toastBuilder: (message) {
        messages.add(message);
        return Text(message);
      }),
      getPages: [
        GetPage(
            name: '/t/:topicId',
            page: () => TopicDetail(loadDetail: (id, p) async {
                  requests.add(p);
                  if (response != null) return response!(p);
                  if (failJump && requests.length > 1) {
                    throw StateError('offline');
                  }
                  return page(p);
                }))
      ],
    ));
    Get.toNamed('/t/42',
        parameters: explicitFloor == null
            ? null
            : {
                'source': 'notice',
                'floorNumber': '$explicitFloor',
              });
    if (settlePage) {
      await settle(tester);
    } else {
      await tester.pump();
      await tester.pump();
    }
  }

  testWidgets(
      'cached detail appears on the first frame and resumes offline without another request',
      (tester) async {
    final key = ContentCache.key('topic:42', 1);
    await ContentCache.write(key, page(1)..topicTitle = '缓存正文');
    await ContentCache.saveProgress(
        key, const ReadingProgress(replyId: 'r50', floorNumber: 50, page: 1));
    final network = Completer<TopicDetailModel>();
    response = (_) => network.future;
    await mount(tester, settlePage: false);
    expect(
        tester.widget<TopicMain>(find.byType(TopicMain)).detailModel.topicTitle,
        '缓存正文');
    expect(find.byType(TopicDetailSkeleton), findsNothing);
    await tester.pump(const Duration(milliseconds: 100));
    expect(requests, [1]);
    network.completeError(StateError('offline'));
    await settle(tester);
    expect(messages, isEmpty);
    expect(find.text('缓存正文'), findsWidgets);
    await tester.ensureVisible(find.text('继续阅读'));
    await tester.tap(find.text('继续阅读'));
    await settle(tester);
    expect(requests, [1]);
    expect(find.text('继续阅读'), findsNothing);
    expect(ContentCache.read(key)!.progress!.floorNumber, 50);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('late initial refresh cannot move reading after a local resume',
      (tester) async {
    final key = ContentCache.key('topic:42', 1);
    TopicDetailModel longReplies() {
      final model = page(1)..totalPage = 1;
      for (final reply in model.replyList) {
        reply.contentRendered =
            '<div style="height: 800px">用于验证用户继续阅读时不会被后台刷新拉回。</div>';
      }
      return model;
    }

    await ContentCache.write(key, longReplies());
    await ContentCache.saveProgress(
        key, const ReadingProgress(replyId: 'r50', floorNumber: 50, page: 1));
    final network = Completer<TopicDetailModel>();
    response = (_) => network.future;
    await mount(tester, settlePage: false);
    await tester.pump(const Duration(milliseconds: 100));
    expect(requests, [1]);
    await tester.tap(find.text('继续阅读'));
    await settle(tester);
    final controller = tester
        .widget<CustomScrollView>(find.byType(CustomScrollView))
        .controller!;
    final resumedOffset = controller.offset;
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
    await settle(tester);
    final readingOffset = controller.offset;
    expect(readingOffset, greaterThan(resumedOffset + 100));
    network.complete(longReplies());
    await settle(tester);
    expect(controller.offset, closeTo(readingOffset, 1));
    expect(find.text('继续阅读'), findsNothing);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('continue asks before jumping and requests only the target page',
      (tester) async {
    final key = ContentCache.key('topic:42', 1);
    await ContentCache.write(key, page(1));
    await ContentCache.saveProgress(
        key, const ReadingProgress(replyId: 'r101', floorNumber: 101, page: 2));
    await mount(tester);
    expect(find.text('上次读到第 101 楼'), findsOneWidget);
    expect(requests, [1]);
    await tester.ensureVisible(find.text('继续阅读'));
    await tester.tap(find.text('继续阅读'));
    await settle(tester);
    expect(requests, [1, 2]);
    expect(find.text('查看更早回复（前 1 页）'), findsOneWidget);
    expect(find.text('上次读到第 101 楼'), findsNothing);
    expect(ContentCache.read(key)!.progress!.floorNumber, 101);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('explicit notification floor 100 overrides saved progress',
      (tester) async {
    final key = ContentCache.key('topic:42', 1);
    await ContentCache.write(key, page(1));
    await ContentCache.saveProgress(
        key, const ReadingProgress(replyId: 'r201', floorNumber: 201, page: 3));
    await mount(tester, explicitFloor: 100);
    expect(find.text('继续阅读'), findsNothing);
    expect(requests.first, 1);
    expect(tester.takeException(), isNull);
    expect(ContentCache.read(key)!.progress!.floorNumber, 201);
    await unmount(tester);
  });

  testWidgets('failed jump preserves current replies and offers retry',
      (tester) async {
    final key = ContentCache.key('topic:42', 1);
    await ContentCache.write(key, page(1));
    await ContentCache.saveProgress(
        key, const ReadingProgress(replyId: 'r101', floorNumber: 101, page: 2));
    await mount(tester);
    failJump = true;
    await tester.tap(find.text('继续阅读'));
    await settle(tester);
    expect(find.text('继续阅读'), findsOneWidget);
    expect(messages, contains('定位失败，已保留当前内容，请重试'));
    expect(ContentCache.read(key)!.progress!.floorNumber, 101);
    failJump = false;
    await tester.tap(find.text('继续阅读'));
    await settle(tester);
    expect(requests, [1, 2, 2]);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets(
      'latest uses last page in ascending order and earlier replies remain accessible',
      (tester) async {
    await mount(tester);
    await tester.ensureVisible(find.text('最新回复'));
    await tester.tap(find.text('最新回复'));
    await settle(tester);
    expect(requests, [1, 3]);
    expect(
        ContentCache.read(ContentCache.key('topic:42', 1))!.progress, isNull);
    tester
        .widget<CustomScrollView>(find.byType(CustomScrollView))
        .controller!
        .jumpTo(0);
    await settle(tester);
    final earlier = find.text('查看更早回复（前 2 页）');
    await tester.ensureVisible(earlier);
    await tester.tap(earlier);
    await settle(tester);
    expect(requests, [1, 3, 2]);
    tester
        .widget<CustomScrollView>(find.byType(CustomScrollView))
        .controller!
        .jumpTo(0);
    await settle(tester);
    expect(find.text('查看更早回复（前 1 页）'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('only deliberate reading saves a cursor after scrolling settles',
      (tester) async {
    await mount(tester);
    final key = ContentCache.key('topic:42', 1);
    expect(ContentCache.read(key)!.progress, isNull);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 850));
    await settle(tester);
    final progress = ContentCache.read(key)!.progress;
    expect(progress, isNotNull);
    expect(progress!.floorNumber, inInclusiveRange(1, 205));
    expect(progress.page, ReadingProgress.pageForFloor(progress.floorNumber));
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets(
      'quick back preserves the reading cursor and long bodies do not hide the resume action',
      (tester) async {
    await mount(tester);
    final key = ContentCache.key('topic:42', 1);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
    // Leave immediately, without waiting for a debounce or ballistic scrolling.
    Get.back();
    await settle(tester);
    final saved = ContentCache.read(key)!.progress;
    expect(saved, isNotNull);
    response = (p) async => page(p)
      ..contentRendered =
          List.filled(80, '<p>很长的正文内容，用于验证继续阅读入口始终出现在正文前。</p>').join();
    Get.toNamed('/t/42');
    await settle(tester);
    expect(find.text('上次读到第 ${saved!.floorNumber} 楼').hitTestable(),
        findsOneWidget);
    expect(find.text('继续阅读').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  for (final expandable in [false, true]) {
    for (final savedPage in [1, 2]) {
      testWidgets(
          'resume aligns reply top and highlights after arrival (expandable=$expandable, page=$savedPage)',
          (tester) async {
        GetStorage()
            .writeInMemory(StoreKeys.expendAppBar.toString(), expandable);
        TopicDetailModel longReplies(int p) {
          final model = page(p);
          for (final reply in model.replyList) {
            reply.contentRendered = '<div style="height: 800px">评论从头阅读</div>';
          }
          return model;
        }

        final floor = (savedPage - 1) * 100 + 1;
        final key = ContentCache.key('topic:42', 1);
        await ContentCache.write(key, longReplies(1));
        await ContentCache.saveProgress(
            key,
            ReadingProgress(
                replyId: 'r$floor',
                floorNumber: floor,
                page: savedPage,
                offsetWithinReply: 750));
        response = (p) async => longReplies(p);
        await mount(tester);
        await tester.tap(find.text('继续阅读'));
        final target = find.byKey(ValueKey('reply-highlight-r$floor'));
        final baseColor =
            Theme.of(tester.element(find.byType(CustomScrollView)))
                .colorScheme
                .surface;
        // Inspect while the arrival highlight is visible, rather than settling it away.
        for (var i = 0; i < 60; i++) {
          await tester.pump(const Duration(milliseconds: 20));
          if (target.evaluate().isNotEmpty &&
              tester.widget<Material>(target).color != baseColor) break;
        }
        final header = find
            .ancestor(of: find.text('205条回复'), matching: find.byType(Container))
            .first;
        final targetRect = tester.getRect(target);
        final headerRect = tester.getRect(header);
        expect(targetRect.top, closeTo(headerRect.bottom, 1));
        expect(find.text('${floor}L').hitTestable(), findsOneWidget);
        expect(tester.widget<Material>(target).color, isNot(baseColor));
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();
        expect(tester.widget<Material>(target).color, baseColor);
        final appTitle = find.ancestor(
            of: find.text('阅读测试主题'), matching: find.byType(AnimatedOpacity));
        expect(appTitle, findsOneWidget);
        expect(tester.widget<AnimatedOpacity>(appTitle).opacity, 1);
        expect(find.text('阅读测试主题').hitTestable(), findsOneWidget);
        tester
            .widget<CustomScrollView>(find.byType(CustomScrollView))
            .controller!
            .jumpTo(0);
        await tester.pumpAndSettle();
        expect(tester.widget<AnimatedOpacity>(appTitle).opacity, 0);
        expect(tester.takeException(), isNull);
        await unmount(tester);
      });
    }
  }

  testWidgets('arrival enlarges once and finishes together with its highlight',
      (tester) async {
    final reply = page(1).replyList.first;
    Future<void> show(int floor, int version) => tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: SingleChildScrollView(
                  child: ReplyListItem(
            key: const ValueKey('arrival-reply'),
            reply: reply,
            topicId: '42',
            source: 'topic',
            replyList: [reply],
            totalPage: 1,
            floorNumber: floor,
            highlightVersion: version,
          ))),
        ));
    double scale() => tester
        .widget<Transform>(
            find.byKey(ValueKey('reply-arrival-scale-${reply.replyId}')))
        .transform
        .entry(0, 0);
    await show(0, 0);
    await tester.pump(const Duration(seconds: 1));
    expect(scale(), 1);
    final highlight = find.byKey(ValueKey('reply-highlight-${reply.replyId}'));
    final baseColor = Theme.of(tester.element(highlight)).colorScheme.surface;
    await show(reply.floorNumber, 1);
    final top = tester
        .getTopLeft(find.byKey(ValueKey('reply-highlight-${reply.replyId}')))
        .dy;
    await tester.pump(const Duration(milliseconds: 150));
    expect(scale(), greaterThan(1));
    expect(tester.widget<Material>(highlight).color, isNot(baseColor));
    await tester.pump(const Duration(milliseconds: 150));
    expect(scale(), closeTo(1.03, 0.001));
    expect(
        tester
            .getTopLeft(
                find.byKey(ValueKey('reply-highlight-${reply.replyId}')))
            .dy,
        top);
    await tester.pump(const Duration(milliseconds: 200));
    expect(scale(), greaterThan(1));
    expect(tester.widget<Material>(highlight).color, isNot(baseColor));
    await tester.pump(const Duration(milliseconds: 100));
    expect(scale(), closeTo(1, 0.000001));
    expect(tester.widget<Material>(highlight).color, baseColor);
    await tester.pump(const Duration(milliseconds: 900));
    expect(scale(), 1);
    await show(reply.floorNumber, 1);
    await tester.pump(const Duration(milliseconds: 150));
    expect(scale(), 1);
    await show(reply.floorNumber, 2);
    await tester.pump(const Duration(milliseconds: 150));
    expect(scale(), greaterThan(1));
    await tester.pumpAndSettle();
    expect(scale(), 1);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets(
      'recycling a reply does not replay its consumed arrival, but a new jump still animates',
      (tester) async {
    TopicDetailModel longReplies() {
      final model = page(1)..totalPage = 1;
      for (final reply in model.replyList) {
        reply.contentRendered =
            '<div style="height: 800px">用于验证评论回收后不重播动画。</div>';
      }
      return model;
    }

    final key = ContentCache.key('topic:42', 1);
    await ContentCache.write(key, longReplies());
    await ContentCache.saveProgress(
        key, const ReadingProgress(replyId: 'r1', floorNumber: 1, page: 1));
    response = (_) async => longReplies();
    await mount(tester);
    await tester.tap(find.text('继续阅读'));
    await settle(tester);
    final target = find.byKey(const ValueKey('reply-highlight-r1'));
    final replyWidget =
        find.ancestor(of: target, matching: find.byType(ReplyListItem)).first;
    final originalState = tester.state(replyWidget);
    final baseColor = Theme.of(tester.element(target)).colorScheme.surface;
    final controller = tester
        .widget<CustomScrollView>(find.byType(CustomScrollView))
        .controller!;
    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();
    expect(target, findsNothing);
    controller.jumpTo(0);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(identical(tester.state(replyWidget), originalState), isFalse);
    final scale = tester
        .widget<Transform>(find.byKey(const ValueKey('reply-arrival-scale-r1')))
        .transform
        .entry(0, 0);
    expect(scale, 1);
    expect(tester.widget<Material>(target).color, baseColor);
    // A fresh navigation request must still produce its own single animation.
    await tester.ensureVisible(find.text('最新回复'));
    await tester.tap(find.text('最新回复'));
    final next = find.byKey(const ValueKey('reply-highlight-r100'));
    for (var i = 0; i < 80; i++) {
      await tester.pump(const Duration(milliseconds: 20));
      if (next.evaluate().isNotEmpty &&
          tester.widget<Material>(next).color != baseColor) break;
    }
    expect(tester.widget<Material>(next).color, isNot(baseColor));
    await tester.pump(const Duration(milliseconds: 150));
    expect(
        tester
            .widget<Transform>(
                find.byKey(const ValueKey('reply-arrival-scale-r100')))
            .transform
            .entry(0, 0),
        greaterThan(1));
    await settle(tester);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });
}
