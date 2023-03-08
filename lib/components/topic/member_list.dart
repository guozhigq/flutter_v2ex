import 'package:flutter/material.dart';
import 'package:flutter_v2ex/components/common/avatar.dart';
import 'package:flutter_v2ex/utils/storage.dart';

class ReplyMemberList extends StatefulWidget {
  List? replyList;

  ReplyMemberList({required this.replyList, Key? key}) : super(key: key);

  @override
  State<ReplyMemberList> createState() => _ReplyMemberListState();
}

class _ReplyMemberListState extends State<ReplyMemberList> {
  final statusBarHeight = GStorage().getStatusBarHeight();

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height - statusBarHeight - 10,
        padding: const EdgeInsets.only(top: 5),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 40,
              padding: const EdgeInsets.only(bottom: 2),
              child: Center(
                child: Container(
                  width: 38,
                  height: 2,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(3),
                      ),
                      color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: widget.replyList!.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return memberItem(widget.replyList![index]);
                },
              ),
            ),
          ],
        ));
  }

  Widget memberItem(replyItem) {
    return ListTile(
      onTap: () {
        // 直接选中
        Navigator.pop(context, {
          'atMemberList': List.filled(1, replyItem)
        });
      },
      leading: CAvatar(url: replyItem.avatar, size: 42, quality: 'origin'),
      title: Text.rich(TextSpan(children: [
        TextSpan(
          text: '${replyItem.userName} ',
        ),
        TextSpan(
            text: ' #${replyItem.floorNumber}',
            style: Theme.of(context)
                .textTheme
                .labelSmall!
                .copyWith(color: Theme.of(context).colorScheme.outline))
      ])),
      subtitle: Text(replyItem.content,
          maxLines: 1, style: Theme.of(context).textTheme.labelMedium!),
      trailing: Transform.scale(
        scale: 1.1,
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
