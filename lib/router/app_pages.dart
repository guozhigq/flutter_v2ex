import 'package:get/get.dart';
import 'package:flutter_v2ex/pages/help_page.dart';
import 'package:flutter_v2ex/pages/message_page.dart';
import 'package:flutter_v2ex/pages/nodes_page.dart';
import 'package:flutter_v2ex/pages/webview_page.dart';

import 'package:flutter_v2ex/pages/t/:topicId.dart';
import 'package:flutter_v2ex/pages/go/:nodeId.dart';
import 'package:flutter_v2ex/pages/member/:memberId.dart';
import 'package:flutter_v2ex/pages/member/:memberId/topics.dart';
import 'package:flutter_v2ex/pages/member/:memberId/replies.dart';

import 'package:flutter_v2ex/pages/my/nodes.dart';
import 'package:flutter_v2ex/pages/my/topics.dart';
import 'package:flutter_v2ex/pages/my/following.dart';


class AppPages {
  static final List<GetPage> getPages = [
    // GetPage(
    //   name: '/login',
    //   page: () => const LoginPage(),
    //   transition: Transition.downToUp,
    // ),
    // GetPage(name: '/listDetail', page: () => const ListDetail(topicId: '')),
    // 话题详情
    GetPage(name: '/t/:topicId', page: () => const TopicDetail()),
    GetPage(name: '/webView', page: () => WebView(aUrl: '')),
    // 节点主页
    // GetPage(name: '/go', page: () => GoPage(nodeKey: '')),
    GetPage(name: '/go/:nodeId', page: () => const GoPage()),
    GetPage(name: '/nodes', page: () => const NodesPage()),
    GetPage(name: '/help', page: () => const HelpPage()),

    // 用户主页
    GetPage(name: '/member/:memberId', page: () => const MemberPage()),
    // 用户发布的主题
    GetPage(name: '/member/:memberId/topics', page: () => const MemberTopicsPage()),
    // 用户发布的回复
    GetPage(name: '/member/:memberId/replies', page: () => const MemberRepliesPage()),

    // 我收藏的节点
    GetPage(name: '/my/nodes', page: () => const MyNodesPage()),
    // 我收藏的主题
    GetPage(name: '/my/topics', page: () => const MyTopicsPage()),
    // 我关注的主题、用户
    GetPage(name: '/my/following', page: () => const MyFollowPage()),


    // GetPage(name: '/profile', page: () => ProfilePage(memberId: '')),
    // 消息提醒
    GetPage(name: '/notifications', page: () => const MessagePage()),
  ];
}
