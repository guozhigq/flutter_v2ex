import 'package:flutter/material.dart';
import 'package:flutter_v2ex/components/common/avatar.dart';

class ScaleAnimationRoute extends StatefulWidget {
  String? topicId;
  ScaleAnimationRoute({this.topicId = '1', Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ScaleAnimationRouteState createState() => _ScaleAnimationRouteState();
}

//需要继承TickerProvider，如果有多个AnimationController，则应该使用TickerProviderStateMixin。
class _ScaleAnimationRouteState extends State<ScaleAnimationRoute> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('animation'),
      ),
      body: SizedBox(
        width: double.infinity,
        height: 100,
        child: Center(
          child: Hero(
            tag: widget.topicId!,
            child: const CAvatar(
              url: '',
              size: 55,
            ),
          ),
        ),
      ),
    );
  }

  @override
  dispose() {
    super.dispose();
  }
}
