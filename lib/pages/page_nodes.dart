import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:flutter_v2ex/http/dio_network.dart';
import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter_v2ex/utils/storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_v2ex/models/web/model_node_fav.dart';

class NodesPage extends StatefulWidget {
  const NodesPage({super.key});

  @override
  State<NodesPage> createState() => _NodesPageState();
}

class _NodesPageState extends State<NodesPage> with TickerProviderStateMixin {
  List nodesList =
      GStorage().getNodes().isNotEmpty ? GStorage().getNodes() : [];
  late final Axis scrollDirection;
  late TabController tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (nodesList.isEmpty) {
      getNodes().then((res) {
        tabController =
            TabController(length: nodesList.toList().length, vsync: this);
      });
    } else {
      _isLoading = false;
      tabController =
          TabController(length: nodesList.toList().length, vsync: this);
      getAllNodes(nodesList);
    }
    if (GStorage().getLoginStatus()) {
      getFavNodes();
    }
  }

  Future getNodes() async {
    var res = await DioRequestWeb.getNodes();
    await getAllNodes(res);
  }

  Future getAllNodes(res) async {
    var result = await DioRequestNet.getAllNodes();

    for (var j in res) {
      for (var z in j['childs']) {
        await nodeInfo(z, result);
      }
    }
    setState(() {
      _isLoading = false;
      nodesList = res;
    });
    return result;
  }

  Future<Map> nodeInfo(nodeItem, result) async {
    for (var i in result) {
      String avatar = i.avatarLarge ?? i.avatar_normal ?? i.avatar_mini;
      if (i.name == nodeItem['nodeId']) {
        if (avatar != '/static/img/node_default_large.png' && avatar != '') {
          nodeItem['nodeCover'] = avatar;
        }
      }
    }
    return nodeItem;
  }

  Future getFavNodes() async {
    var res = await DioRequestWeb.getFavNodes();
    var list = [];
    if (res.isNotEmpty) {
      for (var i in res) {
        list.add({
          'nodeId': i.nodeId,
          'nodeName': i.nodeName,
          'nodeCover': i.nodeCover
        });
      }
    }
    setState(() {
      nodesList[0]['childs'] = list;
    });
  }

  allNodes(e) {
    List res = [];
    for (var i = 19; i < e.length; i++) {
      res.add(e[i]);
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: 550,
          padding: const EdgeInsets.fromLTRB(16, 25, 16, 16),
          child: GridView.count(
            padding: EdgeInsets.zero,
            // 禁止滚动
            physics: const NeverScrollableClampingScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 6,
            children: nodesChildList(res),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Text('节点'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.refresh_rounded)),
          const SizedBox(width: 12)
        ],
      ),
      body: _isLoading
          ? showLoading()
          : Row(
              children: <Widget>[
                Card(
                  elevation: 2,
                  clipBehavior: Clip.hardEdge,
                  child: ExtendedTabBar(
                    controller: tabController,
                    indicator: BoxDecoration(
                      color: Theme.of(context).appBarTheme.backgroundColor,
                      border: Border(
                          left: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 4.0,
                            style: BorderStyle.solid,
                          )),
                    ),
                    unselectedLabelColor: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withOpacity(0.8),
                    labelColor: Theme.of(context).colorScheme.primary,
                    scrollDirection: Axis.vertical,
                    labelStyle: Theme.of(context).textTheme.titleSmall,
                    tabs: nodesList.map((e) {
                      return ExtendedTab(
                        size: 75,
                        iconMargin: const EdgeInsets.only(bottom: 0),
                        text: e['name'],
                      );
                    }).toList(),
                  ),
                )
                ,
                // const SizedBox(width: 4),
                Expanded(
                    child: ExtendedTabBarView(
                      cacheExtent: 0,
                      controller: tabController,
                      scrollDirection: Axis.vertical,
                      children: nodesList.map((e) {
                        return e['childs'].length == 0
                            ? const Center(
                                child: Text('还没有收藏节点'),
                              )
                            : GridView.count(
                                padding: EdgeInsets.zero,
                                // 禁止滚动
                                physics: e.length < 5
                                    ? const NeverScrollableClampingScrollPhysics()
                                    : const ScrollPhysics(),
                                crossAxisCount: 3,
                                mainAxisSpacing: 6,
                                children: [
                                  ...nodesChildList(e['childs']),
                                  if (e['childs'].length > 19)
                                    IconButton(
                                        onPressed: () {
                                          allNodes(e['childs']);
                                        },
                                        icon: Icon(Icons.more_horiz,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary)),
                                ],
                              );
                      }).toList(),
                    ),
                )
              ],
            ),
    );
  }

  List<Widget> nodesChildList(child) {
    List<Widget>? list = [];
    for (var i = 0; i < child.length; i++) {
      var item = child[i];
      if (i <= 18) {
        list.add(
          InkWell(
            onTap: () {
              Get.toNamed('/go/${item['nodeId']}');
            },
            borderRadius: BorderRadius.circular(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                if (item['nodeCover'] != null && item['nodeCover'] != '') ...[
                  CachedNetworkImage(
                    imageUrl: item['nodeCover'],
                    width: 38,
                    height: 38,
                  )
                ] else ...[
                  Image.asset(
                    'assets/images/avatar.png',
                    width: 38,
                    height: 38,
                  )
                ],
                const SizedBox(height: 8),
                Text(item['nodeName'],
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium,
                    textAlign: TextAlign.center,
                    maxLines: 1),
                // const SizedBox(height: 2),
              ],
            ),
          ),
        );
      }
    }
    return list;
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
