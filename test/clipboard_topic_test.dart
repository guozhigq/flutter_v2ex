import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:flutter_v2ex/utils/app_scheme.dart';

void main() {
  testWidgets('retries clipboard after Android window gains focus',
      (tester) async {
    final binding = tester.binding;
    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    var readable = false;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async => call.method == 'Clipboard.getData' && readable
          ? {'text': 'https://v2ex.com/t/456'}
          : null,
    );
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
    final links = VvexScheme();
    await links.init();
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    readable = true;
    binding.handleViewFocusChanged(ui.ViewFocusEvent(
      viewId: tester.view.viewId,
      state: ui.ViewFocusState.focused,
      direction: ui.ViewFocusDirection.undefined,
    ));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.text('打开剪贴板中的帖子？'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    links.dispose();
    await tester.pumpWidget(const SizedBox());
    Get.reset();
    binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('clipboard opens the topic and does not prompt again on resume',
      (tester) async {
    final binding = tester.binding;
    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async => call.method == 'Clipboard.getData'
          ? {'text': '分享 https://v2ex.com/t/123?p=2#r_456'}
          : null,
    );
    await tester.pumpWidget(GetMaterialApp(
      home: const Scaffold(body: Text('home')),
      getPages: [
        GetPage(
            name: '/t/:topicId',
            page: () => Scaffold(
                  body: Text('topic ${Get.parameters}'),
                )),
      ],
    ));
    final links = VvexScheme();
    final initialization = links.init();
    await tester.pumpAndSettle();
    expect(find.text('打开剪贴板中的帖子？'), findsOneWidget);
    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();
    await initialization;
    expect(Get.parameters['topicId'], '123');
    expect(Get.parameters['p'], '2');
    expect(Get.parameters['replyId'], '456');
    Get.back();
    await tester.pumpAndSettle();
    binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    links.dispose();
    await tester.pumpWidget(const SizedBox());
    Get.reset();
    binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });
}
