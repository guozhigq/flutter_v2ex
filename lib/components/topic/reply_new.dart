import 'package:flutter_v2ex/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_v2ex/components/topic/html_render.dart';

class ReplyNew extends StatefulWidget {
  List? replyMemberList;
  final String topicId;
  int? totalPage;

  ReplyNew({
    this.replyMemberList,
    required this.topicId,
    this.totalPage,
    super.key,
  });

  @override
  State<ReplyNew> createState() => _ReplyNewState();
}

class _ReplyNewState extends State<ReplyNew> {
  final TextEditingController _replyContentController = TextEditingController();
  final GlobalKey _formKey = GlobalKey<FormState>();
  late String _replyContent = '';
  final statusBarHeight = GStorage().getStatusBarHeight();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<dynamic> onSubmit() async {
    if ((_formKey.currentState as FormState).validate()) {
      //验证通过提交数据
      (_formKey.currentState as FormState).save();

      String replyUser = '';
      if (widget.replyMemberList!.isNotEmpty) {
        for (var i in widget.replyMemberList as List) {
          replyUser += '@${i.userName} #${i.floorNumber}  ';
        }
      }

      var res = await DioRequestWeb.onSubmitReplyTopic(
          widget.topicId, replyUser + _replyContent, widget.totalPage!);
      if (res) {
        if (context.mounted) {
          Navigator.pop(context, {'replyStatus': 'success'});
        }
      } else {
        if (context.mounted) {
          Navigator.pop(context, {'replyStatus': 'fail'});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - statusBarHeight - 10,
      padding: const EdgeInsets.only(top: 25, left: 12, right: 12),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                tooltip: '关闭弹框',
                onPressed: () {
                  Map res = {'replyStatus': 'cancel'};
                  Navigator.pop(context, res);
                },
                icon: const Icon(Icons.close),
                style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(9),
                    backgroundColor: Theme.of(context).colorScheme.background),
              ),
              Text(
                widget.replyMemberList!.isEmpty
                    ? '回复楼主'
                    : widget.replyMemberList!.length == 1
                        ? '回复@${widget.replyMemberList![0].userName}'
                        : '回复',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                tooltip: '发送',
                onPressed: onSubmit,
                icon: const Icon(Icons.send_outlined),
                style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(9),
                    backgroundColor: Theme.of(context).colorScheme.background),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (widget.replyMemberList!.isNotEmpty)
            if (widget.replyMemberList!.length > 1)
              Container(
                padding: const EdgeInsets.only(left: 12, bottom: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        runSpacing: 2,
                        spacing: 10,
                        children: [
                          Text(
                            ' 回复：',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          ...replyList(widget.replyMemberList)
                        ],
                      ),
                    ),
                  ],
                ),
              )
              ,
          if (widget.replyMemberList!.length == 1)
            Container(
              padding: const EdgeInsets.only(
                  top: 0, right: 10, bottom: 20, left: 10),
              alignment: Alignment.topLeft,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 196),
                child: HtmlRender(
                  htmlContent: widget.replyMemberList![0].contentRendered,
                ),
              ),
              // child: Text(widget.replyMemberList![0].content, maxLines: 5),
            ),
          Expanded(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.only(
                  top: 12,
                  right: 15,
                  left: 15,
                  bottom: MediaQuery.of(context).padding.bottom + 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: TextFormField(
                  controller: _replyContentController,
                  minLines: 1,
                  maxLines: null,
                  autofocus: true,
                  decoration: const InputDecoration(
                      hintText: "输入回复内容", border: InputBorder.none),
                  style: Theme.of(context).textTheme.bodyLarge,
                  validator: (v) {
                    return v!.trim().isNotEmpty ? null : "请输入回复内容";
                  },
                  onSaved: (val) {
                    _replyContent = val!;
                  },
                ),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).padding.bottom,
          )
        ],
      ),
    );
  }

  List<Widget> replyList(replyMemberList) {
    List<Widget> widgetList = [];
    for (var i in replyMemberList) {
      widgetList.add(
          // TextButton(
          //   onPressed: () => {},
          //   child: Text(i.userName),
          // ),
          FilledButton.tonal(onPressed: () => {}, child: Text(i.userName)));
    }
    return widgetList;
  }
}
