import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_v2ex/models/web/item_member_reply.dart';
import 'package:flutter_v2ex/components/topic/html_render.dart';

class ReplyItem extends StatelessWidget {
  final MemberReplyItem replyItem;

  const ReplyItem({required this.replyItem, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.only(top: 8, right: 12, bottom: 0, left: 12),
        child: Material(
          color: Theme.of(context).colorScheme.onInverseSurface,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: () => Get.toNamed('/t/${replyItem.topicId}'),
            borderRadius: BorderRadius.circular(10),
            child: Ink(
              padding: const EdgeInsets.fromLTRB(7, 15, 7, 0),
              child: content(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget content(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          margin: const EdgeInsets.only(top: 0, bottom: 4),
          child: HtmlRender(htmlContent: replyItem.replyContent),
        ),
        Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            margin: const EdgeInsets.only(top: 0, bottom: 8),
            child: Text(replyItem.time,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color: Theme.of(context).colorScheme.outline))),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          margin: const EdgeInsets.only(bottom: 7),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background.withOpacity(0.8),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    replyItem.memberId,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    replyItem.nodeName,
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium!
                        .copyWith(color: Theme.of(context).colorScheme.outline),
                  )
                ],
              ),
              Divider(
                color: Theme.of(context).dividerColor.withOpacity(0.2),
              ),
              Text(replyItem.topicTitle)
            ],
          ),
        ),
      ],
    );
  }
}
