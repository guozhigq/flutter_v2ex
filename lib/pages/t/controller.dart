import 'package:get/get.dart';
import 'package:flutter_v2ex/models/web/item_tab_topic.dart';

class TopicController extends GetxController {
  RxString topicId = ''.obs;
  Rx<TabTopicItem> topic = TabTopicItem().obs;

  void setTopic(value) {
    topic.value = value;
    topicId.value = value.topicId;
  }
}
