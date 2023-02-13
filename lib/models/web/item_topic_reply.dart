// 帖子详情页下的评论item

class ReplyItem {
  bool isOwner = false; // 是否op主
  String avatar = '';
  String userName = '';
  String lastReplyTime = '';
  String content = ''; // 纯文本
  String contentRendered = ''; // 带html标签
  String replyId = '';
  int favorites = 0; // 感谢数量
  bool favoritesStatus = false; // 感谢状态 登录状态
  String number = ''; // 楼层
  int floorNumber = 0; // 楼层
  String platform = ''; // 平台 Android ios
  bool isChoose = false; // 默认不选中,
  List replyMemberList = []; // 回复的用户id
  List imgList = []; // image
}
