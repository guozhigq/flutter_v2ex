// 主页tab下的item
class TabTopicItem {
  /// unread 未读
  /// read 已读
  String readStatus = 'unread';
  String memberId = ''; // 发布人id
  String topicId = ''; // 话题id
  String avatar = ''; // 头像
  String topicTitle = ''; // 话题标题
  String replyCount = '0'; // 回复数
  String clickCount = ''; // 点击数
  String nodeId = ''; // 节点id
  String nodeName = ''; // 节点名称
  String lastReplyMId = ''; // 最后回复人id
  String lastReplyTime = ''; // 最后回复时间

  TabTopicItem();

  get name => null;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['readStatus'] = readStatus;
    map['memberId'] = memberId;
    map['topicId'] = topicId;
    map['avatar'] = avatar;
    map['topicTitle'] = topicTitle;
    map['replyCount'] = replyCount;
    map['clickCount'] = clickCount;
    map['nodeId'] = nodeId;
    map['nodeName'] = nodeName;
    map['lastReplyMId'] = lastReplyMId;
    map['lastReplyTime'] = lastReplyTime;
    return map;
  }

  TabTopicItem.fromMap(Map<String, dynamic> map) {
    readStatus = map['readStatus'];
    memberId = map['memberId'];
    topicId = map['topicId'];
    avatar = map['avatar'];
    topicTitle = map['topicTitle'];
    replyCount = map['replyCount'];
    clickCount = map['clickCount'];
    nodeId = map['nodeId'];
    nodeName = map['nodeName'];
    lastReplyMId = map['lastReplyMId'];
    lastReplyTime = map['lastReplyTime'];
  }
}
