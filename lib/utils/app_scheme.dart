import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:appscheme/appscheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_v2ex/utils/logger.dart';
import 'package:flutter_v2ex/utils/topic_link.dart';

class VvexScheme with WidgetsBindingObserver {
  final AppScheme appScheme = AppSchemeImpl.getInstance();
  StreamSubscription<SchemeEntity?>? _subscription;
  bool _disposed = false;
  bool _checkingClipboard = false;
  bool _dialogOpen = false;
  bool _starting = true;
  String? _lastClipboard;
  String? _lastExternal;
  DateTime? _lastExternalTime;
  int _externalRevision = 0;
  Timer? _clipboardTimer;

  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        _subscription = appScheme.registerSchemeListener().listen(
              (event) => _handleExternal(event?.dataString),
              onError: (Object error) => logDebug('Link listener: $error'),
            );
        final initial = await appScheme.getInitScheme();
        if (!_disposed) _handleExternal(initial?.dataString);
      } catch (error) {
        logDebug('Initial link: $error');
      }
    }
    _starting = false;
    if (_lastExternal == null) await _checkClipboard();
  }

  void _handleExternal(String? value) {
    final link = TopicLink.parse(value);
    if (link == null || _disposed) return;
    final now = DateTime.now();
    if (_lastExternal == link.location &&
        _lastExternalTime != null &&
        now.difference(_lastExternalTime!) < const Duration(seconds: 1)) {
      return;
    }
    _lastExternal = link.location;
    _lastExternalTime = now;
    _externalRevision++;
    if (_dialogOpen) Get.back(result: false);
    _open(link);
  }

  void _open(TopicLink link) {
    if (_disposed || Get.currentRoute == link.location) return;
    Get.toNamed(link.route, parameters: link.parameters);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_starting) {
      _scheduleClipboardCheck();
    }
  }

  @override
  void didChangeViewFocus(ui.ViewFocusEvent event) {
    // Android can report resumed before the window is focused. Clipboard reads
    // made in that interval return null; retry when the window actually gains focus.
    if (event.state == ui.ViewFocusState.focused && !_starting) {
      _scheduleClipboardCheck();
    }
  }

  void _scheduleClipboardCheck() {
    _clipboardTimer?.cancel();
    final revision = _externalRevision;
    _clipboardTimer = Timer(const Duration(milliseconds: 400), () {
      if (!_disposed && revision == _externalRevision) _checkClipboard();
    });
  }

  Future<void> _checkClipboard() async {
    if (_disposed ||
        _checkingClipboard ||
        _dialogOpen ||
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }
    _checkingClipboard = true;
    final revision = _externalRevision;
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (_disposed ||
          revision != _externalRevision ||
          WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
        return;
      }
      final text = data?.text;
      if (text == _lastClipboard) return;
      final link = TopicLink.fromText(text);
      if (Get.isDialogOpen == true) return;
      _lastClipboard = text;
      if (link == null || Get.currentRoute == link.location) {
        return;
      }
      _dialogOpen = true;
      final open = await Get.dialog<bool>(AlertDialog(
        title: const Text('打开剪贴板中的帖子？'),
        content: Text('检测到 V2EX 帖子链接：\nhttps://www.v2ex.com${link.location}'),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('取消')),
          TextButton(
              onPressed: () => Get.back(result: true), child: const Text('打开')),
        ],
      ));
      _dialogOpen = false;
      if (open == true && revision == _externalRevision) _open(link);
    } catch (error) {
      logDebug('Clipboard link: $error');
    } finally {
      _dialogOpen = false;
      _checkingClipboard = false;
    }
  }

  void dispose() {
    _disposed = true;
    _clipboardTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
  }
}
