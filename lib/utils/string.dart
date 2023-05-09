import 'package:flutter_v2ex/models/tabs.dart';

enum ThemeType { light, dark, system } // 主题切换

enum NoticeType { reply, thanksTopic, thanksReply, favTopic } // 消息类型

const int baseFontSize = 14;

class Strings {
  static String v2exHost = "https://www.v2ex.com";
  static String remoteUrl = "https://github.com/guozhigq/flutter_v2ex";

  /// 提交tag时 记得更改
  static String currentVersion = 'v1.2.3';
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
    "Markdown",
    "nofollow",
    "noopener",
    "referrer",
    "loading="
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

  // 酷安表情
  static Map<String, String> coolapkEmoticon = {
    "k_doge": "https://i.imgur.com/WyJtjIO.png",
    "k_\u4e8c\u54c8": "https://i.imgur.com/wgnukxM.png",
    "k_\u4eb2\u4eb2": "https://i.imgur.com/nTqqMwt.png",
    "k_\u5047\u54ed": "https://i.imgur.com/c9koCsd.png",
    "k_\u5047\u7b11": "https://i.imgur.com/wevaACJ.png",
    "k_\u518d\u89c1": "https://i.imgur.com/BQM3wnz.png",
    "k_\u53d1\u6012": "https://i.imgur.com/a4oxROe.png",
    "k_\u53d8\u6001\u6ed1\u7a3d": "https://i.imgur.com/p71XhF9.png",
    "k_\u53ef\u601c": "https://i.imgur.com/86QzF2v.png",
    "k_\u5403\u74dc": "https://i.imgur.com/4ctg1uh.png",
    "k_\u5410\u8840": "https://i.imgur.com/9N68fjF.png",
    "k_\u5428\u5428\u5428": "https://i.imgur.com/RL8pEff.png",
    "k_\u5472\u7259": "https://i.imgur.com/7SddcaX.png",
    "k_\u5496\u5561": "https://i.imgur.com/1RtxlL4.png",
    "k_\u54c8\u54c8": "https://i.imgur.com/EK8QKc9.png",
    "k_\u54ed\u4e86": "https://i.imgur.com/XutJACB.png",
    "k_\u559c": "https://i.imgur.com/wePQo18.png",
    "k_\u55b7": "https://i.imgur.com/S7KMNsS.png",
    "k_\u563f\u54c8": "https://i.imgur.com/QnPXAfK.png",
    "k_\u574f\u7b11": "https://i.imgur.com/2vn1v8b.png",
    "k_\u5927\u7b11": "https://i.imgur.com/E5Uqqfk.png",
    "k_\u5965\u7279\u66fc": "https://i.imgur.com/3UgIUCZ.png",
    "k_\u59d4\u5c48": "https://i.imgur.com/z1UStbV.png",
    "k_\u5e72\u676f": "https://i.imgur.com/savTxnM.png",
    "k_\u5fc3\u788e": "https://i.imgur.com/LMcbPfS.png",
    "k_\u60ca\u8bb6": "https://i.imgur.com/k5cgDsG.png",
    "k_\u6253\u8138": "https://i.imgur.com/hePLVvZ.png",
    "k_\u6253\u8138\u6ed1\u7a3d": "https://i.imgur.com/xgNoo8x.png",
    "k_\u6258\u816e": "https://i.imgur.com/rdq8HCd.png",
    "k_\u62b1\u62f3": "https://i.imgur.com/NpZz2rJ.png",
    "k_\u6342\u5634\u7b11": "https://i.imgur.com/zhwu7Iu.png",
    "k_\u673a\u667a": "https://i.imgur.com/PwcbJI4.png",
    "k_\u6d41\u6c57\u6ed1\u7a3d": "https://i.imgur.com/P5gN5BH.png",
    "k_\u6d41\u6cea": "https://i.imgur.com/ZTr5z44.png",
    "k_\u6ed1\u7a3d": "https://i.imgur.com/zRwC7aD.png",
    "k_\u725b\u5564": "https://i.imgur.com/jP8z9va.png",
    "k_\u751f\u6c14": "https://i.imgur.com/36KFRac.png",
    "k_\u7591\u95ee": "https://i.imgur.com/sOgSspk.png",
    "k_\u770b\u620f": "https://i.imgur.com/FiTQUcO.png",
    "k_\u778c\u7761": "https://i.imgur.com/5eC6nLz.png",
    "k_\u7eff\u5e3ddoge": "https://i.imgur.com/NyRxtpF.png",
    "k_\u82b1": "https://i.imgur.com/i02mU8N.png",
    "k_\u83dc\u5200": "https://i.imgur.com/rp1OaQW.png",
    "k_\u86cb\u7cd5": "https://i.imgur.com/5Jmbs5y.png",
    "k_\u8721\u70db": "https://i.imgur.com/l7ZxZec.png",
    "k_\u8dea\u4e86": "https://i.imgur.com/XkfBzmK.png",
    "k_\u9119\u89c6": "https://i.imgur.com/MQFgdh9.png",
    "k_\u9177": "https://i.imgur.com/eq6tPW7.png",
    "k_\u9634\u9669": "https://i.imgur.com/UdCZ5hH.png",
    "k_\u9999\u8549": "https://i.imgur.com/fy7FxE8.png"
  };
}
