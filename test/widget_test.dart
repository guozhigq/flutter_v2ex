// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:flutter_v2ex/main.dart';
import 'package:flutter_v2ex/utils/storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel pathProviderChannel =
      MethodChannel('plugins.flutter.io/path_provider');
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('flutter_v2ex_test');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      pathProviderChannel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getTemporaryDirectory':
          case 'getApplicationSupportDirectory':
          case 'getLibraryDirectory':
          case 'getApplicationDocumentsDirectory':
          case 'getApplicationCacheDirectory':
          case 'getDownloadsDirectory':
          case 'getStorageDirectory':
            return tempDir.path;
          case 'getExternalCacheDirectories':
          case 'getExternalStorageDirectories':
            return <String>[tempDir.path];
          default:
            return tempDir.path;
        }
      },
    );
    await GetStorage.init();
    await GStorage().setAutoUpdate(false);
  });

  tearDownAll(() async {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(pathProviderChannel, null);
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  testWidgets('App renders the GetMaterialApp shell', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(
      enableBackgroundTasks: false,
      homeOverride: SizedBox.shrink(),
    ));
    await tester.pump();

    expect(find.byType(GetMaterialApp), findsOneWidget);
  });
}
