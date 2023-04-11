import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_v2ex/components/adaptive/resize_layout.dart';
import 'package:flutter_v2ex/components/common/avatar.dart';
import 'package:flutter_v2ex/pages/t/controller.dart';
import 'package:flutter_v2ex/utils/global.dart';
import 'package:get/get.dart';
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
  final TopicController _topicController = Get.put(TopicController());
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
        _topicController.setTopic(res.topicList[0]);
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
      backgroundColor: getBackground(context, 'homePage'),
      body: ResizeLayout(
        leftLayout: Stack(
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
      ),
    );
  }

  Widget content() {
    return CustomScrollView(
      controller: _controller,
      slivers: [
        SliverAppBar(
    automaticallyImplyLeading: Breakpoints.mediumAndUp.isActive(context) ? false : true,
          backgroundColor: Get.isDarkMode
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.primary,
          expandedHeight: 280 - MediaQuery.of(context).padding.top,
          iconTheme: IconThemeData(
              color: Get.isDarkMode
                  ? Colors.white
                  : Theme.of(context).colorScheme.onPrimary),
          pinned: true,
          title: StreamBuilder(
            stream: titleStreamC.stream,
            initialData: false,
            builder: (context, AsyncSnapshot snapshot) {
              return AnimatedOpacity(
                opacity: snapshot.data ? 1 : 0,
                curve: Curves.easeOut,
                duration: const Duration(milliseconds: 500),
                child: Row(
                  children: [
                    CAvatar(url: topicListDetail!.nodeCover, size: 35),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(topicListDetail!.nodeName,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                    color: Get.isDarkMode
                                        ? Colors.white
                                        : Theme.of(context)
                                            .colorScheme
                                            .onPrimary)),
                        Text(
                          '   ${topicListDetail!.topicCount} 主题  ${topicListDetail!.favoriteCount} 收藏',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall!
                              .copyWith(
                                  color: Get.isDarkMode
                                      ? Colors.white
                                      : Theme.of(context)
                                          .colorScheme
                                          .onPrimary),
                        )
                      ],
                    )
                  ],
                ),
              );
            },
          ),
          actions: [
            // IconButton(
            //   onPressed: () => favNode(),
            //   icon: const Icon(Icons.bookmark_add_outlined),
            //   selectedIcon: const Icon(Icons.bookmark_added),
            //   isSelected: topicListDetail!.isFavorite,
            // ),
            // IconButton(
            //   onPressed: () => favNode(),
            //   icon: const Icon(Icons.search_rounded),
            // ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert),
            ),
            const SizedBox(width: 4)
          ],
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(25),
              child: Container(
                height: 20,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
              )),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              children: [
                topicListDetail!.nodeCover != ''
                    ? Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(
                                  topicListDetail!.nodeCover,
                                ),
                                fit: BoxFit.fitWidth)),
                      )
                    : const Spacer(),
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), //可以看源码
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 112, left: 24, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CachedNetworkImage(
                            imageUrl: topicListDetail!.nodeCover,
                            height: 62,
                            width: 62,
                            fit: BoxFit.cover,
                            // fadeOutDuration: const Duration(milliseconds: 800),
                            // fadeInDuration: const Duration(milliseconds: 300),
                            errorWidget: (context, url, error) =>
                                const Center(child: Text('加载失败')),
                            placeholder: (context, url) =>
                                const Center(child: Text('加载中')),
                          ),
                          const SizedBox(width: 6),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                topicListDetail!.nodeName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(color: Colors.white),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '   ${topicListDetail!.topicCount} 主题  ${topicListDetail!.favoriteCount} 收藏',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                          const Spacer(),
                          ElevatedButton(
                              onPressed: () => favNode(),
                              child: Text(
                                  topicListDetail!.isFavorite ? '已收藏' : '收藏'))
                        ],
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Text(
                            topicListDetail!.nodeIntro != ''
                                ? topicListDetail!.nodeIntro
                                : '还没有节点描述 😊',
                            style: const TextStyle(color: Colors.white),
                            maxLines: 2),
                      ),
                    ],
                  ),
                ),
              ],
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
