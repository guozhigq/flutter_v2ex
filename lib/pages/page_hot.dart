import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter_v2ex/components/adaptive/resize_layout.dart';
import 'package:flutter_v2ex/components/common/footer.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_v2ex/http/dio_network.dart';
import 'package:flutter_v2ex/service/i18n_keyword.dart';
import 'package:flutter_v2ex/models/network/item_topic.dart';
import 'package:flutter_v2ex/components/home/list_item.dart';
import 'package:flutter_v2ex/models/web/item_tab_topic.dart';
import 'package:flutter_v2ex/components/common/pull_refresh.dart';
import 'package:flutter_v2ex/components/common/skeleton_topic.dart';
import 'package:get/get.dart';

class HotPage extends StatefulWidget {
  const HotPage({Key? key}) : super(key: key);

  @override
  State<HotPage> createState() => _HotPageState();
}

class _HotPageState extends State<HotPage> {
  final ScrollController _controller = ScrollController();
  bool _isLoading = true;
  List<TabTopicItem> hotTopicList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    queryHotTopic();
  }

  Future<List<TopicItem>> queryHotTopic() async {
    var res = await DioRequestNet.getHotTopic();
    List<TabTopicItem> list = [];
    for (var i in res) {
      TabTopicItem item = TabTopicItem();
      item.memberId = i.memberId!;
      item.topicId = i.topicId!;
      item.avatar = i.avatar!;
      item.topicTitle = i.topicTitle!;
      item.replyCount = i.replyCount!;
      item.clickCount = i.clickCount!;
      item.nodeId = i.nodeId!;
      item.nodeName = i.nodeName!;
      item.lastReplyMId = i.lastReplyMId!;
      item.lastReplyTime = i.lastReplyTime!;
      list.add(item);
    }
    setState(() {
      hotTopicList = list;
      _isLoading = false;
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
      appBar: Breakpoints.mediumAndUp.isActive(context) ? null :  AppBar(
        title: Text(I18nKeyword.todayHot.tr),
        actions: [
          TextButton(
              onPressed: () => Get.toNamed('/historyHot'),
              child: const Text('历史')),
        ],
      ),
      body: ResizeLayout(
        leftLayout: Scrollbar(
          radius: const Radius.circular(10),
          controller: _controller,
          child: _isLoading
              ? const TopicSkeleton()
              : hotTopicList.isNotEmpty
                  ? Container(
                      clipBehavior: Clip.antiAlias,
                      margin:
                          const EdgeInsets.only(right: 12, top: 8, left: 12),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      child: RefreshIndicator(
                        onRefresh: () {
                          return queryHotTopic();
                        },
                        // desktop ListView scrollBar
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context)
                              .copyWith(scrollbars: false),
                          child: ListView.builder(
                            padding: const EdgeInsets.only(top: 1, bottom: 0),
                            physics: const AlwaysScrollableScrollPhysics(
                                // parent: BouncingScrollPhysics(), // iOS
                                parent: ClampingScrollPhysics() // Android
                                ),
                            //重要
                            itemCount: hotTopicList.length + 1,
                            controller: _controller,
                            itemBuilder: (BuildContext context, int index) {
                              if (index == hotTopicList.length) {
                                return const FooterTips();
                              } else {
                                return ListItem(topic: hotTopicList[index]);
                                ;
                              }
                            },
                          ),
                        ),
                      ),
                    )
                  : const Text('没有数据'),
        ),
      ),
    );
  }
}
