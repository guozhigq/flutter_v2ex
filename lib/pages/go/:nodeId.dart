import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_v2ex/components/common/avatar.dart';
import 'package:get/get.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:flutter_v2ex/components/common/pull_refresh.dart';
import 'package:flutter_v2ex/models/web/model_node_list.dart';
import 'package:flutter_v2ex/components/home/list_item.dart';
import 'package:flutter_v2ex/http/node.dart';

class GoPage extends StatefulWidget {
  const GoPage({super.key});

  @override
  State<GoPage> createState() => _GoPageState();
}

class _GoPageState extends State<GoPage> {
  late final ScrollController _controller = ScrollController();
  NodeListModel? topicListDetail;
  List topicList = [];
  int _currentPage = 0;
  int _totalPage = 1;
  bool showBackTopBtn = false;
  String nodeId = '';

  @override
  void initState() {
    super.initState();
    setState(() {
      nodeId = Get.parameters['nodeId']!;
    });
    getTopics();
    print('go page');
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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void getTopics() async {
    var res = await NodeWebApi.getTopicsByNodeId(nodeId, _currentPage + 1);
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

  Future<bool> favNode() async {
    bool res = await NodeWebApi.onFavNode(topicListDetail!.nodeId, topicListDetail!.isFavorite);
    if(res) {
      SmartDialog.showToast(topicListDetail!.isFavorite ? '取消收藏成功' : '收藏成功');
      setState(() {
        topicListDetail!.isFavorite = !topicListDetail!.isFavorite;
      });
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: topicListDetail != null
            ? AppBar(
                centerTitle: false,
                // title: Text(topicListDetail!.nodeName),
          title: Row(
            children: [
              CAvatar(url: topicListDetail!.nodeCover, size: 35),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(topicListDetail!.nodeName, style: Theme.of(context).textTheme.titleMedium),
                  Text('   ${topicListDetail!.topicCount} 主题  ${topicListDetail!.favoriteCount} 收藏', style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Theme.of(context).colorScheme.outline),)
                ],
              )
            ],
          ),
                titleSpacing: 0,
                actions: [
                  IconButton(
                    onPressed: () => favNode(),
                    icon: const Icon(Icons.bookmark_add_outlined),
                    selectedIcon: Icon(
                      Icons.bookmark_add_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    isSelected: topicListDetail!.isFavorite,
                  ),
                  const SizedBox(width: 12)
                ],
              )
            : null,
        body: Stack(
          children: [
            Scrollbar(
              controller: _controller,
              radius: const Radius.circular(10),
              child: Container(
                margin: const EdgeInsets.only(right: 12, left: 12),
                child: PullRefresh(
                  onChildRefresh: () {
                    setState(() {
                      _currentPage = 0;
                    });
                    getTopics();
                  },
                  // 上拉
                  onChildLoad: _totalPage > 1 && _currentPage < _totalPage
                      ? getTopics
                      : null,
                  currentPage: _currentPage,
                  totalPage: _totalPage,
                  child: topicListDetail != null ? content() : showLoading(),
                ),
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
        ));
  }

  Widget content() {
    return CustomScrollView(
      controller: _controller,
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
