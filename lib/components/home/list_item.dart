import 'package:flutter/material.dart';
import 'package:flutter_v2ex/components/common/avatar.dart';
import 'package:flutter_v2ex/models/web/item_tab_topic.dart';

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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.only(top: 0, right: 0, bottom: 8, left: 0),
        child: Material(
          color: Theme.of(context).colorScheme.onInverseSurface,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: () {},
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
                // CAvatar(url: widget.topic.avatar, size: 33),
                // const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  clipBehavior: Clip.antiAlias,
                  margin: const EdgeInsets.only(right: 10),
                  // child: Image.network(
                  //   // widget.topic.avatar,
                  //   'https://cdn.v2ex.com/avatar/7265/601c/290989_normal.png?m=1672712228',
                  //   fit: BoxFit.cover,
                  //   width: 33,
                  //   height: 33,
                  // ),
                  width: 33,
                  height: 33,
                  child: Center(
                    child: Text(widget.topic.memberId.substring(0, 1)),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // ignore: sized_box_for_whitespace
                    Container(
                      width: 100,
                      child: Text(
                        widget.topic.memberId,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 13.0,
                          height: 1.5,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        if (widget.topic.lastReplyTime.isNotEmpty) ...[
                          Text(
                            widget.topic.lastReplyTime,
                            style: const TextStyle(
                              fontSize: 10.0,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(width: 7),
                        ],
                        if (widget.topic.replyCount.isNotEmpty) ...[
                          Text(
                            '${widget.topic.replyCount} 评论',
                            style: const TextStyle(
                              fontSize: 10.0,
                              height: 1.3,
                            ),
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
              color:
                  Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
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
                      // const Icon(Icons.workspaces_outlined, size: 14),
                      // const SizedBox(width: 2.5),
                      Text(
                        widget.topic.nodeName,
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
          margin: const EdgeInsets.only(top: 10, bottom: 3),
          child: Text(
            Characters(widget.topic.topicContent).join('\u{200B}'),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 14.0,
            ),
          ),
        ),
      ],
    );
  }
}
