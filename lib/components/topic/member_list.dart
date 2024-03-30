import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_v2ex/components/common/avatar.dart';
import 'package:flutter_v2ex/utils/storage.dart';
import 'package:get/get.dart';

class ReplyMemberList extends StatefulWidget {
  final List? replyList;

  const ReplyMemberList({required this.replyList, Key? key}) : super(key: key);

  @override
  State<ReplyMemberList> createState() => _ReplyMemberListState();
}

class _ReplyMemberListState extends State<ReplyMemberList>
    with TickerProviderStateMixin {
  final statusBarHeight = GStorage().getStatusBarHeight();
  final ScrollController _listScrollController = ScrollController();
  int _currentIndex = 0;
  bool checkStatus = false; // 是否全选
  IconData iconData = Icons.done;
  String myUserName = '';
  // 滑动至顶部下拉关闭bottomSheet +2 降低灵敏度
  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification &&
        _listScrollController.offset + 2 <=
            _listScrollController.position.minScrollExtent &&
        notification.metrics.extentBefore == 0) {
      Get.back();
      return true;
    }
    return false;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myUserName = GStorage().getUserInfo().isNotEmpty
        ? GStorage().getUserInfo()['userName']
        : '';
    widget.replyList!.removeWhere((item) => item.userName == myUserName);
  }

  void _checkAll() {
    Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (_currentIndex >= widget.replyList!.length) {
        return;
      }

      /// TODO 频繁 setState
      setState(() {
        widget.replyList![_currentIndex].isChoose = !checkStatus;
        _currentIndex++;
        if (_currentIndex >= widget.replyList!.length) {
          checkStatus = !checkStatus;
          _currentIndex = 0;
          timer.cancel();
          Navigator.pop(
              context, {'atMemberList': widget.replyList, 'checkStatus': true});
        }
        iconData = !checkStatus ? Icons.done : Icons.done_all;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      height: MediaQuery.of(context).size.height - statusBarHeight - 85,
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
        ),
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
          tooltip: '全部选中',
          onPressed: () {
            _checkAll();
          },
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(iconData,
                key: ValueKey<IconData>(iconData),
                size: 28.0,
                color: Theme.of(context).colorScheme.primary),
          ),
          // icon: Icon(!checkStatus ? Icons.done : Icons.done_all, color: Theme.of(context).colorScheme.primary,),
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
