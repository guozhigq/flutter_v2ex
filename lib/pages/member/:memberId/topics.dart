import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_v2ex/components/common/skeleton.dart';
import 'package:flutter_v2ex/components/common/pull_refresh.dart';
import 'package:flutter_v2ex/components/member/topic_item.dart';
import 'package:flutter_v2ex/models/web/model_member_topic.dart';
import 'package:flutter_v2ex/models/web/item_member_topic.dart';
import 'package:flutter_v2ex/components/common/skeleton_topic_recent.dart';
import 'package:flutter_v2ex/http/user.dart';

class MemberTopicsPage extends StatefulWidget {
  const MemberTopicsPage({Key? key}) : super(key: key);

  @override
  State<MemberTopicsPage> createState() => _MemberTopicsPageState();
}

class _MemberTopicsPageState extends State<MemberTopicsPage> {
  String memberId = '';
  final ScrollController _controller = ScrollController();

  ModelMemberTopic topicListData = ModelMemberTopic();
  List<MemberTopicItem> topicList = [];
  int _currentPage = 0;
  int _totalPage = 1;
  bool showBackTopBtn = false;
  bool _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    memberId = Get.parameters['memberId'] ?? 'guozhigq';

    _controller.addListener(
      () {
        var screenHeight = MediaQuery.of(context).size.height;
        if (_controller.offset >= screenHeight && showBackTopBtn == false) {
          setState(() {
            showBackTopBtn = true;
          });
        } else if (_controller.offset < screenHeight && showBackTopBtn) {
          setState(() {
            showBackTopBtn = false;
          });
        }
      },
    );

    queryMemberTopic();
  }

  Future<ModelMemberTopic> queryMemberTopic() async {
    ModelMemberTopic res =
        await UserWebApi.queryMemberTopic(memberId, _currentPage + 1);
    if (!res.isShow) {
      setState(() {
        _isLoading = false;
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
      _isLoading = false;
      _currentPage += 1;
      _totalPage = int.parse(res.totalPage);
      topicListData = res;
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
        title: const Text('最近发布'),
        actions: [
          if(topicListData.topicCount > 0)
            Text('主题总数 ${topicListData.topicCount}', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(width: 12)
        ],
      ),
      body: Stack(
        children: [
          Scrollbar(
              controller: _controller,
              radius: const Radius.circular(10),
              child: _isLoading
                  ? showLoading()
                  : topicList.isNotEmpty
                      ? PullRefresh(
                          totalPage: _totalPage,
                          currentPage: _currentPage,
                          onChildLoad:
                              _totalPage > 1 && _currentPage <= _totalPage
                                  ? queryMemberTopic
                                  : null,
                          onChildRefresh: () {
                            setState(() {
                              _currentPage = 0;
                            });
                            queryMemberTopic();
                          },
                          child: content(),
                        )
                      : !topicListData.isShow
                          ? noShow()
                          : noData()),
          Positioned(
            right: 20,
            bottom: 20,
            child: AnimatedScale(
              scale: showBackTopBtn ? 1 : 0,
              curve: Curves.easeOut,
              duration: const Duration(milliseconds: 300),
              child: FloatingActionButton(
                heroTag: null,
                child: const Icon(Icons.vertical_align_top_rounded),
                onPressed: () {
                  _controller.animateTo(0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget content() {
    return CustomScrollView(
      controller: _controller,
      slivers: [
        SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
          return TopicItem(topicItem: topicList[index]);
        }, childCount: topicList.length))
      ],
    );
  }

  Widget showLoading() {
    int count = MediaQuery.of(context).size.height ~/ 90;
    var arr = List.filled(count, 1, growable: false);
    return Skeleton(
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: arr.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return const TopicItemSkeleton();
        },
      ),
    );
  }

  Widget noShow() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 180),
          Icon(
            Icons.lock_outline,
            size: 42,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 30),
          Text(
            '根据 $memberId 的设置，主题列表被隐藏',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget noData() {
    return Center(
      child: Text('没有数据', style: Theme.of(context).textTheme.titleMedium,),
    );
  }
}
