import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:flutter_v2ex/components/home/list_item.dart';
import 'package:flutter_v2ex/models/web/item_tab_topic.dart';
import 'package:flutter_v2ex/components/common/pull_refresh.dart';
import 'package:flutter_v2ex/models/web/model_topic_fav.dart';

class MyTopicsPage extends StatefulWidget {
  const MyTopicsPage({Key? key}) : super(key: key);

  @override
  State<MyTopicsPage> createState() => _MyTopicsPageState();
}

class _MyTopicsPageState extends State<MyTopicsPage> {
  final ScrollController _controller = ScrollController();
  List<TabTopicItem> topicList = [];
  int _currentPage = 0;
  int _totalPage = 1;
  bool showBackTopBtn = false;
  bool _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

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
    getTopics();
  }

  Future<FavTopicModel> getTopics() async {
    FavTopicModel res = await DioRequestWeb.getFavTopics(_currentPage + 1);
    setState(() {
      if (_currentPage == 0) {
        topicList = res.topicList;
      } else {
        topicList.addAll(res.topicList);
      }
      _isLoading = false;
      _currentPage += 1;
      _totalPage = res.totalPage;
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
        title: Text('收藏的主题'),
      ),
      body: Stack(
        children: [
          Scrollbar(
            controller: _controller,
            radius: const Radius.circular(10),
            child: Container(
              margin: const EdgeInsets.only(right: 12, left: 12),
              child: _isLoading
                  ? showLoading()
                  : topicList.isNotEmpty
                      ? PullRefresh(
                          totalPage: _totalPage,
                          currentPage: _currentPage,
                          onChildLoad:
                              _totalPage > 1 && _currentPage <= _totalPage
                                  ? getTopics
                                  : null,
                          onChildRefresh: () {
                            setState(() {
                              _currentPage = 0;
                            });
                            getTopics();
                          },
                          child: content(),
                        )
                      : const Text('没有数据'),
            ),
          ),
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
          return ListItem(topic: topicList[index]);
        }, childCount: topicList.length))
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
