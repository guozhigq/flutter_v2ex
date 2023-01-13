// import 'package:flare_flutter/base/animation/property_types.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_html/style.dart';
import 'package:flutter_v2ex/models/web/item_tab_topic.dart';
import 'package:flutter_v2ex/pages/list_detail.dart';
import 'package:flutter_v2ex/pages/go_page.dart';
import 'package:flutter_v2ex/components/common/avatar.dart';
// import 'package:flutter_v2ex/pages/profile_page.dart';

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
    return GestureDetector(
      child: Container(
        height: 108,
        margin: const EdgeInsets.only(top: 0, right: 0, bottom: 8, left: 0),
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ListDetail(topicId: widget.topic.topicId),
                  // ScaleAnimationRoute(topicId: widget.topic.topicId),
                ),
                // PageRouteBuilder(
                //   transitionDuration:
                //       const Duration(milliseconds: 300), //动画时间为500毫秒
                //   pageBuilder: (BuildContext context, Animation animation,
                //       Animation secondaryAnimation) {
                //     return FadeTransition(
                //       //使用渐隐渐入过渡,
                //       opacity: opacityAnim,
                //       child: ListDetail(
                //         topic: widget.topic,
                //       ), //路由B
                //     );
                //   },
                // ),
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
                  child: CAvatar(
                    url: widget.topic.avatar,
                    size: 33,
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
                        if (widget.topic.replyCount.isNotEmpty) ...[
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
                        ] else ...[
                          Text('0 回复',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline)),
                        ]
                      ],
                    )
                  ],
                )
              ],
            ),
            if (widget.topic.nodeName.isNotEmpty) ...[
              Material(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            GoPage(nodeKey: widget.topic.nodeId),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 3.5, horizontal: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
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
            ]
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
