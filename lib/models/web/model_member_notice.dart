import 'item_member_notice.dart';

class MemberNoticeModel {
  int totalPage = 1; // 总页数
  int totalCount = 0; // 总条目
  List<MemberNoticeItem> noticeList = []; // 消息列表
  bool isEmpty = false; // 无内容
}
