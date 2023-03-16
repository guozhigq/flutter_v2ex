import 'package:hive/hive.dart';
import 'package:flutter_v2ex/models/web/item_topic_reply.dart';
import 'package:flutter_v2ex/models/web/item_topic_subtle.dart';

part 'model_topic_detail.g.dart';
/// 帖子详情（含评论）数据

@HiveType(typeId: 1)
class TopicDetailModel {
  @HiveField(0)
  String topicId = ''; // 帖子id
  @HiveField(1)
  String nodeId = ''; // 节点id
  @HiveField(2)
  String nodeName = ''; // 节点名称
  @HiveField(3)
  String topicTitle = ''; // 标题
  @HiveField(4)
  String createdId = ''; // 创建人
  @HiveField(5)
  String avatar = '';
  @HiveField(6)
  String replyCount = '0';
  @HiveField(7)
  // String smallGray = ''; // 6 小时 21 分钟前 · 3366 次点击
  String createdTime = ''; // 创建时间
  @HiveField(8)
  String visitorCount = ''; // 点击数
  @HiveField(9)
  String content = ''; // 纯文本内容
  @HiveField(10)
  String contentRendered = ''; // 带html标签内容
  @HiveField(11)
  late List<TopicSubtleItem> subtleList = []; // 附言
  @HiveField(12)
  int imgCount = 0; // 正文&附言image数量
  @HiveField(13)
  List imgList = []; // 正文&附言image
  @HiveField(14)
  bool isAuth = false; // 是否需要登录  默认不需要
  @HiveField(15)
  String token = ''; // 用于操作：对主题收藏
  // <a href="#;" onclick="if (confirm('确定不想再看到这个主题？')) { location.href = '/ignore/topic/583319?once=62479'; }"
  // class="op" style="user-select: auto;">忽略主题</a>
  // String once = ''; // 用于操作：对忽略主题、给主题发送感谢、对评论发送感谢
  @HiveField(16)
  bool isFavorite = false; // 是否已收藏
  @HiveField(17)
  int favoriteCount = 0; // 收藏的人数
  @HiveField(18)
  bool isThank = false; // 是否已感谢

  // op
  @HiveField(19)
  bool isAPPEND = false; // 默认不可增加附言
  @HiveField(20)
  bool isEDIT = false; // 默认不可编辑主题
  @HiveField(21)
  bool isMOVE = false; // 默认不可移动节点
  @HiveField(22)
  int totalPage = 1; // 共有多少页数评论
  @HiveField(23)
  late List<ReplyItem> replyList;
}
