import 'package:flutter/material.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  '消息提醒',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                centerTitle: false,
                titlePadding:
                    const EdgeInsetsDirectional.only(start: 42, bottom: 16),
                expandedTitleScale: 1.5),
          ),
        ],
      ),
    );
  }
}
