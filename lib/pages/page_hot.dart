import 'package:flutter/material.dart';
import 'package:flutter_v2ex/http/dio_network.dart';
import 'package:flutter_v2ex/models/network/item_topic.dart';
import 'package:flutter_v2ex/components/home/list_item.dart';
import 'package:flutter_v2ex/models/web/item_tab_topic.dart';
import 'package:flutter_v2ex/components/common/pull_refresh.dart';
import 'package:flutter_v2ex/components/common/skeleton_topic.dart';


class HotPage extends StatefulWidget {
  const HotPage({Key? key}) : super(key: key);

  @override
  State<HotPage> createState() => _HotPageState();
}

class _HotPageState extends State<HotPage> {
  final ScrollController _controller = ScrollController();
  bool _isLoading = true;
  List<TabTopicItem> hotTopicList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    queryHotTopic();
  }


  Future<List<TopicItem>> queryHotTopic() async {
    var res = await DioRequestNet.getHotTopic();
    List <TabTopicItem> list = [];
    for(var i in res) {
      TabTopicItem item = TabTopicItem();
      item.memberId = i.memberId!;
      item.topicId = i.topicId!;
      item.avatar = i.avatar!;
      item.topicTitle = i.topicTitle!;
      item.replyCount = i.replyCount!;
      item.clickCount = i.clickCount!;
      item.nodeId = i.nodeId!;
      item.nodeName = i.nodeName!;
      item.lastReplyMId = i.lastReplyMId!;
      item.lastReplyTime = i.lastReplyTime!;
      list.add(item);
    }
    setState(() {
      hotTopicList = list;
      _isLoading = false;
    });
    return res;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('今日热议'),
      ),
      body: Scrollbar(
        controller: _controller,
        radius: const Radius.circular(10),
          child: _isLoading
              ? const TopicSkeleton()
              : hotTopicList.isNotEmpty
              ? PullRefresh(
            currentPage: 1,
            totalPage: 1,
            onChildLoad: queryHotTopic,
            onChildRefresh: () {
              queryHotTopic();
            },
            child: content(),
          )
              : const Text('没有数据')
      )
    );
  }

  Widget content() {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 12),
      child: CustomScrollView(
        controller: _controller,
        slivers: [
          SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return
                  ListItem(topic: hotTopicList[index]);
              }, childCount: hotTopicList.length))
        ],
      ),
    );
  }
}
