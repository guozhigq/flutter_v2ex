import 'package:flutter_v2ex/http/dio_network.dart';
import 'package:flutter_v2ex/service/content_cache.dart';
import 'package:flutter_v2ex/service/page_request.dart';
import 'package:flutter_v2ex/models/web/item_tab_topic.dart';
import 'package:flutter_v2ex/pages/t/controller.dart';
import 'package:get/get.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class HotPageController extends GetxController {
  RxList<TabTopicItem> hotTopicList = <TabTopicItem>[].obs;

  final loading = true.obs;
  final error = RxnString();
  final _requests = PageRequest();

  Future<void> queryHotTopic({bool userRefresh = false}) {
    final showRefreshToast = userRefresh && hotTopicList.isNotEmpty;
    final account = ContentCache.scope;
    return _requests.run((generation) async {
      bool active() =>
          _requests.accepts(generation) && ContentCache.scope == account;
      if (!active()) return;
      loading.value = true;
      error.value = null;
      try {
        var res = await DioRequestNet.getHotTopic(silent: true);
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
        if (!active()) return;
        final TopicController topicController = Get.find<TopicController>();
        hotTopicList.value = list;
        if (list.isNotEmpty) topicController.setTopic(list.first);
      } catch (_) {
        if (!active()) return;
        if (hotTopicList.isEmpty) error.value = '更新失败';
        if (showRefreshToast) SmartDialog.showToast('刷新失败，已保留当前内容');
      } finally {
        if (active()) loading.value = false;
      }
    }, refresh: userRefresh);
  }

  @override
  void onClose() {
    _requests.invalidate();
    super.onClose();
  }
}
