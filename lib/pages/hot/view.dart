import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter_v2ex/components/adaptive/resize_layout.dart';
import 'package:flutter_v2ex/components/common/footer.dart';
import 'package:flutter_v2ex/utils/global.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_v2ex/service/i18n_keyword.dart';
import 'package:flutter_v2ex/components/home/list_item.dart';
import 'package:flutter_v2ex/models/web/item_tab_topic.dart';
import 'package:flutter_v2ex/components/common/skeleton_topic.dart';

import 'controller.dart';

class HotPage extends StatefulWidget {
  const HotPage({Key? key}) : super(key: key);

  @override
  State<HotPage> createState() => _HotPageState();
}

class _HotPageState extends State<HotPage> {
  final HotPageController _hotPageController = Get.put(HotPageController());
  final ScrollController _controller = ScrollController();
  late Future _futureBuilderFuture;

  @override
  void initState() {
    super.initState();
    _futureBuilderFuture = _hotPageController.queryHotTopic();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMediumAndUp = Breakpoints.mediumAndUp.isActive(context);
    return Scaffold(
      backgroundColor: getBackground(context, 'homePage'),
      appBar: isMediumAndUp
          ? null
          : AppBar(
              title: Text(I18nKeyword.todayHot.tr),
              actions: [
                TextButton(
                  onPressed: () => Get.toNamed('/historyHot'),
                  child: const Text('历史'),
                ),
              ],
            ),
      body: ResizeLayout(
        leftLayout: Scrollbar(
          radius: const Radius.circular(10),
          controller: _controller,
          child: RefreshIndicator(
            onRefresh: () async {
              await _hotPageController.queryHotTopic();
            },
            child: FutureBuilder(
              future: _futureBuilderFuture,
              builder: ((BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  List<TabTopicItem> hotTopicList =
                      _hotPageController.hotTopicList;
                  return Obx(
                    () => hotTopicList.isNotEmpty
                        ? Container(
                            clipBehavior: Clip.antiAlias,
                            margin: EdgeInsets.only(
                                right: isMediumAndUp ? 0 : 12,
                                top: 8,
                                left: 12),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                            child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context)
                                  .copyWith(scrollbars: false),
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.only(top: 1, bottom: 0),
                                physics: const AlwaysScrollableScrollPhysics(
                                    parent: ClampingScrollPhysics()),
                                itemCount: hotTopicList.length + 1,
                                controller: _controller,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == hotTopicList.length) {
                                    return const FooterTips();
                                  } else {
                                    return ListItem(topic: hotTopicList[index]);
                                  }
                                },
                              ),
                            ),
                          )
                        : const Text('没有数据'),
                  );
                } else {
                  return const TopicSkeleton();
                }
              }),
            ),
          ),
        ),
      ),
    );
  }
}
