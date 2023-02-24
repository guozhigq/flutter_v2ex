import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:flutter_v2ex/models/web/item_tab_topic.dart';
import 'package:flutter_v2ex/components/common/avatar.dart';
import 'package:flutter_v2ex/components/common/node_tag.dart';
import 'dart:math';

// ignore: must_be_immutable
class ListItem extends StatefulWidget {
  final TabTopicItem topic;

  const ListItem({required this.topic, super.key});

  // List<TabTopicItem> item;

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> opacityAnim;

  @override
  void initState() {
    super.initState();

    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    opacityAnim = Tween<double>(begin: 0, end: 1.0).animate(_ctrl);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 0, right: 0, bottom: 7, left: 0),
      child: Material(
        color: Theme.of(context).colorScheme.onInverseSurface,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () {
            var arguments = <String, TabTopicItem>{"topic": widget.topic};
            Get.toNamed("/t/${widget.topic.topicId}", arguments: arguments);
          },
          borderRadius: BorderRadius.circular(10),
          child: Ink(
            padding: const EdgeInsets.fromLTRB(12, 15, 12, 12),
            child: content(),
          ),
        ),
      ),
    );
  }

  Widget content() {
    final herotag = widget.topic.memberId + Random().nextInt(999).toString();
    // final herotag = UniqueKey();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // title
        Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.only(top: 0, bottom: 12),
          child: Text(
            Characters(widget.topic.topicTitle).join('\u{200B}'),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(height: 1.6, fontWeight: FontWeight.w500),
          ),
        ),
        // 头像、昵称
        Row(
          // 两端对齐
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                GestureDetector(
                  onTap: () => Get.toNamed('/member/${widget.topic.memberId}',
                      parameters: {
                        'memberAvatar': widget.topic.avatar,
                        'heroTag': herotag,
                      }),
                  child: Hero(
                    tag: herotag,
                    child: CAvatar(
                      url: widget.topic.avatar,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 150,
                      child: Text(
                        widget.topic.memberId,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 1.5),
                    Row(
                      children: [
                        if (widget.topic.lastReplyTime.isNotEmpty) ...[
                          Text(
                            widget.topic.lastReplyTime,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.outline),
                          ),
                        ],
                        if (widget.topic.replyCount > 0) ...[
                          const SizedBox(width: 10),
                          Text(
                            '${widget.topic.replyCount} 回复',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.outline),
                          ),
                        ]
                      ],
                    )
                  ],
                )
              ],
            ),
            if (widget.topic.nodeName.isNotEmpty) ...[
              NodeTag(
                  nodeId: widget.topic.nodeId,
                  nodeName: widget.topic.nodeName,
                  route: 'home')
            ]
          ],
        ),
      ],
    );
  }
}
