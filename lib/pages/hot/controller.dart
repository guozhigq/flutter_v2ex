import 'package:flutter_v2ex/http/dio_network.dart';
import 'package:flutter_v2ex/models/network/item_topic.dart';
import 'package:flutter_v2ex/models/web/item_tab_topic.dart';
import 'package:flutter_v2ex/pages/t/controller.dart';
import 'package:get/get.dart';

class HotPageController extends GetxController {
  RxList<TabTopicItem> hotTopicList = <TabTopicItem>[].obs;

  Future<List<TopicItem>> queryHotTopic({type = 'init'}) async {
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
    final TopicController topicController = Get.find<TopicController>();
    hotTopicList.value = list;
    topicController.setTopic(list[0]);
    return res;
  }
}
