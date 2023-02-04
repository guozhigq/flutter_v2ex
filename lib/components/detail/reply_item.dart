import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_v2ex/models/web/item_topic_reply.dart';
import 'package:flutter_v2ex/components/common/avatar.dart';
import 'package:flutter_v2ex/components/detail/html_render.dart';
import 'package:flutter_v2ex/pages/profile_page.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_v2ex/components/detail/reply_new.dart';
import 'package:flutter_v2ex/utils/utils.dart';
import 'dart:math';

class ReplyListItem extends StatefulWidget {
  const ReplyListItem({
    required this.reply,
    required this.topicId,
    super.key,
  });

  final ReplyItem reply;
  final String topicId;

  @override
  State<ReplyListItem> createState() => _ReplyListItemState();
}

class _ReplyListItemState extends State<ReplyListItem> {
  // bool isChoose = false;
  List<Map<dynamic, dynamic>> sheetMenu = [
    {
      'title': '添加回复',
      'leading': const Icon(
        Icons.reply,
        size: 21,
      ),
    },
    {
      'title': '复制内容',
      'leading': const Icon(
        Icons.copy_rounded,
        size: 21,
      ),
    },
    {
      'title': '忽略回复',
      'leading': const Icon(
        Icons.not_interested_rounded,
        size: 21,
      ),
    },
    {
      'title': '查看主页',
      'leading': const Icon(Icons.person, size: 21),
    }
  ];
  String heroTag = Random().nextInt(999).toString();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var isOwner = widget.reply.isOwner;
    if (isOwner) {
      setState(() {
        sheetMenu.removeAt(2);
      });
    }
  }

  void menuAction(index) {
    switch (index) {
      case 0:
        replyComment();
        break;
      case 1:
        copyComment();
        break;
      case 2:
        ignoreComment();
        break;
      case 3:
        Utils.routeProfile(widget.reply.userName, widget.reply.avatar,
            widget.reply.userName + heroTag);
        break;
    }
  }

  // 回复评论
  void replyComment() {
    var statusHeight = MediaQuery.of(context).padding.top;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return ReplyNew(
          statusHeight: statusHeight,
          replyMemberList: [widget.reply],
          topicId: widget.topicId,
        );
      },
    );
  }

  // 复制评论
  void copyComment() {
    Clipboard.setData(ClipboardData(text: widget.reply.content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.done, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 4),
            const Text('复制成功')
          ],
        ),
        showCloseIcon: true,
      ),
    );
  }

  // 忽略回复
  void ignoreComment() {
    SmartDialog.show(
      animationType: SmartAnimationType.centerFade_otherSlide,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('忽略回复'),
          content: Row(
            children: [
              const Text('确定不再显示来自 '),
              Text(
                '@${widget.reply.userName}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Text(' 的这条回复？'),
            ],
          ),
          actions: [
            TextButton(
                onPressed: (() => {SmartDialog.dismiss()}),
                child: const Text('取消')),
            TextButton(
                onPressed: (() => {SmartDialog.dismiss()}),
                child: const Text('确定'))
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
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
                  onTap: replyComment,
                  borderRadius: BorderRadius.circular(16),
                  child: Ink(
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
      onLongPress: () {
        setState(() {
          widget.reply.isChoose = !widget.reply.isChoose;
        });
      },
      onTap: () => Utils.routeProfile(widget.reply.userName,
          widget.reply.avatar, widget.reply.userName + heroTag),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(18))),
            child: Stack(
              children: [
                Hero(
                  tag: widget.reply.userName + heroTag,
                  child: CAvatar(
                    url: widget.reply.avatar,
                    size: 36,
                  ),
                ),
                // if (widget.reply.isChoose)
                Positioned(
                  top: 0,
                  left: 0,
                  child: AnimatedOpacity(
                    opacity: widget.reply.isChoose ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 100),
                    child: Container(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.8),
                      width: 36,
                      height: 36,
                      child: Icon(Icons.done,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
              ],
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
                      maxWidth: 200, // 最大宽度
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
              Text('#${widget.reply.floorNumber}'),
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
            // SizedBox(
            //   height: 28.0,
            //   width: 28.0,
            //   child: IconButton(
            //     padding: const EdgeInsets.all(2.0),
            //     // color: themeData.primaryColor,
            //     icon: const Icon(Icons.copy_rounded, size: 18.0),
            //     onPressed: () {
            //       Clipboard.setData(ClipboardData(text: widget.reply.content));
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         const SnackBar(
            //           content: Text('复制成功'),
            //           showCloseIcon: true,
            //         ),
            //       );
            //     },
            //   ),
            // ),
            const SizedBox(width: 1),
            SizedBox(
              height: 28.0,
              width: 28.0,
              child: IconButton(
                padding: const EdgeInsets.all(2.0),
                // color: themeData.primaryColor,
                icon: const Icon(Icons.more_horiz_outlined, size: 18.0),
                onPressed: showBottomSheet,
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

  void showBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return ListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          //重要
          itemCount: sheetMenu.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              onTap: () {
                Navigator.pop(context);
                menuAction(index);
              },
              minLeadingWidth: 0,
              iconColor: Theme.of(context).colorScheme.onSurface,
              leading: sheetMenu[index]['leading'],
              title: Text(
                sheetMenu[index]['title'],
                style: Theme.of(context).textTheme.titleSmall,
              ),
            );
          },
        );
      },
    );
  }
}
