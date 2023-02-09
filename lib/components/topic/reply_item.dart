import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_v2ex/models/web/item_topic_reply.dart';
import 'package:flutter_v2ex/components/common/avatar.dart';
import 'package:flutter_v2ex/components/topic/html_render.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_v2ex/components/topic/reply_new.dart';
import 'dart:math';

class ReplyListItem extends StatefulWidget {
  const ReplyListItem({
    required this.reply,
    required this.topicId,
    this.queryReplyList,
    super.key,
  });

  final ReplyItem reply;
  final String topicId;
  final queryReplyList;

  @override
  State<ReplyListItem> createState() => _ReplyListItemState();
}

class _ReplyListItemState extends State<ReplyListItem> {
  // bool isChoose = false;
  List<Map<dynamic, dynamic>> sheetMenu = [
    {
      'id': 1,
      'title': '添加回复',
      'leading': const Icon(
        Icons.reply,
        size: 21,
      ),
    },
    {
      'id': 3,
      'title': '复制内容',
      'leading': const Icon(
        Icons.copy_rounded,
        size: 21,
      ),
    },
    {
      'id': 4,
      'title': '忽略回复',
      'leading': const Icon(
        Icons.not_interested_rounded,
        size: 21,
      ),
    },
    {
      'id': 5,
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
    if (widget.reply.replyMemberList.isNotEmpty) {
      setState(() {
        sheetMenu.insert(1, {
          'id': 2,
          'title': '查看回复',
          'leading': const Icon(Icons.messenger_outline_rounded, size: 21),
        });
      });
    }
  }

  void menuAction(index) {
    switch (index) {
      case 1:
        replyComment();
        break;
      case 2:
        widget.queryReplyList(widget.reply.replyMemberList,
            widget.reply.floorNumber, [widget.reply]);
        break;
      case 3:
        copyComment();
        break;
      case 4:
        ignoreComment();
        break;
      case 5:
        Get.toNamed('/member/${widget.reply.userName}', parameters: {
          'memberAvatar': widget.reply.avatar,
          'heroTag': widget.reply.userName + heroTag,
        });
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
                child: const Text('确定')),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      // decoration: BoxDecoration(
      //   border: Border(bottom: BorderSide(
      //     width: 1,
      //     color: Theme.of(context).dividerColor.withOpacity(0.1)
      //   ))
      // ),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        // color: Theme.of(context).colorScheme.onInverseSurface,
        child: InkWell(
          onTap: replyComment,
          borderRadius: BorderRadius.circular(10),
          child: Ink(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
            child: content(context),
          ),
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
      onTap: () => Get.toNamed('/member/${widget.reply.userName}', parameters: {
        'memberAvatar': widget.reply.avatar,
        'heroTag': widget.reply.userName + heroTag,
      }),
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
                    size: 34,
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
          child: Row(
            // 两端对齐
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  lfAvtar(),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.reply.userName,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Theme.of(context).textTheme.labelLarge,
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
                      const SizedBox(height: 1.5),
                      Row(
                        children: [
                          if (widget.reply.lastReplyTime.isNotEmpty) ...[
                            Text(
                              widget.reply.lastReplyTime,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            const SizedBox(width: 2),
                          ],
                          if (widget.reply.platform == 'Android') ...[
                            const Icon(
                              Icons.android,
                              size: 14,
                            ),
                          ],
                          if (widget.reply.platform == 'iPhone') ...[
                            const Icon(Icons.apple, size: 16),
                          ]
                        ],
                      )
                    ],
                  )
                ],
              ),
              Text(
                '#${widget.reply.floorNumber}',
                style: Theme.of(context).textTheme.titleSmall,
              )
            ],
          ),
        ),
        // title
        Container(
          margin: const EdgeInsets.only(top: 0, bottom: 5, left: 46, right: 0),
          child: HtmlRender(
            htmlContent: widget.reply.contentRendered,
            imgList: widget.reply.imgList,
          ),
        ),
        bottonAction()
      ],
    );
  }

  // 感谢、回复、复制
  Widget bottonAction() {
    var color = Theme.of(context).colorScheme.onBackground.withOpacity(0.8);
    var textStyle = Theme.of(context).textTheme.bodyMedium !.copyWith(
      color: Theme.of(context).colorScheme.onBackground,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const SizedBox(width: 32),
            TextButton(
              onPressed: thanksDialog,
              child: Row(children: [
                Icon(Icons.favorite_border, size: 17, color: color),
                const SizedBox(width: 2),
                widget.reply.favorites.isNotEmpty
                    ? Text(widget.reply.favorites,
                        style: textStyle)
                    : Text('感谢', style:textStyle),
              ]),
            ),
            TextButton(
              onPressed: replyComment,
              child: Row(children: [
                Icon(Icons.reply, size: 20, color: color.withOpacity(0.8)),
                const SizedBox(width: 2),
                Text('回复', style: textStyle),
              ]),
            ),
            if (widget.reply.replyMemberList.isNotEmpty)
              TextButton(
                onPressed: () => widget.queryReplyList(
                    widget.reply.replyMemberList,
                    widget.reply.floorNumber,
                    [widget.reply]),
                child: Text(
                  '查看回复',
                  style: textStyle,
                ),
              ),
          ],
        ),
        Row(
          children: [
            SizedBox(
              height: 28.0,
              width: 28.0,
              child: IconButton(
                padding: const EdgeInsets.all(2.0),
                icon: const Icon(Icons.more_horiz_outlined, size: 18.0),
                onPressed: showBottomSheet,
              ),
            ),
            SizedBox(width: 4)
          ],
        )
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
                menuAction(sheetMenu[index]['id']);
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

  void thanksDialog() {
    showDialog<String>(
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
    );
  }
}
