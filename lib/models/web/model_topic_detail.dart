import 'package:flutter_v2ex/models/web/item_topic_reply.dart';
import 'package:flutter_v2ex/models/web/item_topic_subtle.dart';

/// 帖子详情（含评论）数据

class TopicDetailModel {
  String topicId = ''; // 帖子id
  String nodeId = ''; // 节点id
  String nodeName = ''; // 节点名称
  String topicTitle = ''; // 标题
  String createdId = ''; // 创建人
  String avatar = '';
  String replyCount = '0';
  // String smallGray = ''; // 6 小时 21 分钟前 · 3366 次点击
  String createdTime = '';
  String visitorCount = '';

  String content = ''; // 纯文本内容
  String contentRendered = ''; // 带html标签内容
  late List<TopicSubtleItem> subtleList; // 附言
  bool isAuth = false; // 是否需要登录  默认不需要

  String token = ''; // 用于操作：对主题收藏
  // <a href="#;" onclick="if (confirm('确定不想再看到这个主题？')) { location.href = '/ignore/topic/583319?once=62479'; }"
  // class="op" style="user-select: auto;">忽略主题</a>
  // String once = ''; // 用于操作：对忽略主题、给主题发送感谢、对评论发送感谢
  bool isFavorite = false; // 是否已收藏
  int favoriteCount = 0; // 收藏的人数
  bool isThank = false; // 是否已感谢

  int totalPage = 1; // 共有多少页数评论

  late List<ReplyItem> replyList;
}
