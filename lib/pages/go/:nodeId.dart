import 'dart:async';

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

class _GoPageState extends State<GoPage>{
  late final ScrollController _controller = ScrollController();
  NodeListModel? topicListDetail;
  List topicList = [];
  int _currentPage = 0;
  int _totalPage = 1;
  bool showBackTopBtn = false;
  String nodeId = '';
  late StreamController<bool> titleStreamC; // appBar title

  @override
  void initState() {
    super.initState();
    setState(() {
      nodeId = Get.parameters['nodeId']!;
    });
    getTopics();
    print('go page');

    titleStreamC = StreamController<bool>();
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

        if (_controller.offset > 150) {
          titleStreamC.add(true);
        } else if (_controller.offset <= 150) {
          titleStreamC.add(false);
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
    bool res = await NodeWebApi.onFavNode(
        topicListDetail!.nodeId, topicListDetail!.isFavorite);
    if (res) {
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
      body: Stack(
        children: [
          Scrollbar(
            controller: _controller,
            radius: const Radius.circular(10),
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
        SliverAppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          expandedHeight: 210,
          collapsedHeight: 60,
          // leadingWidth: 30,
          iconTheme: IconThemeData(
            color: Theme.of(context)
        .colorScheme
        .onPrimary
          ),
          pinned: true,
          title: StreamBuilder(
            stream: titleStreamC.stream,
            initialData: false,
            builder: (context, AsyncSnapshot snapshot) {
              return AnimatedOpacity(
                opacity: snapshot.data ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child:
                Row(
                  children: [
                    CAvatar(url: topicListDetail!.nodeCover, size: 35),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(topicListDetail!.nodeName,
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimary)),
                        Text(
                          '   ${topicListDetail!.topicCount} 主题  ${topicListDetail!.favoriteCount} 收藏',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall!
                              .copyWith(color: Theme.of(context).colorScheme.onPrimary),
                        )
                      ],
                    )
                  ],
                ),
              );
            },
          ),

          actions: [
            IconButton(
              onPressed: () => favNode(),
              icon: const Icon(Icons.bookmark_add_outlined),
              selectedIcon: const Icon(
                Icons.bookmark_added
              ),
              isSelected: topicListDetail!.isFavorite,
            ),
            const SizedBox(width: 12)
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              padding: const EdgeInsets.only(top: 110, left: 30, right: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.network(
                        topicListDetail!.nodeCover,
                        height: 70,
                        width: 70,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topicListDetail!.nodeName,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '   ${topicListDetail!.topicCount} 主题  ${topicListDetail!.favoriteCount} 收藏',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(topicListDetail!.nodeIntro,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary),
                      maxLines: 2),
                ],
              ),
            ),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _MySliverPersistentHeaderDelegate(
            child: Container(
              width: double.infinity,
              height: 20,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Container(
                width: double.infinity,
                height: 20,
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    )),
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            return Padding(
              padding: const EdgeInsets.only(left: 12, right: 12),
              child: ListItem(topic: topicList[index]),
            );
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

class _MySliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double _minExtent = 20;
  final double _maxExtent = 20;
  final Widget child;

  _MySliverPersistentHeaderDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    //创建child子组件
    return child;
  }

  //SliverPersistentHeader最大高度
  @override
  double get maxExtent => _maxExtent;

  //SliverPersistentHeader最小高度
  @override
  double get minExtent => _minExtent;

  @override
  bool shouldRebuild(covariant _MySliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
