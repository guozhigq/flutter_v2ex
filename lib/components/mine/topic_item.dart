import 'package:flutter/material.dart';
import 'package:flutter_v2ex/models/web/item_member_topic.dart';
import 'package:flutter_v2ex/components/common/node_tag.dart';
import 'package:flutter_v2ex/pages/list_detail.dart';

class TopicItem extends StatefulWidget {
  MemberTopicItem topicItem;

  TopicItem({required this.topicItem, Key? key}) : super(key: key);

  @override
  State<TopicItem> createState() => _TopicItemState();
}

class _TopicItemState extends State<TopicItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.only(top: 8, right: 12, bottom: 0, left: 12),
        child: Material(
          color: Theme.of(context).colorScheme.onInverseSurface,
          // color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ListDetail(topicId: widget.topicItem.topicId),
                ),
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.fromLTRB(15, 18, 15, 15),
              child: content(),
            ),
          ),
        ),
      ),
    );
  }

  Widget content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.only(bottom: 2),
          child: Text(
            // Characters(widget.topic.topicTitle).join('\u{200B}'),
            widget.topicItem.topicTitle,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(height: 1.6, fontWeight: FontWeight.w500),
          ),
        ),
        Row(
          // 两端对齐
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: [
                Text(
                  widget.topicItem.time,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium!
                      .copyWith(color: Theme.of(context).colorScheme.outline),
                ),
                const SizedBox(width: 10),
                Text(
                  '${widget.topicItem.replyCount}回复',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium!
                      .copyWith(color: Theme.of(context).colorScheme.outline),
                ),
              ],
            ),
            if (widget.topicItem.nodeName.isNotEmpty) ...[
              NodeTag(
                  nodeId: widget.topicItem.nodeId,
                  nodeName: widget.topicItem.nodeName,
                  route: 'home')
            ]
          ],
        ),
        // title
      ],
    );
  }
}
