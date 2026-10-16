import 'package:flutter/material.dart';

/// A failed page retries only on a new, deliberate upward drag at the list end.
/// Ballistic scrolling and a failure arriving during the previous drag never retry.
class LoadMoreRetry extends StatefulWidget {
  final bool hasError;
  final VoidCallback onRetry;
  final Widget child;

  const LoadMoreRetry(
      {super.key,
      required this.hasError,
      required this.onRetry,
      required this.child});

  @override
  State<LoadMoreRetry> createState() => _LoadMoreRetryState();
}

class _LoadMoreRetryState extends State<LoadMoreRetry> {
  bool _armed = false;
  bool _attempted = false;
  double _distance = 0;

  bool _onScroll(ScrollNotification notification) {
    if (notification.depth != 0 || notification.metrics.axis != Axis.vertical) {
      return false;
    }
    if (notification is ScrollStartNotification) {
      _armed = notification.dragDetails != null && widget.hasError;
      _attempted = false;
      _distance = 0;
    } else if (notification is ScrollEndNotification) {
      _armed = false;
    } else if (_armed && !_attempted && widget.hasError) {
      double delta = 0;
      if (notification is ScrollUpdateNotification &&
          notification.dragDetails != null) {
        delta = notification.scrollDelta ?? 0;
      } else if (notification is OverscrollNotification &&
          notification.dragDetails != null) {
        delta = notification.overscroll;
      }
      if (notification.metrics.extentAfter <= 72 && delta > 0) {
        _distance += delta;
        if (_distance >= 40) {
          _attempted = true;
          widget.onRetry();
        }
      } else if (delta < 0) {
        _distance = 0;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) =>
      NotificationListener<ScrollNotification>(
          onNotification: _onScroll, child: widget.child);
}

class LoadMoreLoading extends StatelessWidget {
  const LoadMoreLoading({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 10),
          Text('加载中…'),
        ]),
      );
}
