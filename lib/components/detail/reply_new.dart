import 'package:flutter/material.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_v2ex/components/detail/html_render.dart';

class ReplyNew extends StatefulWidget {
  final statusHeight;
  List? replyMemberList;
  final String topicId;

  ReplyNew({
    this.statusHeight,
    this.replyMemberList,
    required this.topicId,
    super.key,
  });

  @override
  State<ReplyNew> createState() => _ReplyNewState();
}

class _ReplyNewState extends State<ReplyNew> {
  final TextEditingController _replyContentController = TextEditingController();
  final GlobalKey _formKey = GlobalKey<FormState>();
  late String _replyContent = '';


  void onCleanInput() {
    SmartDialog.show(
      animationType: SmartAnimationType.centerFade_otherSlide,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('清空内容'),
          // content: Text(
          //   '确定不再显示@${widget.reply.userName}来自的这条回复？',
          // ),
          content: const Text('该操作将清空所输入的内容，请确认。'),
          actions: [
            TextButton(
                onPressed: (() => {SmartDialog.dismiss()}),
                child: const Text('手误了')),
            TextButton(
                onPressed: (() => {SmartDialog.dismiss()}),
                child: const Text('确认清空'))
          ],
        );
      },
    );
  }

  Future<dynamic> onSubmit() async {
    if ((_formKey.currentState as FormState).validate()) {
      //验证通过提交数据
      (_formKey.currentState as FormState).save();
      print(_replyContent);
      var res = await DioRequestWeb.onSubmitReplyTopic(widget.topicId, '', _replyContent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - widget.statusHeight,
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
                onPressed: () => Navigator.pop(context),
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
                tooltip: '清空内容',
                onPressed: onCleanInput,
                icon: const Icon(Icons.clear_all_rounded),
                style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(9),
                    backgroundColor: Theme.of(context).colorScheme.background),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (widget.replyMemberList!.isNotEmpty)
            if (widget.replyMemberList!.length > 1)
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: -1,
                      children: [
                        const Text(' 回复：'),
                        ...replyList(widget.replyMemberList)
                      ],
                    ),
                  ),
                ],
              ),
          if (widget.replyMemberList!.length == 1)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
              alignment: Alignment.topLeft,
              child: HtmlRender(
                htmlContent: widget.replyMemberList![0].contentRendered,
              ),
              // child: Text(widget.replyMemberList![0].content, style: Theme.of(context).textTheme.titleMedium,),
            ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.only(
                  top: 12,
                  right: 20,
                  left: 20,
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
              // child: TextField(
              //   minLines: 1,
              //   maxLines: null,
              //   decoration: const InputDecoration(
              //       hintText: "输入回复内容", border: InputBorder.none),
              //   style: Theme.of(context).textTheme.bodyLarge,
              // ),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: TextFormField(
                  controller: _replyContentController,
                  minLines: 1,
                  maxLines: null,
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
          Container(
            width: double.infinity,
            height: 60,
            clipBehavior: Clip.hardEdge,
            margin: const EdgeInsets.only(top: 10, bottom: 30),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.circular(30),
            ),
            child: ElevatedButton(
              onPressed: onSubmit,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.send),
                  SizedBox(width: 10),
                  Text('发送')
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> replyList(replyMemberList) {
    List<Widget> widgetList = [];
    for (var i in replyMemberList) {
      widgetList.add(
        TextButton(
          onPressed: () => {},
          child: Text(i),
        ),
      );
    }
    return widgetList;
  }
}
