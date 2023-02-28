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
    print('source: $source');
    if (source == 'edit') {
      // 查询编辑状态及内容
      queryTopicStatus();
    }
    if (source == 'append') {
      // 查询附言状态
      queryAppendStatus();
    }
  }

  // 是否可编辑
  void queryTopicStatus() async {
    var res = await DioRequestWeb.queryTopicStatus(topicId);
    if (res['status']) {
      // 可以编辑，渲染内容
      Map topicDetail = res['topicDetail'];
      String topicTitle = topicDetail['topicTitle'];
      String topicContent = topicDetail['topicContent'];
      String syntax = topicDetail['syntax'];
      titleController.text = topicTitle;
      contentController.text = topicContent;
      setState(() {
        syntax = syntax;
      });
    } else {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('提示'),
              content: const Text('你不能编辑这个主题。'),
              actions: [
                TextButton(
                    onPressed: () {
                      // 关闭 dialog
                      Navigator.pop(context);
                      // 关闭 page
                      Navigator.pop(context, {'refresh': true});
                    },
                    child: const Text('返回'))
              ],
            );
          },
        );
      }
    }
  }

  // 是否可以增加附言
  void queryAppendStatus() async {
    var res = await DioRequestWeb.appendStatus(topicId);
    if(!res) {
      if(context.mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('提示'),
              content: const Text('不可为该主题增加附言'),
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

  void appendDialog() {
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: const Text('关于为主题创建附言'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const[
            Text('- 请在确有必要的情况下再使用此功能为原主题补充信息'),
            Text('- 每个主题至多可以附加 3 条附言'),
            Text('- 创建附言价格为每千字 20 铜币'),
            // Text('- 每个主题至多可以附加 3 条附言'),
            // Text('- 创建附言价格为每千字 20 铜币'),
          ],
        ),
        actions: [
          TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('了解了'))
        ],
      );
    });
  }

  void onSubmit() {
    switch (source) {
      case '':
        onPost();
        break;
      case 'edit':
        onEdit();
        break;
      case 'append':
        onAppend();
        break;
      default:
        onPost();
    }
  }

  Future onPost() async{
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
  }

  // 编辑主题
  Future onEdit() async{
    if ((_formKey.currentState as FormState).validate()) {
      //验证通过提交数据
      (_formKey.currentState as FormState).save();
      // 键盘收起
      contentTextFieldNode.unfocus();
      var args = {
        'title': title,
        'syntax': syntax == 'default' ? 0 : 1,
        'content': content,
        'topicId': topicId
      };
      var result = await DioRequestWeb.eidtTopic(args);
      if (result) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('编辑成功'),
                content: const Text('主题编辑成功，是否前往查看'),
                actions: [
                  TextButton(
                      onPressed: () {
                        // 返回主题详情页并刷新
                        Navigator.pop(context, {'refresh', true});
                      },
                      child: const Text('去查看'))
                ],
              );
            },
          );
        }
      }else{
        SmartDialog.show(
          useSystem: true,
          animationType: SmartAnimationType.centerFade_otherSlide,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('提示'),
              content: const Text('你不能编辑这个主题。'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('确定'))
              ],
            );
          },
        );
      }
    }
  }

  // 添加附言
  Future onAppend() async{
    if ((_formKey.currentState as FormState).validate()) {
      //验证通过提交数据
      (_formKey.currentState as FormState).save();
      // 键盘收起
      contentTextFieldNode.unfocus();
      var args = {
        'syntax': syntax == 'default' ? 0 : 1,
        'content': content,
        'topicId': topicId
      };
      var result = await DioRequestWeb.appendContent(args);
      if (result) {
        if (context.mounted) {
          SmartDialog.showToast('发布成功', displayTime: const Duration(milliseconds: 800)).then((value) {
            Get.back(result: {'refresh': true});
          });
        }
      }else{

      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(source == 'edit' ? '编辑主题内容' : source == 'append' ? '增加附言' : '创作新主题'),
        actions: [
          IconButton(
              onPressed: () => onSubmit(),
              icon: const Icon(Icons.send),
              tooltip: '发布'),
          if(source == 'append')
            IconButton(
                onPressed: ()=> appendDialog(), icon: const Icon(Icons.info_outline_rounded)),
            const SizedBox(width: 10),
          if(source != 'append')
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
            if(source != 'append')
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
                  decoration: InputDecoration(
                      hintText: source == 'append' ? '输入附言内容' : '输入正文内容', border: InputBorder.none),
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
