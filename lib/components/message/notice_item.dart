import 'package:flutter/material.dart';
import 'package:flutter_v2ex/models/web/item_member_notice.dart';
import 'dart:math';
import 'package:flutter_v2ex/utils/utils.dart';
import 'package:flutter_v2ex/components/common/avatar.dart';
import 'package:flutter_v2ex/components/detail/html_render.dart';

// TODO 样式
class NoticeItem extends StatefulWidget {
  MemberNoticeItem noticeItem = MemberNoticeItem();

  NoticeItem({required this.noticeItem, Key? key}) : super(key: key);

  @override
  State<NoticeItem> createState() => _NoticeItemState();
}

class _NoticeItemState extends State<NoticeItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 0, right: 12, bottom: 7, left: 12),
      child: Material(
        color: Theme.of(context).colorScheme.onInverseSurface,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(10),
          child: Ink(
            padding: const EdgeInsets.fromLTRB(15, 15, 5, 5),
            child: content(),
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
            margin: const EdgeInsets.only(top: 2, bottom: 8, right: 10),
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
        if(widget.noticeItem.replyContentHtml != null)
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(right: 10, bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.1))),
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
                  onTap: () => Utils.routeProfile(widget.noticeItem!.memberId,
                      widget.noticeItem!.memberAvatar, herotag),
                  child: Hero(
                    tag: herotag,
                    child: CAvatar(
                      url: widget.noticeItem!.memberAvatar,
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
                        widget.noticeItem!.memberId,
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
            // IconButton(onPressed: () {}, icon: Icon(Icons.delete_outline, size: 18,))
            TextButton(
                onPressed: () {},
                child: Text(
                  '删除',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ))
          ],
        ),
      ],
    );
  }
}
