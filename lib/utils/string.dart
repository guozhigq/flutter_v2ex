

import 'package:flutter_v2ex/models/tabs.dart';

enum ThemeType { light, dark, system } // 主题切换
enum NoticeType { reply, thanksTopic, thanksReply, favTopic } // 消息类型
const int baseFontSize = 14;

class Strings {
  static String v2exHost = "https://www.v2ex.com";
  static String remoteUrl = "https://github.com/guozhigq/flutter_v2ex";
  /// 提交tag时 记得更改
  static String currentVersion = 'v1.2.2';
  List base64BlackList = [
    "bilibili",
    "Bilibili",
    "MyTomato",
    "InDesign",
    "Encrypto",
    "encrypto",
    "Window10",
    "USERNAME",
    "airpords",
    "Windows7",
    "iMessage",
    "appStore",
    "appStore",
    "Installation",
    "markdown",
    "Markdown"
  ];
  static List<TabModel> tabs = [
    TabModel('最近', 'recent', 'recent', true),
    TabModel('最新', 'changes', 'changes', true),
    TabModel('全部', 'all', 'tab', true),
    TabModel('最热', 'hot', 'tab', true),
    TabModel('技术', 'tech', 'tab', true),
    TabModel('创意', 'creative', 'tab', true),
    TabModel('好玩', 'play', 'tab', true),
    TabModel('APPLE', 'apple', 'tab', true),
    TabModel('酷工作', 'jobs', 'tab', true),
    TabModel('交易', 'deals', 'tab', true),
    TabModel('城市', 'city', 'tab', true),
    TabModel('问与答', 'qna', 'tab', true),
    TabModel('R2', 'r2', 'tab', true),
  ];
  static int maxAge = 7; // 最多记录7天已读
}
