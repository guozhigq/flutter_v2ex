import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_v2ex/http/dio_network.dart';
import 'package:flutter_v2ex/http/dio_web.dart';

class TopicNodesPage extends StatefulWidget {
  const TopicNodesPage({Key? key}) : super(key: key);

  @override
  State<TopicNodesPage> createState() => _TopicNodesPageState();
}

class _TopicNodesPageState extends State<TopicNodesPage> {
  List topicNodesList = [];
  List searchResList = [];
  bool _isLoading = false;

  // 接收的参数
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
    getTopicNodes();
  }

  Future<List> getTopicNodes() async {
    setState(() {
      _isLoading = true;
    });
    var res = await DioRequestNet.getAllNodesT();
    setState(() {
      topicNodesList = res;
      _isLoading = false;
    });
    return res;
  }

  void search(searchKey) {
    if (searchKey == '') {
      setState(() {
        searchResList = [];
      });
      return;
    }
    List resultList = [];
    for (var i in topicNodesList) {
      if (i.name.contains(searchKey) || i.title.contains(searchKey)) {
        resultList.add(i);
      }
    }
    setState(() {
      searchResList = resultList;
    });
  }

  Future moveTopicNode(node) async {
    var res = await DioRequestWeb.moveTopicNode(topicId, node.name);
    if (res) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('提示'),
              content: Text('成功将主题移动到「${node.title}」节点'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('返回'))
              ],
            );
          },
        );
      }
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 130,
              title: Text(source == 'move' ? '移动节点' : '选择节点'),
              elevation: 1,
              pinned: true,
              floating: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Column(
                  children: [
                    const SizedBox(height: 120.0),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                          top: 0, right: 12, left: 12, bottom: 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          color: Theme.of(context).colorScheme.onInverseSurface,
                          padding: const EdgeInsets.only(
                              top: 0, right: 0, left: 20, bottom: 0),
                          child: Center(
                            child: TextField(
                              autofocus: true,
                              textInputAction: TextInputAction.search,
                              decoration: const InputDecoration.collapsed(
                                hintText: '搜索节点',
                              ),
                              onChanged: (String value) {
                                search(value);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
              return ListTile(
                  onTap: () {
                    if (source != '' && source == 'move') {
                      // 移动节点
                      moveTopicNode(searchResList[index]);
                    } else {
                      Get.back(result: {'node': searchResList[index]});
                    }
                  },
                  title: Text(
                    searchResList[index].title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(searchResList[index].name),
                  enableFeedback: true,
                  trailing: Text('主题数：${searchResList[index].topics}'));
            }, childCount: searchResList.length)),
          ],
        ),
        // AnimatedContainer(
        //   alignment: Alignment.bottomCenter,
        //   duration: const Duration(milliseconds: 300),
        //     child: Container(
        //       width: double.infinity,
        //       height: 500,
        //       color: Theme.of(context).colorScheme.background,
        //     ),
        // )
      ],
    ));
  }
}
