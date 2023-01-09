import 'package:flutter/material.dart';
import 'package:flutter_v2ex/components/go/go_list.dart';
// import 'package:flutter_v2ex/http/dio_web.dart';
// import 'package:flutter_v2ex/models/web/item_tab_topic.dart';

class GoPage extends StatefulWidget {
  GoPage({required this.nodeKey, super.key});
  String nodeKey;
  @override
  State<GoPage> createState() => _GoPageState();
}

class _GoPageState extends State<GoPage> {
  @override
  void initState() {
    super.initState();
    print(widget.nodeKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        appBar: AppBar(
          title: const Text('节点'),
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        ),
        body: GoList(nodeKey: widget.nodeKey));
  }
}
