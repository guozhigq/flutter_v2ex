import 'package:flutter/material.dart';
import 'package:flutter_v2ex/models/web/item_tab_topic.dart';
import 'package:flutter_v2ex/pages/list_detail.dart';

// ignore: must_be_immutable
class ListItem extends StatefulWidget {
  final TabTopicItem topic;

  const ListItem({required this.topic, super.key});
  // List<TabTopicItem> item;

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(top: 0, right: 0, bottom: 8, left: 0),
        child: Material(
          color: Theme.of(context).colorScheme.onInverseSurface,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ListDetail(topicId: widget.topic.topicId),
                ),
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(15),
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
        // 头像、昵称
        Row(
          // 两端对齐
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  clipBehavior: Clip.antiAlias,
                  margin: const EdgeInsets.only(right: 10),
                  child: Image.network(
                    'https://desk-fd.zol-img.com.cn/t_s960x600c5/g6/M00/03/0E/ChMkKWDZLXSICljFAC1U9uUHfekAARQfgG_oL0ALVUO515.jpg',
                    fit: BoxFit.cover,
                    width: 33,
                    height: 33,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.topic.memberId,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    Row(
                      children: [
                        if (widget.topic.lastReplyTime.isNotEmpty) ...[
                          Text(
                            widget.topic.lastReplyTime,
                            style: TextStyle(
                                fontSize: 10.0,
                                height: 1.3,
                                color: Theme.of(context).colorScheme.outline),
                          ),
                          const SizedBox(width: 10),
                        ],
                        if (widget.topic.replyCount.isNotEmpty) ...[
                          Text(
                            '${widget.topic.clickCount}次点击',
                            style: TextStyle(
                                fontSize: 10.0,
                                height: 1.3,
                                color: Theme.of(context).colorScheme.outline),
                          ),
                        ]
                      ],
                    )
                  ],
                )
              ],
            ),
            Material(
              borderRadius: BorderRadius.circular(50),
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 3.5, horizontal: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        widget.topic.replyCount,
                        style: const TextStyle(
                          fontSize: 11.0,
                          textBaseline: TextBaseline.ideographic,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        // title
        Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.only(top: 12, bottom: 3),
          child: Text(
            Characters(widget.topic.topicTitle).join('\u{200B}'),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
