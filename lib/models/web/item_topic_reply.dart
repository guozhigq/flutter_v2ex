// 帖子详情页下的评论item
import 'dart:ffi';

class ReplyItem {
  bool isOwner = false; // 是否op主
  String avatar = '';
  String userName = '';
  String lastReplyTime = '';
  String content = ''; // 纯文本
  String contentRendered = ''; // 带html标签
  String replyId = '';
  String favorites = ''; // 感谢数量
  bool favoritesStatus = false; // 感谢状态 登录状态
  String number = ''; // 楼层
  String floorNumber = ''; // 楼层
  String platform = ''; // 平台 Android ios
}
