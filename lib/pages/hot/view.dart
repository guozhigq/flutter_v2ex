import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter_v2ex/components/adaptive/resize_layout.dart';
import 'package:flutter_v2ex/components/common/footer.dart';
import 'package:flutter_v2ex/components/common/network_error.dart';
import 'package:flutter_v2ex/components/common/skeleton_topic.dart';
import 'package:flutter_v2ex/components/home/list_item.dart';
import 'package:flutter_v2ex/service/i18n_keyword.dart';
import 'package:flutter_v2ex/utils/global.dart';
import 'package:get/get.dart';
import 'controller.dart';

class HotPage extends StatefulWidget {
  const HotPage({super.key});
  @override
  State<HotPage> createState() => _HotPageState();
}

class _HotPageState extends State<HotPage> {
  final _hot = Get.put(HotPageController());
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _hot.queryHotTopic();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wide = Breakpoints.mediumAndUp.isActive(context);
    return Scaffold(
      backgroundColor: getBackground(context, 'homePage'),
      appBar: wide
          ? null
          : AppBar(
              title: Text(I18nKeyword.todayHot.tr),
              actions: [
                TextButton(
                    onPressed: () => Get.toNamed('/historyHot'),
                    child: const Text('历史'))
              ],
            ),
      body: ResizeLayout(leftLayout: Obx(() {
        if (_hot.loading.value && _hot.hotTopicList.isEmpty) {
          return const TopicSkeleton();
        }
        if (_hot.error.value != null && _hot.hotTopicList.isEmpty) {
          return NetworkErrorPage(onRetry: () => _hot.queryHotTopic());
        }
        return RefreshIndicator(
          onRefresh: () => _hot.queryHotTopic(userRefresh: true),
          child: ListView.builder(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(12, 8, wide ? 0 : 12, 0),
            itemCount: _hot.hotTopicList.length + 1,
            itemBuilder: (context, index) {
              if (index == _hot.hotTopicList.length) {
                return const FooterTips();
              }
              final topic = _hot.hotTopicList[index];
              return ListItem(key: ValueKey(topic.topicId), topic: topic);
            },
          ),
        );
      })),
    );
  }
}
