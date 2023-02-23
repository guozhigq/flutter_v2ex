import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:flutter_v2ex/models/network/item_node_topic.dart';

enum SampleItem { draft, cancel, tips }

class WritePage extends StatefulWidget {
  const WritePage({Key? key}) : super(key: key);

  @override
  State<WritePage> createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final GlobalKey _formKey = GlobalKey<FormState>();

  final FocusNode titleTextFieldNode = FocusNode();
  final FocusNode contentTextFieldNode = FocusNode();

  String title = '';
  String content = '';
  String syntax = 'default'; // 语法 default markdown
  TopicNodeItem? currentNode;

  // 接收到的参数
  String source = '';
  String topicId = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Get.parameters.isNotEmpty) {
      source = Get.parameters['source']!;
      topicId = Get.parameters['topicId']!;
    }
    if (source == 'edit') {
      // 查询编辑状态及内容
      queryTopicStatus();
    }
  }

  // 是否可编辑
  void queryTopicStatus() async {
    SmartDialog.showLoading();
    var res = await DioRequestWeb.queryTopicStatus(topicId);
    print(res);
    SmartDialog.dismiss();
    if (res['status']) {

    } else {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('提示'),
              content: const Text('内容不可编辑'),
              actions: [
                TextButton(
                    onPressed: () {
                      // 关闭 dialog
                      Navigator.pop(context);
                      // 关闭 page
                      Navigator.pop(context);
                    },
                    child: const Text('返回'))
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(source == 'edit' ? '编辑主题内容' : '创作新主题'),
        actions: [
          IconButton(
              onPressed: () async {
                if (currentNode == null) {
                  SmartDialog.showToast('请选择节点', alignment: Alignment.center);
                  return;
                }
                if ((_formKey.currentState as FormState).validate()) {
                  //验证通过提交数据
                  (_formKey.currentState as FormState).save();
                  // 键盘收起
                  contentTextFieldNode.unfocus();
                  var args = {
                    'title': title,
                    'syntax': syntax,
                    'content': content,
                    'node_name': currentNode!.name,
                    'content': content
                  };
                  var result = await DioRequestWeb.postTopic(args);
                  if (result) {
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('发布成功'),
                            content: const Text('主题发布成功，是否前往查看'),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('返回上一页')),
                              TextButton(
                                  onPressed: () {

                                  },
                                  child: const Text('去查看'))
                            ],
                          );
                        },
                      );
                    }
                  }
                }
              },
              icon: const Icon(Icons.send),
              tooltip: '发布'),
          PopupMenuButton<SampleItem>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'action',
            itemBuilder: (BuildContext context) =>
            <PopupMenuEntry<SampleItem>>[
              PopupMenuItem<SampleItem>(
                value: SampleItem.draft,
                onTap: () {},
                child: const Text('保存草稿'),
              ),
              PopupMenuItem<SampleItem>(
                value: SampleItem.cancel,
                onTap: () {},
                child: const Text('舍弃'),
              ),
              PopupMenuItem<SampleItem>(
                value: SampleItem.tips,
                onTap: () {},
                child: const Text('发帖提示'),
              ),
            ],
          ),
        ],
      ),
      body: Form(
        key: _formKey, //设置globalKey，用于后面获取FormState
        autovalidateMode: AutovalidateMode.disabled,
        child: Column(
          children: [
            if(source == '') ... [
              InkWell(
                onTap: () async {
                  var result = await Get.toNamed('/topicNodes');
                  setState(() {
                    currentNode = result['node'];
                  });
                },
                child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: Theme
                                    .of(context)
                                    .dividerColor
                                    .withOpacity(0.2)))),
                    child: Row(
                      children: [
                        Text(
                          '主题节点:',
                          style: Theme
                              .of(context)
                              .textTheme
                              .titleMedium,
                        ),
                        const SizedBox(width: 20),
                        Text(
                          currentNode != null ? currentNode!.title! : '选择节点',
                          style: Theme
                              .of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                              color: Theme
                                  .of(context)
                                  .colorScheme
                                  .primary),
                        ),
                      ],
                    )),
              ),
            ],
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 5),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: Theme
                              .of(context)
                              .dividerColor
                              .withOpacity(0.2)))),
              child: TextFormField(
                autofocus: true,
                controller: titleController,
                focusNode: titleTextFieldNode,
                decoration: const InputDecoration(
                  hintText: "主题标题",
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                // 校验用户名
                validator: (v) {
                  return v!.trim().isNotEmpty ? null : "请输入主题标题";
                },
                onSaved: (val) {
                  title = val!;
                },
              ),
            ),
            Expanded(
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                child: TextFormField(
                  controller: contentController,
                  minLines: 1,
                  maxLines: null,
                  decoration: const InputDecoration(
                      hintText: "输入正文内容", border: InputBorder.none),
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyLarge,
                  validator: (v) {
                    return v!.trim().isNotEmpty ? null : "请输入正文内容";
                  },
                  onSaved: (val) {
                    content = val!;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
