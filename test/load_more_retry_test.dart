import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_v2ex/components/common/load_more_retry.dart';
import 'package:flutter_v2ex/components/common/pull_refresh.dart';

void main() {
  testWidgets('upward retry also works inside the shared refresh component',
      (tester) async {
    final controller = ScrollController();
    var attempts = 0;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: PullRefresh(
      currentPage: 1,
      totalPage: 3,
      child: LoadMoreRetry(
          hasError: true,
          onRetry: () => attempts++,
          child: CustomScrollView(controller: controller, slivers: const [
            SliverToBoxAdapter(child: SizedBox(height: 1200)),
            SliverToBoxAdapter(child: SizedBox(height: 48)),
          ])),
    ))));
    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -180));
    await tester.pumpAndSettle();
    expect(attempts, 1);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets('a new upward drag at the end retries once', (tester) async {
    final controller = ScrollController();
    var attempts = 0;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: LoadMoreRetry(
      hasError: true,
      onRetry: () => attempts++,
      child: ListView(
          controller: controller,
          physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics()),
          children: const [SizedBox(height: 1200), SizedBox(height: 48)]),
    ))));
    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();
    await tester.drag(find.byType(ListView), const Offset(0, -180));
    await tester.pumpAndSettle();
    expect(attempts, 1);
    await tester.drag(find.byType(ListView), const Offset(0, -180));
    await tester.pumpAndSettle();
    expect(attempts, 2);
    // Retry still works without any persistent footer control or message.
    expect(find.byType(TextButton), findsNothing);
    expect(find.text('加载失败，上滑重试'), findsNothing);
    expect(attempts, 2);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets('failure during an existing gesture waits for the next drag',
      (tester) async {
    final error = ValueNotifier(false);
    final controller = ScrollController();
    var attempts = 0;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: ValueListenableBuilder<bool>(
      valueListenable: error,
      builder: (_, failed, __) => LoadMoreRetry(
          hasError: failed,
          onRetry: () => attempts++,
          child: ListView(
              controller: controller,
              physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics()),
              children: const [SizedBox(height: 1200), SizedBox(height: 48)])),
    ))));
    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();
    final drag =
        await tester.startGesture(tester.getCenter(find.byType(ListView)));
    await drag.moveBy(const Offset(0, -70));
    await tester.pump();
    error.value = true;
    await tester.pump();
    await drag.moveBy(const Offset(0, -100));
    await tester.pump();
    expect(attempts, 0);
    await drag.up();
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -150));
    await tester.pumpAndSettle();
    expect(attempts, 1);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    error.dispose();
  });

  testWidgets('another failure in the same retry gesture cannot loop',
      (tester) async {
    final error = ValueNotifier(true);
    final controller = ScrollController();
    var attempts = 0;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: ValueListenableBuilder<bool>(
      valueListenable: error,
      builder: (_, failed, __) => LoadMoreRetry(
          hasError: failed,
          onRetry: () {
            attempts++;
            error.value = false;
          },
          child: ListView(
              controller: controller,
              physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics()),
              children: const [SizedBox(height: 1200), SizedBox(height: 48)])),
    ))));
    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();
    final drag =
        await tester.startGesture(tester.getCenter(find.byType(ListView)));
    await drag.moveBy(const Offset(0, -100));
    await tester.pump();
    expect(attempts, 1);
    error.value = true;
    await tester.pump();
    await drag.moveBy(const Offset(0, -100));
    await tester.pump();
    expect(attempts, 1);
    await drag.up();
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    error.dispose();
  });

  testWidgets('downward drag and programmatic scrolling never retry',
      (tester) async {
    final controller = ScrollController();
    var attempts = 0;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: LoadMoreRetry(
      hasError: true,
      onRetry: () => attempts++,
      child: ListView(
          controller: controller,
          children: const [SizedBox(height: 1200), SizedBox(height: 48)]),
    ))));
    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();
    expect(attempts, 0);
    await tester.drag(find.byType(ListView), const Offset(0, 150));
    await tester.pumpAndSettle();
    expect(attempts, 0);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });
}
