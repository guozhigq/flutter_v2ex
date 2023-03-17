import 'package:hive/hive.dart';

part 'item_tab_topic.g.dart';

// 主页tab下的item
@HiveType(typeId: 0)
class TabTopicItem extends HiveObject {
  /// unread 未读
  /// read 已读
  @HiveField(0)
  String readStatus = 'unread';

  @HiveField(1)
  String memberId = ''; // 发布人id

  @HiveField(2)
  String topicId = ''; // 话题id

  @HiveField(3)
  String avatar = ''; // 头像

  @HiveField(4)
  String topicTitle = ''; // 话题标题

  @HiveField(5)
  int replyCount = 0; // 回复数

  @HiveField(6)
  String clickCount = ''; // 点击数

  @HiveField(7)
  String nodeId = ''; // 节点id

  @HiveField(8)
  String nodeName = ''; // 节点名称

  @HiveField(9)
  String lastReplyMId = ''; // 最后回复人id

  @HiveField(10)
  String lastReplyTime = ''; // 最后回复时间

// TabTopicItem();

// get name => null;

// Map<String, dynamic> toMap() {
//   final map = <String, dynamic>{};
//   map['readStatus'] = readStatus;
//   map['memberId'] = memberId;
//   map['topicId'] = topicId;
//   map['avatar'] = avatar;
//   map['topicTitle'] = topicTitle;
//   map['replyCount'] = replyCount;
//   map['clickCount'] = clickCount;
//   map['nodeId'] = nodeId;
//   map['nodeName'] = nodeName;
//   map['lastReplyMId'] = lastReplyMId;
//   map['lastReplyTime'] = lastReplyTime;
//   return map;
// }

// TabTopicItem.fromMap(Map<String, dynamic> map) {
//   readStatus = map['readStatus'];
//   memberId = map['memberId'];
//   topicId = map['topicId'];
//   avatar = map['avatar'];
//   topicTitle = map['topicTitle'];
//   replyCount = map['replyCount'];
//   clickCount = map['clickCount'];
//   nodeId = map['nodeId'];
//   nodeName = map['nodeName'];
//   lastReplyMId = map['lastReplyMId'];
//   lastReplyTime = map['lastReplyTime'];
// }
}
