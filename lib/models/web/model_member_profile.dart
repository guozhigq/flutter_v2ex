import 'package:flutter_v2ex/models/web/item_member_topic.dart';
import 'package:flutter_v2ex/models/web/item_member_reply.dart';
import 'package:flutter_v2ex/models/web/item_member_social.dart';

class ModelMemberProfile {
  List<MemberTopicItem> topicList = []; // 主题列表
  List<MemberReplyItem> replyList = []; // 回复列表
  List<MemberSocialItem> socialList = []; // 社交
  String memberId = '';
  String mbAvatar = '';
  String mbCreatedTime = '';
  String mbSign = ''; // 简介
  bool isOnline = false; // 是否在线
  bool isFollow = false; // 是否关注
  bool isShow = true; // 隐私设置
  bool isEmpty = false; // 主题列表为空
  String socialEle = ''; // 社交
}