import 'package:flutter/material.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:flutter_v2ex/components/mine/topic_item.dart';
import 'package:flutter_v2ex/models/web/model_member_topic.dart';
import 'package:flutter_v2ex/models/web/item_member_topic.dart';
import 'package:flutter_v2ex/components/common/pull_refresh.dart';

class TopicList extends StatefulWidget {
  String memberId = '';

  TopicList({required this.memberId, Key? key}) : super(key: key);

  @override
  State<TopicList> createState() => _TopicListState();
}

class _TopicListState extends State<TopicList>
    with AutomaticKeepAliveClientMixin {
  ModelMemberTopic topicListData = ModelMemberTopic();
  List<MemberTopicItem> topicList = [];
  int _currentPage = 0;
  int _totalPage = 1;
  bool _loading = true;

  @override
  bool wantKeepAlive = true;

  @override
  void initState() {
    super.initState();
    queryMemberTopic();
  }

  Future<ModelMemberTopic> queryMemberTopic() async {
    var res =
        await DioRequestWeb.queryMemberTopic(widget.memberId, _currentPage + 1);
    if (!res.isShow) {
      setState(() {
        _loading = false;
        topicListData = res;
      });
      return res;
    }
    setState(() {
      if (_currentPage == 0) {
        topicList = res.topicList;
      } else {
        topicList.addAll(res.topicList);
      }
      _currentPage += 1;
      _loading = false;
      _totalPage = int.parse(res.totalPage);
      topicListData = res;
    });
    return res;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _loading
        ? loading()
        : topicList.isNotEmpty
            ? PullRefresh(
                currentPage: _currentPage,
                totalPage: _totalPage,
                onChildRefresh: () {
                  setState(() {
                    _currentPage = 0;
                  });
                  queryMemberTopic();
                },
                onChildLoad: _totalPage > 1 && _currentPage <= _totalPage
                    ? queryMemberTopic
                    : null,
                child: content(),
              )
            : !topicListData.isShow
                ? noShow()
                : noData();
  }

  Widget content() {
    return CustomScrollView(
      slivers: [
        SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
          return TopicItem(topicItem: topicList[index]);
        }, childCount: topicList.length))
      ],
    );
  }

  Widget loading() {
    return const Center(child: Text('加载中'));
  }

  Widget noShow() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 130),
          Icon(
            Icons.lock_outline,
            size: 42,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 30),
          Text(
            '根据 ${widget.memberId} 的设置，主题列表被隐藏',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget noData() {
    return const Text('没有数据');
  }
}
