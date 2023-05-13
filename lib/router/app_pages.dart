import 'package:flutter/animation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_v2ex/pages/help/network.dart';
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
import 'package:flutter_v2ex/pages/search/index.dart';
import 'package:flutter_v2ex/pages/page_hot.dart';
import 'package:flutter_v2ex/pages/page_write.dart';
import 'package:flutter_v2ex/pages/page_nodes_topic.dart';
import 'package:flutter_v2ex/pages/page_history.dart';
import 'package:flutter_v2ex/pages/page_agreement.dart';
import 'package:flutter_v2ex/pages/page_history_hot.dart';
import 'package:flutter_v2ex/pages/help/change_log/index.dart';

import 'package:flutter_v2ex/pages/setting/page_font.dart';
import 'package:flutter_v2ex/pages/setting/page_nodes_sort.dart';
import 'package:flutter_v2ex/pages/setting/page_display_mode.dart';
import 'package:flutter_v2ex/utils/storage.dart';

class AppPages {
  static final List<GetPage> getPages = [
    // 登录页面
    GetPage(
      name: '/login',
      page: () => const LoginPage(),
      fullscreenDialog: true,
      transitionDuration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    ),
    // 话题详情
    CustomGetPage('/t/:topicId', TopicDetail()),
    // webView
    GetPage(
        name: '/webView',
        page: () => const WebView(),
        fullscreenDialog: true,
        transitionDuration: const Duration(milliseconds: 300)),

    // 节点主页
    CustomGetPage('/go/:nodeId', const GoPage()),
    // 所有节点
    CustomGetPage('/nodes', const NodesPage()),
    // 帮助页面
    CustomGetPage('/help', const HelpPage()),

    // 用户主页
    CustomGetPage('/member/:memberId', const MemberPage()),
    // 用户发布的主题
    CustomGetPage('/member/:memberId/topics', const MemberTopicsPage()),
    // 用户发布的回复
    CustomGetPage('/member/:memberId/replies', const MemberRepliesPage()),

    // 我收藏的主题
    CustomGetPage('/my/topics', const MyTopicsPage()),
    // 我关注的主题、用户
    CustomGetPage('/my/following', const MyFollowPage()),

    // 消息提醒
    CustomGetPage('/notifications', const MessagePage()),
    // 图片预览
    GetPage(
      name: '/imgPreview',
      page: () => const ImagePreview(),
      transition: Transition.cupertino,
    ),
    // 设置
    CustomGetPage('/setting', const SettingPage()),
    // 搜索
    CustomGetPage('/search', const SearchPage()),
    // 热议
    CustomGetPage('/hot', const HotPage()),
    // 发布主题
    CustomGetPage('/write', const WritePage()),
    // 主题节点
    CustomGetPage('/topicNodes', const TopicNodesPage()),
    // 主题设置
    CustomGetPage('/setFont', const SetFontPage()),
    // 节点排序
    CustomGetPage('/nodesSort', const NodesSortPage()),
    // 最近浏览
    CustomGetPage('/history', const HistoryPage()),
    // 隐私协议
    CustomGetPage('/agreement', const AgreementPage()),
    // 历史热议
    CustomGetPage('/historyHot', const HistoryHotPage()),
    // 网络
    CustomGetPage('/networkCheck', const NetworkCheckPage()),
    // 更新日志
    CustomGetPage('/changeLog', const ChangeLogPage()),
    // 设置帧率
    CustomGetPage('/setDisplayMode', const SetDiaplayMode()),
  ];
}

bool sideslip = GStorage().getSideslip();

class CustomGetPage extends GetPage {
  bool? fullscreen = false;

  CustomGetPage(
    name,
    page, {
    this.fullscreen,
    transitionDuration,
  }) : super(
          name: name,
          page: () => page,
          curve: Curves.linear,
          //  iPad 模式下 Transition.fadeIn mob 模式下 Transition.cupertino
          transition: sideslip ? Transition.cupertino : Transition.native,
          // iPad 模式下关闭 | context.width
          gestureWidth: sideslip ? (context) => context.width : null,
          showCupertinoParallax: false,
          popGesture: false,
          transitionDuration: transitionDuration,
          fullscreenDialog: fullscreen != null && fullscreen,
        );
}
