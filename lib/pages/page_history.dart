import 'package:flutter/material.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:flutter_v2ex/components/home/list_item.dart';
import 'package:flutter_v2ex/models/web/item_tab_topic.dart';
import 'package:flutter_v2ex/components/common/pull_refresh.dart';
import 'package:flutter_v2ex/components/common/skeleton_topic.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool _isLoading = true;
  List<TabTopicItem> topicList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getHistoryTopic();
  }

  Future<List<TabTopicItem>> getHistoryTopic() async {
    var res = await DioRequestWeb.getTopicsRecent(1);
    setState(() {
      topicList = res;
      _isLoading = false;
    });
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('最近浏览'),
      ),
      body: _isLoading
          ? const TopicSkeleton()
          : Container(
              padding: const EdgeInsets.only(left: 12, right: 12),
              child: topicList.isEmpty
                  ? noData()
                  : CustomScrollView(
                      slivers: [
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 8),
                        ),
                        SliverList(
                          delegate:
                              SliverChildBuilderDelegate((context, index) {
                            return ListItem(topic: topicList[index]);
                          }, childCount: topicList.length),
                        ),
                        SliverToBoxAdapter(
                          child: SizedBox(
                              height:
                                  MediaQuery.of(context).padding.bottom + 15),
                        ),
                      ],
                    ),
            ),
    );
  }

  Widget noData() {
    return const Center(
      child: Text('没有数据'),
    );
  }
}
