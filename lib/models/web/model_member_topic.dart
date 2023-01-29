import 'package:flutter_v2ex/models/web/item_member_topic.dart';

class ModelMemberTopic {
  String totalPage = '1';
  bool isShow = true; // 是否设置隐私
  bool isEmpty = false; // 主题列表为空
  late List<MemberTopicItem> topicList;
}
