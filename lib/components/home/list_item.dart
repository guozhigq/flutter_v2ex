import 'dart:math';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter_v2ex/pages/t/controller.dart';
import 'package:flutter_v2ex/utils/global.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_v2ex/service/i18n_keyword.dart';
import 'package:flutter_v2ex/components/common/avatar.dart';
import 'package:flutter_v2ex/models/web/item_tab_topic.dart';
import 'package:flutter_v2ex/components/common/node_tag.dart';

// ignore: must_be_immutable
class ListItem extends StatefulWidget {
  final TabTopicItem topic;

  const ListItem({required this.topic, super.key});

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem>
    with SingleTickerProviderStateMixin {
  TabTopicItem topic = TabTopicItem();
  final TopicController _topicController = Get.put(TopicController());

  @override
  void initState() {
    super.initState();
    topic = widget.topic;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 0, right: 0, bottom: 7, left: 0),
      child: Material(
        color: getBackground(context, 'listItem'),
        // color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () async {
            setState(() {
              topic.readStatus = 'read';
            });

            /// 增加200毫秒延迟 水波纹动画
            await Future.delayed(const Duration(milliseconds: 200));
            var arguments = <String, dynamic>{
              "topic": topic,
              "heroTag": '${topic.topicId}${topic.memberId}'
            };
            if (context.mounted && Breakpoints.large.isActive(context)) {
              // eventBus.emit('topicDetail', topic);
              _topicController.setTopic(topic);
            } else {
              Get.toNamed("/t/${topic.topicId}", arguments: arguments);
            }
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
    final herotag = topic.memberId + Random().nextInt(999).toString();
    TextStyle timeStyle = Theme.of(context)
        .textTheme
        .labelSmall!
        .copyWith(color: Theme.of(context).colorScheme.outline);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // title
        Text(
          Characters(topic.topicTitle).join('\u{200B}'),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                height: 1.6,
                fontWeight: FontWeight.w500,
                color: topic.readStatus == 'unread'
                    ? null
                    : Theme.of(context).colorScheme.outline,
              ),
        ),
        const SizedBox(height: 12),
        // 头像、昵称
        LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              // 两端对齐
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () =>
                          Get.toNamed('/member/${topic.memberId}', parameters: {
                        'memberAvatar': topic.avatar,
                        'heroTag': herotag,
                      }),
                      child: Hero(
                        tag: herotag,
                        child: CAvatar(
                          url: topic.avatar,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          child: Text(
                            topic.memberId,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: topic.readStatus == 'unread'
                                      ? null
                                      : Theme.of(context).colorScheme.outline,
                                ),
                          ),
                        ),
                        const SizedBox(height: 1.5),
                        Row(
                          children: [
                            if (topic.lastReplyTime.isNotEmpty) ...[
                              Text(topic.lastReplyTime, style: timeStyle),
                            ],
                            if (topic.replyCount > 0) ...[
                              const SizedBox(width: 10),
                              Text(
                                '${topic.replyCount} ${I18nKeyword.replies.tr}',
                                style: timeStyle,
                              ),
                            ]
                          ],
                        )
                      ],
                    )
                  ],
                ),
                if (topic.nodeName.isNotEmpty &&
                    constraints.maxWidth > 280) ...[
                  Opacity(
                    opacity: topic.readStatus == 'unread' ? 1 : 0.6,
                    child: NodeTag(
                        nodeId: topic.nodeId,
                        nodeName: topic.nodeName,
                        route: 'home'),
                  ),
                ]
              ],
            );
          },
        ),
      ],
    );
  }
}
