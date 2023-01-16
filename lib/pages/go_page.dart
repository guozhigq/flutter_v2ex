import 'package:flutter/material.dart';
import 'package:flutter_v2ex/components/go/go_list.dart';
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
  int page = 1;

  @override
  void initState() {
    super.initState();
    getTopics();
  }

  void getTopics() async {
    var res = await DioRequestWeb.getTopicsByNodeKey(widget.nodeKey, page);
    setState(() {
      topicListDetail = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PullRefresh(
        onChildRefresh: () {},
        // 上拉
        onChildLoad: () {},
        currentPage: 0,
        totalPage: 0,
        child: topicListDetail != null ? content() : showLoading(),
      ),
    );
  }

  Widget content() {
    return CustomScrollView(
      slivers: [
        // SliverAppBar(
        //   expandedHeight: 120,
        //   actions: [
        //     IconButton(
        //         onPressed: () => {}, icon: const Icon(Icons.star_outline)),
        //     const SizedBox(width: 12)
        //   ],
        //   pinned: true,
        //   flexibleSpace: FlexibleSpaceBar(
        //       title: Text(
        //         '全部节点',
        //         style: Theme.of(context).textTheme.titleMedium,
        //       ),
        //       centerTitle: false,
        //       titlePadding:
        //           const EdgeInsetsDirectional.only(start: 36, bottom: 16),
        //       expandedTitleScale: 1.5),
        // ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            return ListItem(topic: topicListDetail!.topicList[index]);
          }, childCount: topicListDetail!.topicList.length),
        ),

        // SliverToBoxAdapter(
        //   child: Container(
        //     clipBehavior: Clip.antiAlias,
        //     margin: const EdgeInsets.only(right: 12, top: 8, left: 12),
        //     decoration: const BoxDecoration(
        //       borderRadius: BorderRadius.only(
        //         topLeft: Radius.circular(10),
        //         topRight: Radius.circular(10),
        //       ),
        //     ),
        //     child: ListView.builder(
        //       shrinkWrap: true,
        //       padding: const EdgeInsets.only(top: 1, bottom: 0),
        //       // physics: const ClampingScrollPhysics(), //重要
        //       itemCount: topicListDetail!.topicList.length,
        //       itemBuilder: (BuildContext context, int index) {
        //         return ListItem(topic: topicListDetail!.topicList[index]);
        //       },
        //     ),
        //   ),
        // )
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
