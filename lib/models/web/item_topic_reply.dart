// 帖子详情页下的评论item
import 'package:hive/hive.dart';
part 'item_topic_reply.g.dart';

@HiveType(typeId: 2)
class ReplyItem {
  @HiveField(0)
  bool isOwner = false; // 是否op主
  @HiveField(1)
  String avatar = '';
  @HiveField(2)
  String userName = '';
  @HiveField(3)
  String lastReplyTime = '';
  @HiveField(4)
  String content = ''; // 纯文本
  @HiveField(5)
  String contentRendered = ''; // 带html标签
  @HiveField(6)
  String replyId = '';
  @HiveField(7)
  int favorites = 0; // 感谢数量
  @HiveField(8)
  bool favoritesStatus = false; // 感谢状态 登录状态
  @HiveField(9)
  String number = ''; // 楼层
  @HiveField(10)
  int floorNumber = 0; // 楼层
  @HiveField(11)
  String platform = ''; // 平台 Android ios
  @HiveField(12)
  bool isChoose = false; // 默认不选中,
  @HiveField(13)
  List replyMemberList = []; // 回复的用户id
  @HiveField(14)
  List imgList = []; // image
  @HiveField(15)
  bool isMod = false; // 管理员
}
