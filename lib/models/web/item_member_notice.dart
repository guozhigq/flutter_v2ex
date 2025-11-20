import 'package:flutter_v2ex/utils/string.dart';

class MemberNoticeItem  {
  String memberId = ''; // 回复用户id
  String memberAvatar = ''; // 回复用户头像
  String replyContent = ''; // 回复内容
  String? replyContentHtml;
  List<String> replyMemberId = []; // 被回复id
  String replyTime = ''; // 回复时间
  String topicTitle = ''; // 主题标题
  String? topicTitleHtml; // 主题标题
  String topicId = ''; // 主题id
  String delIdOne = ''; // 删除id
  String delIdTwo = ''; // 删除id
  NoticeType noticeType = NoticeType.reply; // 消息类型 可枚举
  String topicHref = ''; // 主题href  /t/923791#reply101
}
