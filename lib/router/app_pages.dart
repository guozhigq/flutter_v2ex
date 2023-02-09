
import 'package:get/get.dart';
import 'package:flutter_v2ex/pages/help_page.dart';
import 'package:flutter_v2ex/pages/message_page.dart';
import 'package:flutter_v2ex/pages/nodes_page.dart';
import 'package:flutter_v2ex/pages/webview_page.dart';
import 'package:flutter_v2ex/pages/login_page.dart';

import 'package:flutter_v2ex/pages/t/:topicId.dart';
import 'package:flutter_v2ex/pages/go/:nodeId.dart';
import 'package:flutter_v2ex/pages/member/:memberId.dart';
import 'package:flutter_v2ex/pages/member/:memberId/topics.dart';
import 'package:flutter_v2ex/pages/member/:memberId/replies.dart';

import 'package:flutter_v2ex/pages/my/nodes.dart';
import 'package:flutter_v2ex/pages/my/topics.dart';
import 'package:flutter_v2ex/pages/my/following.dart';
import 'package:flutter_v2ex/pages/image_preview_page.dart';


class AppPages {
  static final List<GetPage> getPages = [
    // 登录页面
    GetPage(name: '/login', page: () => const LoginPage(), fullscreenDialog: true),
    // 话题详情
    GetPage(name: '/t/:topicId', page: () => const TopicDetail()),
    // webview
    GetPage(name: '/webView', page: () => WebView(aUrl: '')),

    // 节点主页
    GetPage(name: '/go/:nodeId', page: () => const GoPage()),
    // 所有节点
    GetPage(name: '/nodes', page: () => const NodesPage()),
    // 帮助页面
    GetPage(name: '/help', page: () => const HelpPage()),

    // 用户主页
    GetPage(name: '/member/:memberId', page: () => const MemberPage()),
    // 用户发布的主题
    GetPage(name: '/member/:memberId/topics', page: () => const MemberTopicsPage()),
    // 用户发布的回复
    GetPage(name: '/member/:memberId/replies', page: () => const MemberRepliesPage()),

    // 我收藏的节点
    GetPage(name: '/my/nodes', page: () => const MyNodesPage(), middlewares: [
      GetMiddleware()
    ]),
    // 我收藏的主题
    GetPage(name: '/my/topics', page: () => const MyTopicsPage()),
    // 我关注的主题、用户
    GetPage(name: '/my/following', page: () => const MyFollowPage()),

    // 消息提醒
    GetPage(name: '/notifications', page: () => const MessagePage()),
    // 图片预览
    GetPage(name: '/imgPreview', page: () => ImagePreview(imgList: []), fullscreenDialog: true)
  ];

}


