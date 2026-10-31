import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_v2ex/components/common/avatar.dart';
import 'package:flutter_v2ex/components/topic/reply_item.dart';
import 'package:flutter_v2ex/components/topic/reply_new.dart';
import 'package:flutter_v2ex/models/web/item_topic_reply.dart';
import 'package:flutter_v2ex/models/web/model_member_profile.dart';
import 'package:flutter_v2ex/pages/member/member_id.dart';
import 'package:flutter_v2ex/utils/storage.dart';

Future<void> frames(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  setUpAll(() async {
    directory =
        await Directory.systemTemp.createTemp('vvex_comment_interaction');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (_) async => directory.path);
    await GetStorage('GetStorage', directory.path).initStorage;
  });
  setUp(() {
    Get.testMode = true;
    GetStorage().writeInMemory(StoreKeys.loginStatus.toString(), false);
    GetStorage().writeInMemory(StoreKeys.userInfo.toString(), {});
  });
  tearDown(() => Get.reset());
  tearDownAll(() async {
    try {
      await directory.delete(recursive: true);
    } on FileSystemException {
      if (!Platform.isWindows) rethrow;
    }
  });

  for (final area in ['正文', '时间', '楼层', '留白', '头像', '名称']) {
    testWidgets('comment tap on $area dispatches to the intended action',
        (tester) async {
      final reply = ReplyItem()
        ..replyId = 'r50'
        ..userName = 'reader'
        ..lastReplyTime = '5分钟前'
        ..floorNumber = 50
        ..contentRendered = '<p>可以点击的评论正文</p>';
      await tester.pumpWidget(GetMaterialApp(
        home: Scaffold(
          body: ReplyListItem(
            reply: reply,
            topicId: '42',
            source: 'topic',
            totalPage: 1,
            replyList: [reply],
          ),
        ),
        getPages: [
          GetPage(
              name: '/member/:memberId',
              page: () => const Scaffold(body: Text('目标用户主页')))
        ],
      ));
      await frames(tester);
      switch (area) {
        case '正文':
          await tester.tap(find.text('可以点击的评论正文', findRichText: true));
          break;
        case '时间':
          await tester.tap(find.text('5分钟前'));
          break;
        case '楼层':
          await tester.tap(find.text('50L'));
          break;
        case '留白':
          final rect =
              tester.getRect(find.byKey(const ValueKey('reply-highlight-r50')));
          await tester
              .tapAt(Offset(rect.right - 4, rect.top + rect.height / 2));
          break;
        case '头像':
          await tester.tap(find.byType(CAvatar));
          break;
        case '名称':
          await tester.tap(find.text('reader'));
          break;
      }
      await frames(tester);
      if (area == '头像' || area == '名称') {
        expect(find.text('目标用户主页'), findsOneWidget);
        expect(find.byType(ReplyNew), findsNothing);
      } else {
        expect(find.byType(ReplyNew), findsOneWidget);
        expect(find.text('目标用户主页'), findsNothing);
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await frames(tester);
    });
  }

  for (final oldFails in [false, true]) {
    testWidgets(
        'leaving a loading profile isolates its late result (failure=$oldFails)',
        (tester) async {
      final pending = <Completer<ModelMemberProfile>>[];
      final tokens = <CancelToken>[];
      final members = <String>[];
      await tester.pumpWidget(GetMaterialApp(
        home: const Scaffold(body: Text('start')),
        getPages: [
          GetPage(
              name: '/member/:memberId',
              page: () => MemberPage(
                    loadProfile: (id, token) {
                      members.add(id);
                      tokens.add(token);
                      final request = Completer<ModelMemberProfile>();
                      pending.add(request);
                      return request.future;
                    },
                  ))
        ],
      ));
      Get.toNamed('/member/reader');
      await frames(tester);
      expect(pending.length, 1);
      // Rebuilding an already loading route must not submit another request.
      tester.element(find.byType(MemberPage)).markNeedsBuild();
      await tester.pump();
      expect(pending.length, 1);
      Get.back();
      await frames(tester);
      expect(tokens.first.isCancelled, isTrue);
      Get.toNamed('/member/reader');
      await frames(tester);
      expect(members, ['reader', 'reader']);
      expect(identical(tokens.first, tokens.last), isFalse);
      expect(tokens.last.isCancelled, isFalse);
      final fresh = ModelMemberProfile()
        ..memberId = 'reader'
        ..mbSort = '新页面数据'
        ..isEmptyTopic = true
        ..isEmptyReply = true;
      pending.last.complete(fresh);
      await frames(tester);
      if (oldFails) {
        pending.first.completeError(StateError('旧页面请求失败'));
      } else {
        pending.first.complete(ModelMemberProfile()..mbSort = '旧页面数据');
      }
      await frames(tester);
      expect(find.text('新页面数据'), findsOneWidget);
      expect(find.text('旧页面数据'), findsNothing);
      expect(find.text('请求异常'), findsNothing);
      tester.element(find.byType(MemberPage)).markNeedsBuild();
      await frames(tester);
      expect(pending.length, 2);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await frames(tester);
    });
  }

  testWidgets('failed profile keeps its original UI and can reload on reentry',
      (tester) async {
    var calls = 0;
    await tester.pumpWidget(GetMaterialApp(
      home: const Scaffold(body: Text('start')),
      getPages: [
        GetPage(
            name: '/member/:memberId',
            page: () => MemberPage(
                  loadProfile: (_, __) async {
                    if (++calls == 1) throw StateError('offline');
                    return ModelMemberProfile()
                      ..memberId = 'reader'
                      ..isEmptyTopic = true
                      ..isEmptyReply = true;
                  },
                ))
      ],
    ));
    Get.toNamed('/member/reader');
    await frames(tester);
    expect(find.text('请求异常'), findsOneWidget);
    expect(find.byType(AppBar), findsNothing);
    expect(find.byType(SliverAppBar), findsNothing);
    expect(find.byType(TextButton), findsNothing);
    final body = tester.widget<Scaffold>(find.byType(Scaffold).last).body!;
    final bodyRect = tester.getRect(find.byWidget(body));
    expect(tester.getTopLeft(find.text('请求异常')), bodyRect.topLeft);
    tester.element(find.byType(MemberPage)).markNeedsBuild();
    await frames(tester);
    expect(calls, 1);
    Get.back();
    await frames(tester);
    Get.toNamed('/member/reader');
    await frames(tester);
    expect(find.text('reader'), findsOneWidget);
    expect(calls, 2);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await frames(tester);
  });
}
