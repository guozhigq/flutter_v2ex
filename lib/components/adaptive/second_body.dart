import 'package:flutter/material.dart';
import 'package:flutter_v2ex/models/web/item_tab_topic.dart';
import 'package:flutter_v2ex/pages/t/:topicId.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter_v2ex/utils/event_bus.dart';

class SecondBody extends StatefulWidget {
  const SecondBody({Key? key}) : super(key: key);

  @override
  State<SecondBody> createState() => _SecondBodyState();
}

class _SecondBodyState extends State<SecondBody> {
  TabTopicItem? topic;

  @override
  void initState() {
    eventBus.on('topicDetail', (e) {
      setState(() {
        topic = e;
      });
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10, top: 10),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      child: Center(
        child: topic != null ? TopicDetail(topicDetail: topic) : const Text('VVEX'),
        // child: topic != null ? Text(topic!.topicTitle) : const Text('VVEX'),
      ),
    );
  }
}
