import 'package:flutter/material.dart';
import 'package:flutter_v2ex/components/common/avatar.dart';
import 'package:flutter_v2ex/utils/storage.dart';
import 'package:get/get.dart';

class ReplyMemberList extends StatefulWidget {
  List? replyList;

  ReplyMemberList({required this.replyList, Key? key}) : super(key: key);

  @override
  State<ReplyMemberList> createState() => _ReplyMemberListState();
}

class _ReplyMemberListState extends State<ReplyMemberList> {
  final statusBarHeight = GStorage().getStatusBarHeight();
  final ScrollController _listScrollController = ScrollController();

  // 滑动至顶部下拉关闭bottomSheet +2 降低灵敏度
  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification &&
        _listScrollController.offset + 2 <= _listScrollController.position.minScrollExtent &&
        notification.metrics.extentBefore == 0) {
      Get.back();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      height: MediaQuery.of(context).size.height - statusBarHeight - 40,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      // child: Column(
      //   children: [
      //     Container(
      //       padding: const EdgeInsets.only(top: 10, left: 20, right: 15),
      //       margin: const EdgeInsets.only(bottom: 5),
      //       child: sheetHead(),
      //     ),
      //     Expanded(
      //       child: ListView.builder(
      //         padding: EdgeInsets.zero,
      //         itemCount: widget.replyList!.length,
      //         itemBuilder: (BuildContext context, int index) {
      //           if (index == widget.replyList!.length) {
      //             return SizedBox(
      //                 height: MediaQuery.of(context).padding.bottom);
      //           } else {
      //             return memberItem(widget.replyList![index]);
      //           }
      //         },
      //       ),
      //     ),
      //   ],
      // ),
      child: Scaffold(
        appBar: AppBar(
          leading: null,
          automaticallyImplyLeading: false,
          toolbarHeight: 65.0,
          title: sheetHead(),
        ),
        body: NotificationListener<ScrollNotification>(
          onNotification: _handleScrollNotification,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            controller: _listScrollController,
            itemCount: widget.replyList!.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == widget.replyList!.length) {
                return SizedBox(height: MediaQuery.of(context).padding.bottom);
              } else {
                return memberItem(widget.replyList![index]);
              }
            },
          ),
      )
        ,
      ),
    );
  }

  Widget sheetHead() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text.rich(
          TextSpan(
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(letterSpacing: 1),
            children: [
              const TextSpan(text: '选择要'),
              TextSpan(
                text: '@',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.w900),
              ),
              const TextSpan(text: '的用户')
            ],
          ),
        ),
        IconButton(
          tooltip: '确认并收起',
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_downward_rounded),
          style: IconButton.styleFrom(
            padding: const EdgeInsets.all(9),
            // backgroundColor: Theme.of(context).colorScheme.background
          ),
        ),
      ],
    );
  }

  Widget memberItem(replyItem) {
    return ListTile(
      onTap: () {
        // 直接选中
        Navigator.pop(context, {'atMemberList': List.filled(1, replyItem)});
      },
      leading: CAvatar(url: replyItem.avatar, size: 38, quality: 'origin'),
      title: Text.rich(TextSpan(children: [
        TextSpan(text: '${replyItem.userName} '),
        TextSpan(
            text: ' ${replyItem.floorNumber}楼',
            style: Theme.of(context)
                .textTheme
                .labelSmall!
                .copyWith(color: Theme.of(context).colorScheme.outline))
      ])),
      subtitle: Text(replyItem.content,
          maxLines: 1, style: Theme.of(context).textTheme.labelMedium!),
      trailing: Transform.scale(
        scale: 0.8,
        child: Checkbox(
          value: replyItem.isChoose,
          onChanged: (bool? checkValue) {
            // 多选
            setState(() {
              replyItem.isChoose = checkValue;
            });
          },
        ),
      ),
    );
  }
}
