import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_v2ex/service/page_request.dart';

void main() {
  test('overlapping pagination shares one request', () async {
    final gate = PageRequest();
    final response = Completer<void>();
    var calls = 0;
    final first = gate.run((_) async {
      calls++;
      await response.future;
    });
    final second = gate.run((_) async {
      calls++;
    });
    expect(identical(first, second), isTrue);
    await Future<void>.delayed(Duration.zero);
    expect(calls, 1);
    response.complete();
    await first;
    expect(gate.isRunning, isFalse);
  });

  test('refresh discards a late pagination response', () async {
    final gate = PageRequest();
    final oldResponse = Completer<void>();
    final displayed = <String>[];
    final old = gate.run((generation) async {
      await oldResponse.future;
      if (gate.accepts(generation)) displayed.add('old page');
    });
    await gate.run((generation) async {
      if (gate.accepts(generation)) displayed.add('refreshed');
    }, refresh: true);
    oldResponse.complete();
    await old;
    expect(displayed, ['refreshed']);
  });

  test('failed request releases the gate and can retry', () async {
    final gate = PageRequest();
    await expectLater(gate.run((_) async {
      throw StateError('offline');
    }), throwsStateError);
    expect(gate.isRunning, isFalse);
    var retried = false;
    await gate.run((_) async {
      retried = true;
    });
    expect(retried, isTrue);
  });

  test('late old completion cannot unlock a newer refresh', () async {
    final gate = PageRequest();
    final oldResponse = Completer<void>();
    final freshResponse = Completer<void>();
    final old = gate.run((_) => oldResponse.future);
    final fresh = gate.run((_) => freshResponse.future, refresh: true);
    oldResponse.complete();
    await old;
    expect(gate.isRunning, isTrue);
    final duplicate = gate.run((_) async {
      fail('duplicate request');
    });
    expect(identical(duplicate, fresh), isTrue);
    freshResponse.complete();
    await fresh;
    expect(gate.isRunning, isFalse);
  });

  test('disposing invalidates outstanding responses', () async {
    final gate = PageRequest();
    final response = Completer<void>();
    var applied = false;
    final pending = gate.run((generation) async {
      await response.future;
      applied = gate.accepts(generation);
    });
    gate.invalidate();
    response.complete();
    await pending;
    expect(applied, isFalse);
  });
}
