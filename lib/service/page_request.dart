import 'dart:async';

/// Coalesces pagination requests. Refresh invalidates any older response.
class PageRequest {
  int _generation = 0;
  Future<void>? _pending;

  bool accepts(int generation) => generation == _generation;
  bool get isRunning => _pending != null;

  Future<void> run(Future<void> Function(int generation) request,
      {bool refresh = false}) {
    if (!refresh && _pending != null) return _pending!;
    final generation = ++_generation;
    final completer = Completer<void>();
    _pending = completer.future;
    Future<void>(() async {
      try {
        await request(generation);
        completer.complete();
      } catch (error, stack) {
        completer.completeError(error, stack);
      } finally {
        if (accepts(generation)) _pending = null;
      }
    });
    return completer.future;
  }

  void invalidate() {
    _generation++;
    _pending = null;
  }
}
