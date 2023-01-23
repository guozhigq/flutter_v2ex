import 'package:flutter/material.dart';
// import 'package:flutter_v2ex/components/go/go_list.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:flutter_v2ex/components/common/pull_refresh.dart';
import 'package:flutter_v2ex/models/web/model_node_list.dart';
import 'package:flutter_v2ex/components/go/list_item.dart';

// import 'package:flutter_v2ex/http/dio_web.dart';
// import 'package:flutter_v2ex/models/web/item_tab_topic.dart';

class GoPage extends StatefulWidget {
  GoPage({required this.nodeKey, super.key});
  String nodeKey;
  @override
  State<GoPage> createState() => _GoPageState();
}

class _GoPageState extends State<GoPage> {
  NodeListModel? topicListDetail;
  List topicList = [];
  int _currentPage = 0;
  int _totalPage = 1;

  @override
  void initState() {
    super.initState();
    getTopics();
  }

  void getTopics() async {
    var res = await DioRequestWeb.getTopicsByNodeKey(
        widget.nodeKey, _currentPage + 1);
    setState(() {
      if (_currentPage == 0) {
        topicList = res.topicList;
        _totalPage = res.totalPage;
      } else {
        topicList.addAll(res.topicList);
      }
      _currentPage += 1;
      topicListDetail = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: topicListDetail != null
          ? AppBar(
              centerTitle: false,
              title: Text(topicListDetail!.nodeName),
              titleSpacing: 0,
              actions: [
                IconButton(
                  onPressed: () => {},
                  icon: const Icon(Icons.star_outline),
                  selectedIcon: Icon(
                    Icons.star,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  isSelected: topicListDetail!.isFavorite,
                ),
                const SizedBox(width: 12)
              ],
            )
          : null,
      body: PullRefresh(
        onChildRefresh: () {},
        // 上拉
        onChildLoad:
            _totalPage > 1 && _currentPage < _totalPage ? getTopics : null,
        currentPage: _currentPage,
        totalPage: _totalPage,
        child: topicListDetail != null ? content() : showLoading(),
      ),
    );
  }

  Widget content() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: topicListDetail!.nodeIntro.isNotEmpty
              ? Container(
                  padding: const EdgeInsets.only(
                      top: 20, right: 20, bottom: 30, left: 20),
                  child: Text(topicListDetail!.nodeIntro),
                )
              : null,
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            return ListItem(topic: topicList[index]);
          }, childCount: topicList.length),
        ),
      ],
    );
  }

  Widget showLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(
            strokeWidth: 3,
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
