// 主页tab下的item
class TabTopicItem {
  /// unread 未读
  /// read 已读
  String readStatus = 'unread';
  String memberId = '';
  String topicId = '';
  String avatar = '';
  String topicContent = '';
  String replyCount = '';
  String nodeId = '';
  String nodeName = '';
  String lastReplyMId = '';
  String lastReplyTime = '';

  TabTopicItem();

  get name => null;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['readStatus'] = readStatus;
    map['memberId'] = memberId;
    map['topicId'] = topicId;
    map['avatar'] = avatar;
    map['topicContent'] = topicContent;
    map['replyCount'] = replyCount;
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
    topicContent = map['topicContent'];
    replyCount = map['replyCount'];
    nodeId = map['nodeId'];
    nodeName = map['nodeName'];
    lastReplyMId = map['lastReplyMId'];
    lastReplyTime = map['lastReplyTime'];
  }
}
