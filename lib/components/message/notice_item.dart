import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_v2ex/utils/string.dart';
import 'package:flutter_v2ex/components/common/avatar.dart';
import 'package:flutter_v2ex/components/topic/html_render.dart';
import 'package:flutter_v2ex/models/web/item_member_notice.dart';

// TODO 样式
class NoticeItem extends StatefulWidget {
  final MemberNoticeItem noticeItem;
  final Function? onDeleteNotice;

  const NoticeItem({required this.noticeItem, this.onDeleteNotice, Key? key})
      : super(key: key);

  @override
  State<NoticeItem> createState() => _NoticeItemState();
}

class _NoticeItemState extends State<NoticeItem> {
  @override
  void initState() {
    super.initState();
  }

  void doNothing(BuildContext context) {
    print(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 0, right: 12, bottom: 7, left: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.hardEdge,
      child: Dismissible(
        movementDuration: const Duration(milliseconds: 300),
        background: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.clear_all_rounded),
                SizedBox(width: 6),
                Text('删除')
              ],
            )),
        direction: DismissDirection.endToStart,
        key: ValueKey<String>(widget.noticeItem.delIdOne),
        onDismissed: (DismissDirection direction) {
          widget.onDeleteNotice?.call();
        },
        child: Material(
          color: Theme.of(context).colorScheme.onInverseSurface,
          child: InkWell(
            onTap: () {
              String floorNumber =
                  widget.noticeItem.topicHref.split('#reply')[1];
              NoticeType noticeType = widget.noticeItem.noticeType;
              Map<String, String> parameters = {};
              if (noticeType.name == NoticeType.reply.name ||
                  noticeType.name == NoticeType.thanksReply.name) {
                // 回复 or 感谢回复
                parameters = {'source': 'notice', 'floorNumber': floorNumber};
              }
              Get.toNamed('/t/${widget.noticeItem.topicId}',
                  parameters: parameters);
            },
            child: Ink(
              padding: const EdgeInsets.fromLTRB(15, 15, 5, 15),
              child: content(),
            ),
          ),
        ),
      ),
    );
  }

  Widget content() {
    final herotag =
        widget.noticeItem.memberId + Random().nextInt(999).toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.noticeItem.topicTitleHtml != null)
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(top: 2, bottom: 10, right: 10),
            // child: Text(
            //   Characters(widget.noticeItem.replyContent).join('\u{200B}'),
            //   style: Theme.of(context)
            //       .textTheme
            //       .titleSmall!
            //       .copyWith(height: 1.6, fontWeight: FontWeight.w500),
            // ),
            child: HtmlRender(
              htmlContent: widget.noticeItem.topicTitleHtml,
            ),
          ),
        if (widget.noticeItem.replyContentHtml != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(right: 10, bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Theme.of(context).colorScheme.surface,
                border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.1))),
            // child: Text(widget.noticeItem.topicTitle),
            child: HtmlRender(
              htmlContent: widget.noticeItem.replyContentHtml,
            ),
          ),
        Row(
          // 两端对齐
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                GestureDetector(
                  onTap: () => Get.toNamed(
                      '/member/${widget.noticeItem.memberId}',
                      parameters: {
                        'memberAvatar': widget.noticeItem.memberAvatar,
                        'heroTag': herotag,
                      }),
                  child: Hero(
                    tag: herotag,
                    child: CAvatar(
                      url: widget.noticeItem.memberAvatar,
                      size: 33,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 150,
                      child: Text(
                        widget.noticeItem.memberId,
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
                        if (widget.noticeItem.replyTime.isNotEmpty) ...[
                          Text(
                            widget.noticeItem.replyTime,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.outline),
                          ),
                        ],
                      ],
                    )
                  ],
                )
              ],
            ),
          ],
        ),
      ],
    );
  }
}
