import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_v2ex/models/web/item_topic_reply.dart';
import 'package:flutter_v2ex/components/common/avatar.dart';
import 'package:flutter_v2ex/components/detail/html_render.dart';

class ReplyListItem extends StatefulWidget {
  const ReplyListItem({required this.reply, super.key});
  final ReplyItem reply;
  @override
  State<ReplyListItem> createState() => _ReplyListItemState();
}

class _ReplyListItemState extends State<ReplyListItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        color: Colors.transparent,
        margin: const EdgeInsets.only(top: 0, right: 16, bottom: 8, left: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            lfAvtar(),
            const SizedBox(width: 8),
            Expanded(
              child: Material(
                color: Theme.of(context).colorScheme.onInverseSurface,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.only(
                        top: 10, right: 14, bottom: 6, left: 10),
                    child: content(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget lfAvtar() {
    return GestureDetector(
      // onLongPress: () => {print('长按')},
      onTap: () => showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('提示'),
          content: const Text('确认向该用户表示感谢吗？，将花费10个铜板💰'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('手误了'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('确定'),
            ),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 5),
            child: CAvatar(
              url: widget.reply.avatar,
              size: 36,
            ),
          ),
          // IconButton(onPressed: () => {}, icon: const Icon(Icons.celebration))
        ],
      ),
    );
  }

  Widget content(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // 头像、昵称
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.only(top: 3, bottom: 3),
          child: Row(
            // 两端对齐
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(width: 6),
                  Container(
                    constraints: const BoxConstraints(
                      maxWidth: 100, // 最大宽度
                    ),
                    child: Text(
                      widget.reply.userName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (widget.reply.isOwner) ...[
                    Icon(
                      Icons.person,
                      size: 15,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  ]
                ],
              ),
              Text('#${widget.reply.floorNumber}')
            ],
          ),
        ),
        // title
        Divider(
          indent: 8,
          endIndent: 2,
          height: 1,
          color: Theme.of(context).dividerColor.withOpacity(0.15),
        ),
        Container(
          // alignment: Alignment.centerLeft,
          margin: const EdgeInsets.only(top: 8, bottom: 5, left: 4, right: 4),
          child: HtmlRender(htmlContent: widget.reply.contentRendered),
        ),
        const SizedBox(height: 10),
        bottonAction()
      ],
    );
  }

  // 感谢、回复、复制
  Widget bottonAction() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            const SizedBox(width: 2),
            SizedBox(
              height: 28.0,
              width: 28.0,
              child: IconButton(
                padding: const EdgeInsets.all(2.0),
                // color: themeData.primaryColor,
                icon: const Icon(Icons.favorite_outline, size: 18.0),
                selectedIcon: const Icon(Icons.favorite, size: 18.0),
                onPressed: () => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('提示'),
                    content: const Text('确认向该用户表示感谢吗？，将花费10个铜板💰'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'Cancel'),
                        child: const Text('手滑了'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'OK'),
                        child: const Text('确定👌'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 2),
            SizedBox(
              height: 28.0,
              width: 28.0,
              child: IconButton(
                padding: const EdgeInsets.all(2.0),
                // color: themeData.primaryColor,
                icon: const Icon(Icons.chat_bubble_outline, size: 18.0),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 2),
            SizedBox(
              height: 28.0,
              width: 28.0,
              child: IconButton(
                padding: const EdgeInsets.all(2.0),
                // color: themeData.primaryColor,
                icon: const Icon(Icons.copy_rounded, size: 18.0),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.reply.content));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('复制成功'),
                      showCloseIcon: true,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 1),
            SizedBox(
              height: 28.0,
              width: 28.0,
              child: IconButton(
                padding: const EdgeInsets.all(2.0),
                // color: themeData.primaryColor,
                icon: const Icon(Icons.more_horiz_outlined, size: 18.0),
                onPressed: () {},
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.reply.lastReplyTime.isNotEmpty) ...[
              Text(
                widget.reply.lastReplyTime,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              // const SizedBox(width: 2)
            ],
            if (widget.reply.platform == 'Android') ...[
              const Icon(
                Icons.android,
                size: 16,
                color: Color.fromRGBO(45, 223, 133, 100),
              ),
            ],
            if (widget.reply.platform == 'iPhone') ...[
              const Icon(Icons.apple, size: 16),
            ]
          ],
        ),
      ],
    );
  }
}
