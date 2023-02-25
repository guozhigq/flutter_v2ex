import 'package:get/get.dart';
import 'package:flutter_v2ex/pages/page_help.dart';
import 'package:flutter_v2ex/pages/page_message.dart';
import 'package:flutter_v2ex/pages/page_nodes.dart';
import 'package:flutter_v2ex/pages/page_webView.dart';
import 'package:flutter_v2ex/pages/page_login.dart';
import 'package:flutter_v2ex/pages/page_setting.dart';

import 'package:flutter_v2ex/pages/t/:topicId.dart';
import 'package:flutter_v2ex/pages/go/:nodeId.dart';
import 'package:flutter_v2ex/pages/member/:memberId.dart';
import 'package:flutter_v2ex/pages/member/:memberId/topics.dart';
import 'package:flutter_v2ex/pages/member/:memberId/replies.dart';

import 'package:flutter_v2ex/pages/my/topics.dart';
import 'package:flutter_v2ex/pages/my/follow.dart';
import 'package:flutter_v2ex/pages/page_preview.dart';
import 'package:flutter_v2ex/pages/page_search.dart';
import 'package:flutter_v2ex/pages/page_hot.dart';
import 'package:flutter_v2ex/pages/page_write.dart';
import 'package:flutter_v2ex/pages/page_nodes_topic.dart';

class AppPages {
  static final List<GetPage> getPages = [
    // 登录页面
    GetPage(
        name: '/login', page: () => const LoginPage(), fullscreenDialog: true),
    // 话题详情
    GetPage(name: '/t/:topicId', page: () => const TopicDetail()),
    // webView
    GetPage(name: '/webView', page: () => const WebView(), fullscreenDialog: true, transitionDuration: const Duration(milliseconds: 300)),

    // 节点主页
    GetPage(name: '/go/:nodeId', page: () => const GoPage()),
    // 所有节点
    GetPage(name: '/nodes', page: () => const NodesPage(), fullscreenDialog: true),
    // 帮助页面
    GetPage(name: '/help', page: () => const HelpPage()),

    // 用户主页
    GetPage(name: '/member/:memberId', page: () => const MemberPage()),
    // 用户发布的主题
    GetPage(
        name: '/member/:memberId/topics', page: () => const MemberTopicsPage()),
    // 用户发布的回复
    GetPage(
        name: '/member/:memberId/replies',
        page: () => const MemberRepliesPage()),

    // 我收藏的主题
    GetPage(name: '/my/topics', page: () => const MyTopicsPage()),
    // 我关注的主题、用户
    GetPage(name: '/my/following', page: () => const MyFollowPage()),

    // 消息提醒
    GetPage(name: '/notifications', page: () => const MessagePage()),
    // 图片预览
    GetPage(
        name: '/imgPreview',
        page: () => ImagePreview(imgList: []),
        fullscreenDialog: true),
    // 设置
    GetPage(name: '/setting', page: () => const SettingPage()),
    // 搜索
    GetPage(name: '/search', page: () => const SearchPage()),
    // 热议
    GetPage(name: '/hot', page: () => const HotPage()),
    // 发布主题
    GetPage(name: '/write', page: () => const WritePage()),
    // 主题节点
    GetPage(name: '/topicNodes', page: () => const TopicNodesPage()),
  ];
}
