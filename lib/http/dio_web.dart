import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

// import 'package:flutter_v2ex/http/init.dart';
import 'package:flutter_v2ex/http/init.dart';
import 'package:html/dom.dart'
    as dom; // Contains DOM related classes for extracting data from elements
// import 'package:html/dom.dart';
import 'package:html/parser.dart'; // Contains HTML parsers to generate a Document object
// import 'package:xpath/xpath.dart';
import 'package:flutter_v2ex/package/xpath/xpath.dart';

// import 'package:html/dom_parsing.dart';
// import 'package:html/html_escape.dart';

import 'package:flutter_v2ex/models/web/item_tab_topic.dart'; // 首页tab主题列表
import 'package:flutter_v2ex/models/web/model_topic_detail.dart'; // 主题详情
import 'package:flutter_v2ex/models/web/item_topic_reply.dart'; // 主题回复
import 'package:flutter_v2ex/models/web/item_topic_subtle.dart'; // 主题附言
import 'package:flutter_v2ex/models/web/model_node_list.dart'; // 节点列表
// import 'package:flutter_v2ex/models/web/item_node_list.dart';
import 'package:flutter_v2ex/models/web/model_topic_fav.dart'; // 收藏的主题
import 'package:flutter_v2ex/models/web/model_login_detail.dart'; // 用户登录字段
import 'package:flutter_v2ex/models/web/model_node_fav.dart';
import 'package:flutter_v2ex/models/web/model_member_reply.dart';
import 'package:flutter_v2ex/models/web/item_member_reply.dart';
import 'package:flutter_v2ex/models/web/model_member_topic.dart';
import 'package:flutter_v2ex/models/web/item_member_topic.dart';
import 'package:flutter_v2ex/models/web/item_member_social.dart';
import 'package:flutter_v2ex/models/web/model_member_profile.dart';
import 'package:flutter_v2ex/models/web/model_member_notice.dart';
import 'package:flutter_v2ex/models/web/item_member_notice.dart';

import 'package:dio_http_cache/dio_http_cache.dart';
import '/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_v2ex/utils/string.dart';

class DioRequestWeb {
  static dynamic _parseAndDecode(String response) {
    return jsonDecode(response);
  }

  static Future parseJson(String text) {
    return compute(_parseAndDecode, text);
  }

  // 错误、异常处理
  static void formatError(DioError e) {
    switch (e.type) {
      case DioErrorType.cancel:
        break;
      case DioErrorType.connectTimeout:
        print('链接超时');
        break;
      case DioErrorType.sendTimeout:
        print('发送请求超时');
        break;
      case DioErrorType.receiveTimeout:
        print('响应超时');
        break;
      case DioErrorType.response:
        break;
      case DioErrorType.other:
        break;
    }
  }

  // 获取主页分类内容
  static Future<List<TabTopicItem>> getTopicsByTabKey(
    String type,
    String id,
    int p,
  ) async {
    var topics = <TabTopicItem>[];
    Response response;
    // type
    // all 默认节点 一页   /?tab=xxx
    // recent 最新主题 翻页 /recent?p=1
    // go 子节点 翻页 /go/xxx
    switch (type) {
      case 'tab':
        response = await Request().get(
          '/',
          data: {'tab': id},
          extra: {'ua': 'mob', 'channel': 'web'},
        );
        break;
      case 'recent':
        return await getTopicsRecent(p).then((value) => value);
      case 'go':
        return await getTopicsByNodeKey(id, p).then((value) => value.topicList);
      default:
        response = await Request().get(
          '/',
          data: {'tab': 'all'},
          extra: {'ua': 'mob', 'channel': 'web'},
        );
        break;
    }
    var tree = ETree.fromString(response.data);
    // 用户信息解析
    // var rootDom = parse(response.data);
    // var userWrap = rootDom.querySelector('div#site-header-menu');
    // print(userWrap!.querySelectorAll('div.cell').length);
    // var isLogin = userWrap!.querySelectorAll('div.cell').length > 6

    var aRootNode = tree.xpath("//*[@class='cell item']");
    for (var aNode in aRootNode!) {
      var item = TabTopicItem();
      item.memberId =
          aNode.xpath("/table/tr/td[3]/span[1]/strong/a/text()")![0].name!;
      item.avatar = Uri.encodeFull(aNode
          .xpath("/table/tr/td[1]/a[1]/img[@class='avatar']")
          ?.first
          .attributes["src"]);
      String topicUrl = aNode
          .xpath("/table/tr/td[3]/span[2]/a")
          ?.first
          .attributes["href"]; // 得到是 /t/522540#reply17
      item.topicId = topicUrl.replaceAll("/t/", "").split("#")[0];
      if (aNode.xpath("/table/tr/td[4]")!.first.children.isNotEmpty) {
        item.replyCount =
            int.parse(aNode.xpath("/table/tr/td[4]/a/text()")![0].name!);
          item.lastReplyTime = aNode
              .xpath("/table/tr/td[3]/span[3]/text()[1]")![0]
              .name!
              .split(' &nbsp;')[0]
              .replaceAll("/t/", "");
        if (aNode.xpath("/table/tr/td[3]/span[3]/strong/a/text()") != null) {
          item.lastReplyMId =
              aNode.xpath("/table/tr/td[3]/span[3]/strong/a/text()")![0].name!;
        }
      }else{
        item.lastReplyTime = aNode.xpath("/table/tr/td[3]/span[3]/text()")![0].name!;
      }
      item.topicTitle = aNode
          .xpath("/table/tr/td[3]/span[2]/a/text()")![0]
          .name!
          .replaceAll('&quot;', '')
          .replaceAll('&amp;', '&')
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>');
      print(item.replyCount);

      item.nodeName = aNode.xpath("/table/tr/td[3]/span[1]/a/text()")![0].name!;
      item.nodeId = aNode
          .xpath("/table/tr/td[3]/span[1]/a")
          ?.first
          .attributes["href"]
          .split('/')[2];
      topics.add(item);
    }
    return topics;
  }

  // 获取最新的主题
  static Future<List<TabTopicItem>> getTopicsRecent(int p) async {
    var topics = <TabTopicItem>[];
    Response response;
    response = await Request().get(
      '/recent',
      data: {'p': p},
      extra: {'ua': 'pc', 'channel': 'web'},
    );
    var tree = ETree.fromString(response.data);
    var aRootNode = tree.xpath("//*[@class='cell item']");
    for (var aNode in aRootNode!) {
      var item = TabTopicItem();
      item.memberId =
          aNode.xpath("/table/tr/td[3]/span[2]/strong/a/text()")![0].name!;
      item.avatar = Uri.encodeFull(aNode
          .xpath("/table/tr/td[1]/a[1]/img[@class='avatar']")
          ?.first
          .attributes["src"]);
      String topicUrl = aNode
          .xpath("/table/tr/td[3]/span[1]/a")
          ?.first
          .attributes["href"]; // 得到是 /t/522540#reply17
      item.topicId = topicUrl.replaceAll("/t/", "").split("#")[0];
      if (aNode.xpath("/table/tr/td[4]")!.first.children.isNotEmpty) {
        item.replyCount =
            int.parse(aNode.xpath("/table/tr/td[4]/a/text()")![0].name!);
      }
      item.lastReplyTime =
          aNode.xpath("/table/tr/td[3]/span[2]/span/text()")![0].name!;
      item.nodeName = aNode
          .xpath("/table/tr/td[3]/span[2]/a/text()")![0]
          .name!
          .replaceAll('&quot;', '')
          .replaceAll('&amp;', '&')
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>');

      item.topicTitle =
          aNode.xpath("/table/tr/td[3]/span[1]/a/text()")![0].name!;
      item.nodeId = aNode
          .xpath("/table/tr/td[3]/span[2]/a")
          ?.first
          .attributes["href"]
          .split('/')[2];
      topics.add(item);
    }
    return topics;
  }

  // 获取节点下的主题
  static Future<NodeListModel> getTopicsByNodeKey(String nodeKey, int p) async {
    // print('------getTopicsByNodeKey---------');
    NodeListModel detailModel = NodeListModel();
    List<TabTopicItem> topics = [];
    Response response;
    // 请求PC端页面 lastReplyTime totalPage
    // Request().dio.options.headers = {};
    response = await Request().get(
      '/go/$nodeKey',
      data: {'p': p},
      extra: {'ua': 'pc'},
    );
    var document = parse(response.data);
    var mainBox = document.body!.children[1].querySelector('#Main');
    var mainHeader = document.querySelector('div.box.box-title.node-header');
    detailModel.nodeCover =
        mainHeader!.querySelector('img')!.attributes['src']!;
    // 节点名称
    detailModel.nodeName =
        mainHeader.querySelector('div.node-breadcrumb')!.text.split('›')[1];
    // 主题总数
    detailModel.topicCount = mainHeader.querySelector('strong')!.text;
    // 节点描述
    if (mainHeader.querySelector('div.intro') != null) {
      detailModel.nodeIntro = mainHeader.querySelector('div.intro')!.text;
    }
    // 节点收藏状态
    if (mainHeader.querySelector('div.cell_ops') != null) {
      detailModel.isFavorite =
          mainHeader.querySelector('div.cell_ops')!.text.contains('取消');
    }
    if (mainBox!.querySelector(
            'div.box:not(.box-title)>div.cell:not(.tab-alt-container):not(.item)') !=
        null) {
      var totalpageNode = mainBox.querySelector(
          'div.box:not(.box-title)>div.cell:not(.tab-alt-container)');
      if (totalpageNode!.querySelectorAll('a.page_normal').isNotEmpty) {
        detailModel.totalPage = int.parse(
            totalpageNode.querySelectorAll('a.page_normal').last.text);
      }
    }

    if (document.querySelector('#TopicsNode') != null) {
      // 主题
      var topicEle =
          document.querySelector('#TopicsNode')!.querySelectorAll('div.cell');
      for (var aNode in topicEle) {
        var item = TabTopicItem();

        //  头像 昵称
        if (aNode.querySelector('td > a > img') != null) {
          item.avatar = aNode.querySelector('td > a > img')!.attributes['src']!;
          item.memberId =
              aNode.querySelector('td > a > img')!.attributes['alt']!;
        }

        if (aNode.querySelector('tr > td:nth-child(5)') != null) {
          item.topicTitle = aNode
              .querySelector('td:nth-child(5) > span.item_title')!
              .text
              .replaceAll('&quot;', '')
              .replaceAll('&amp;', '&')
              .replaceAll('&lt;', '<')
              .replaceAll('&gt;', '>');
          // var topicSub = aNode
          //     .querySelector('td:nth-child(5) > span.small')!
          //     .text
          //     .replaceAll('&nbsp;', "");
          // item.memberId = topicSub.split('•')[0].trim();
          // item.clickCount =
          //     topicSub.split('•')[2].trim().replaceAll(RegExp(r'[^0-9]'), '');
        }
        if (aNode.querySelector('tr > td:last-child > a') != null) {
          String? topicUrl = aNode
              .querySelector('tr > td:last-child > a')!
              .attributes['href']; // 得到是 /t/522540#reply17
          item.topicId = topicUrl!.replaceAll("/t/", "").split("#")[0];
          item.replyCount = int.parse(topicUrl
              .replaceAll("/t/", "")
              .split("#")[1]
              .replaceAll(RegExp(r'[^0-9]'), ''));
        }
        if (aNode.querySelector('tr') != null) {
          var topicTd = aNode.querySelector('tr')!.children[2];
          item.lastReplyTime = topicTd
              .querySelector('span.topic_info > span')!
              .text
              .replaceAll("/t/", "");
        }
        // item.nodeName = aNode.xpath("/table/tr/td[3]/span[1]/a/text()")![0].name!;
        topics.add(item);
      }
    }
    detailModel.topicList = topics;
    return detailModel;
  }

  // 获取收藏的主题
  static Future<FavTopicModel> getFavTopics(int p) async {
    FavTopicModel favTopicDetail = FavTopicModel();
    List<TabTopicItem> topicList = [];

    Response response;
    response = await Request().get(
      '/my/topics',
      data: {'p': p},
      extra: {
        'ua': 'mob',
      },
    );
    var document = parse(response.data);
    var mainBox = document
        .querySelector('#Wrapper > div.content > div.box:not(.box-title)');
    var totalPageNode =
        mainBox!.querySelector('div.cell:not(.tab-alt-container):not(.item)');
    if (totalPageNode != null) {
      if (totalPageNode.querySelectorAll('a.page_normal').isNotEmpty) {
        favTopicDetail.totalPage = int.parse(
            totalPageNode.querySelectorAll('a.page_normal').last.text);
      }
    }
    var cellBox = mainBox.querySelectorAll('div.cell.item');
    for (var aNode in cellBox) {
      TabTopicItem item = TabTopicItem();
      if (aNode.querySelector('img.avatar') != null) {
        item.avatar = aNode.querySelector('img.avatar')!.attributes['src']!;
        // item.memberId = aNode.querySelector('img.avatar')!.attributes['alt']!;
      }
      if (aNode.querySelector('tr > td:nth-child(5)') != null) {
        item.topicTitle = aNode
            .querySelector('td:nth-child(5) > span.item_title')!
            .text
            .replaceAll('&quot;', '')
            .replaceAll('&amp;', '&')
            .replaceAll('&lt;', '<')
            .replaceAll('&gt;', '>');
      }
      if (aNode.querySelector('tr > td:last-child > a') != null) {
        String? topicUrl = aNode
            .querySelector('tr > td:last-child > a')!
            .attributes['href']; // 得到是 /t/522540#reply17
        item.topicId = topicUrl!.replaceAll("/t/", "").split("#")[0];
        item.replyCount = int.parse(topicUrl
            .replaceAll("/t/", "")
            .split("#")[1]
            .replaceAll(RegExp(r'[^0-9]'), ''));
      }
      if (aNode.querySelector('tr') != null) {
        var topicTd = aNode.querySelector('tr')!.children[2];
        item.lastReplyTime = topicTd
            .querySelector('span.topic_info > span')!
            .text
            .replaceAll("/t/", "");
        item.memberId =
            topicTd.querySelectorAll('span.topic_info > strong')[0].text;
      }
      if (aNode.querySelector(' a.node') != null) {
        item.nodeId =
            aNode.querySelector('a.node')!.attributes['href']!.split('/').last;
        item.nodeName = aNode.querySelector('a.node')!.innerHtml;
      }
      topicList.add(item);
    }
    favTopicDetail.topicList = topicList;
    return favTopicDetail;
  }

  // 获取收藏的节点
  static Future<List<NodeFavModel>> getFavNodes() async {
    List<NodeFavModel> favNodeList = [];
    Response response;
    response = await Request().get('/my/nodes', extra: {'ua': 'mob'});
    var tree = ETree.fromString(response.data);
    var aRootNode = tree.xpath("//*[@class='fav-node']");
    for (var aNode in aRootNode!) {
      NodeFavModel item = NodeFavModel();
      item.nodeCover = aNode.xpath("/img")?.first.attributes["src"];
      item.nodeId = aNode.xpath("/img")?.first.attributes["alt"];
      item.nodeName =
          aNode.xpath("/span[@class='fav-node-name']/text()")![0].name!;
      item.topicCount =
          aNode.xpath("/span[@class='f12 fade']/text()")![0].name!;
      favNodeList.add(item);
    }
    // var bodyDom = parse(response.data).body;
    // var nodeListWrap =
    //     bodyDom!.querySelector('div.cell(not.tab-alt-container)');
    // List<dom.Element> nodeListDom = [];
    // if (nodeListWrap != null) {
    //   nodeListDom = nodeListWrap.querySelectorAll('a');
    // }
    // for (var i in nodeListDom) {
    //   NodeFavModel item = NodeFavModel();
    //   if (i.querySelector('img') != null) {
    //     item.nodeCover = i.querySelector('img')!.attributes['src']!;
    //     item.nodeId = i.querySelector('img')!.attributes['alt']!;
    //   }
    //   item.nodeName = i.querySelector('span.fav-node-name')!.text;
    //   item.topicCount = i.querySelector('span.f12.fade')!.text;
    //   print(item.nodeCover);
    // }
    return favNodeList;
  }

  // 获取帖子详情及下面的评论信息 [html 解析的] todo 关注 html 库 nth-child
  static Future<TopicDetailModel> getTopicDetail(String topicId, int p) async {
    // ignore: avoid_print
    // print('line 228: 在请求第$p页面数据');
    TopicDetailModel detailModel = TopicDetailModel();
    List<TopicSubtleItem> subtleList = []; // 附言
    List<ReplyItem> replies = [];
    // List<ProfileRecentReplyItem> replies = <ProfileRecentReplyItem>[];
    var response = await Request().get(
      "/t/$topicId",
      data: {'p': p},
      options: buildCacheOptions(const Duration(days: 4), forceRefresh: true),
      extra: {'ua': 'mob'},
    );
    // Use html parser and query selector
    var document = parse(response.data);
    detailModel.topicId = topicId;

    if (response.redirects.isNotEmpty ||
        document.querySelector('#Main > div.box > div.message') != null) {
      // ignore: avoid_print
      print('需要登录');
      // Fluttertoast.showToast(
      //     msg: '查看本主题需要先登录 😞',
      //     gravity: ToastGravity.CENTER,
      //     timeInSecForIosWeb: 2);
      // Routes.navigatorKey.currentState?.pushNamedAndRemoveUntil(
      //     Routes.toHomePage, ModalRoute.withName("/"));
      SmartDialog.show(
        useSystem: true,
        animationType: SmartAnimationType.centerFade_otherSlide,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('权限不足'),
            content: const Text('登录后查看主题内容'),
            actions: [
              TextButton(
                  onPressed: (() =>
                      {SmartDialog.dismiss(), Navigator.pop(context)}),
                  child: const Text('返回上一页')),
              TextButton(
                  onPressed: (() =>
                      {Navigator.of(context).pushNamed('/login')}),
                  child: const Text('去登录'))
            ],
          );
        },
      );
      detailModel.replyList = replies;
      detailModel.isAuth = true;
      return detailModel;
    }

    /// 头部内容
    /// 查询头部内容公共头

    const String wrapperQuery = '#Wrapper';

    /// main box 正文
    const String mainBoxQuery = '$wrapperQuery > div > div:nth-child(1)';
    const String headerQuery = '$mainBoxQuery > div.header';
    const String innerQuery = '$mainBoxQuery > div.inner';

    detailModel.avatar = document
        .querySelector('$headerQuery > div.fr > a > img')!
        .attributes["src"]!;

    detailModel.createdId =
        document.querySelector('$headerQuery > small > a')!.text;

    detailModel.nodeId = document
        .querySelector('$headerQuery > a:nth-child(6)')!
        .attributes["href"]!
        .replaceAll('/go/', '');

    detailModel.nodeName =
        document.querySelector('$headerQuery > a:nth-child(6)')!.text;
    //  at 9 小时 26 分钟前，1608 次点击
    var pureStr = document
        .querySelector('$headerQuery > small')!
        .text
        .split(' at')[1]
        .replaceAll(RegExp(r"\s+"), "");
    detailModel.createdTime = pureStr.split('·')[0].replaceFirst(' +08:00', '');
    detailModel.visitorCount =
        pureStr.split('·')[1].replaceAll(RegExp(r'[^0-9]'), '');

    // detailModel.smallGray = document
    //     .querySelector('$headerQuery > small')!
    //     .text
    //     .split(' at')[1]
    //     .replaceFirst(' +08:00', ''); // 时间 去除+ 08:00;

    detailModel.topicTitle = document.querySelector('$headerQuery > h1')!.text;

    // [email_protected] 转码回到正确的邮件字符串
    List<dom.Element> aRootNode =
        document.querySelectorAll("a[class='__cf_email__']");
    for (var aNode in aRootNode) {
      String encodedCf = aNode.attributes["data-cfemail"].toString();
      var newEl = document.createElement('SPAN');
      newEl.innerHtml = Utils.cfDecodeEmail(encodedCf);
      aNode.replaceWith(newEl);

      // aNode.replaceWith(Text(Utils.cfDecodeEmail(encodedCf)));
    }

    // 判断是否有正文
    if (document.querySelector('$mainBoxQuery > div.cell > div') != null) {
      detailModel.content =
          document.querySelector('$mainBoxQuery > div.cell > div')!.text;
      detailModel.contentRendered =
          document.querySelector('$mainBoxQuery > div.cell > div')!.innerHtml;
    }

    // 附言
    List<dom.Element> appendNodes =
        document.querySelectorAll("$mainBoxQuery > div[class='subtle']");
    if (appendNodes.isNotEmpty) {
      for (var node in appendNodes) {
        TopicSubtleItem subtleItem = TopicSubtleItem();
        subtleItem.fade = node
            .querySelector('span.fade')!
            .text
            .replaceFirst(' +08:00', ''); // 时间（去除+ 08:00）;
        subtleItem.content = node.querySelector('div.topic_content')!.innerHtml;
        subtleList.add(subtleItem);
      }
    }
    detailModel.subtleList = subtleList;

    // token 是否收藏
    // <a href="/unfavorite/topic/541492?t=lqstjafahqohhptitvcrplmjbllwqsxc" class="op">取消收藏</a>
    // #Wrapper > div > div:nth-child(1) > div.inner > div > a:nth-child(2)
    if (document.querySelector("$innerQuery > div > a[class='op']") != null) {
      String collect = document
          .querySelector("$innerQuery > div > a[class='op']")!
          .attributes["href"]!;
      // detailModel.token = collect.split('?t=')[1];
      detailModel.isFavorite = collect.startsWith('/unfavorite');
      // print('detailModel.isFavorite: ${detailModel.isFavorite}');
    }

    // 登录
    if (document.querySelector("$innerQuery > div > span") != null) {
      String count = document.querySelector("$innerQuery > div > span")!.text;
      if (count.contains('人收藏')) {
        detailModel.favoriteCount = int.parse(count.trim().split('人收藏')[0]);
      }
    }

    // <a href="#;" onclick="if (confirm('确定不想再看到这个主题？')) { location.href = '/ignore/topic/583319?once=62479'; }"
    //    class="op" style="user-select: auto;">忽略主题</a>
    // #Wrapper > div > div:nth-child(1) > div.inner > div > a:nth-child(5)

    // 登录 是否感谢 document.querySelector('#topic_thank > span')
    detailModel.isThank = document.querySelector('#topic_thank > span') != null;
    // print(detailModel.isFavorite == true ? 'yes' : 'no');
    // print(detailModel.isThank == true ? 'yes' : 'no');

    // 判断是否有评论
    if (document.querySelector('#no-comments-yet') == null) {
      // 表示有评论
      // tag 标签
      // var tagBoxDom =
      //     document.querySelector('$wrapperQuery > div')!.children[2];

      // 回复数 发布时间 评论
      dom.Element replyBoxDom;
      dom.Element? totalPageDom;

      // tag标签判断
      var isHasTag = document
              .querySelector('$wrapperQuery > div')!
              .children[2]
              .querySelector('a.tag') !=
          null;
      if (isHasTag) {
        replyBoxDom =
            document.querySelector('$wrapperQuery > div')!.children[4];
      } else {
        replyBoxDom =
            document.querySelector('$wrapperQuery > div')!.children[2];
      }
      if (replyBoxDom.querySelectorAll('div.cell > a.page_normal').isNotEmpty) {
        totalPageDom =
            replyBoxDom.querySelectorAll('div.cell > a.page_normal').last;
      }
      if (p == 1) {
        detailModel.totalPage =
            totalPageDom != null ? int.parse(totalPageDom.text) : 1;
      }

      detailModel.replyCount = replyBoxDom
          .querySelector('div.cell span')!
          .text
          .replaceAll(RegExp(r"\s+"), "")
          .split('条回复')[0];
      // if (p == 1) {
      //   // 只有第一页这样的解析才对
      //   if (document.querySelector(
      //           '#Wrapper > div > div:nth-child(7) > div:last-child > a:last-child') !=
      //       null) {
      //     detailModel.totalPage = int.parse(document
      //         .querySelector(
      //             '#Wrapper > div > div:nth-child(5) > div:last-child > a:last-child')!
      //         .text);
      //   }
      // }

      /// 回复楼层
      /// first td user avatar
      /// third td main content
      List<dom.Element> rootNode = document
          .querySelectorAll("#Wrapper > div > div[class='box'] > div[id]");
      var replyTrQuery = 'table > tbody > tr';
      for (var aNode in rootNode) {
        ReplyItem replyItem = ReplyItem();
        replyItem.avatar = Uri.encodeFull(aNode
            .querySelector('$replyTrQuery > td:nth-child(1) > img')!
            .attributes["src"]!);
        replyItem.userName = aNode
            .querySelector('$replyTrQuery > td:nth-child(5) > strong > a')!
            .text;
        if (aNode.querySelector(
                '$replyTrQuery > td:nth-child(5) > div.badges > div.badge') !=
            null) {
          replyItem.isOwner = true;
        }
        replyItem.lastReplyTime = aNode
            .querySelector('$replyTrQuery > td:nth-child(5) > span')!
            .text
            .replaceFirst(' +08:00', ''); // 时间（去除+ 08:00）和平台（Android/iPhone）
        if (replyItem.lastReplyTime.contains('via')) {
          var platform = replyItem.lastReplyTime
              .split('via')[1]
              .replaceAll(RegExp(r"\s+"), "");
          replyItem.lastReplyTime =
              replyItem.lastReplyTime.split('via')[0].replaceAll("/t/", "");
          replyItem.platform = platform;
        }

        /// @user
        if (aNode.querySelector(
                "$replyTrQuery > td:nth-child(5) > span[class='small fade']") !=
            null) {
          replyItem.favorites = aNode
              .querySelector(
                  "$replyTrQuery > td:nth-child(5) > span[class='small fade']")!
              .text
              .split(" ")[1];
          // 感谢状态
          if (aNode.querySelector(
                  "$replyTrQuery > td:nth-child(5) > div.fr > div.thanked") !=
              null) {
            replyItem.favoritesStatus = true;
          }
        }
        // replyItem.number = aNode
        //     .querySelector(
        //         '$replyTrQuery > td:nth-child(5) > div.fr > span')!
        //     .text;
        replyItem.floorNumber = int.parse(aNode
            .querySelector('$replyTrQuery > td:nth-child(5) > div.fr > span')!
            .text);
        replyItem.contentRendered = aNode
            .querySelector(
                '$replyTrQuery > td:nth-child(5) > div.reply_content')!
            .innerHtml;
        replyItem.content = aNode
            .querySelector(
                '$replyTrQuery > td:nth-child(5) > div.reply_content')!
            .text;

        var replyMemberNodes = aNode.querySelectorAll(
            '$replyTrQuery > td:nth-child(5) > div.reply_content > a');
        if(replyMemberNodes.isNotEmpty){
          for(var aNode in replyMemberNodes){
            if(aNode.attributes['href']!.startsWith('/member')){
              replyItem.replyMemberList.add(aNode.text);
            }
          }
        }
        replyItem.replyId = aNode.attributes["id"]!.substring(2);
        replies.add(replyItem);
      }
    }
    detailModel.replyList = replies;
    return detailModel;
  }

  // 获取所有节点
  static Future getNodes() async {
    List<Map<dynamic, dynamic>> nodesList = [];
    Response response;
    response = await Request().get(
      '/',
      extra: {'ua': 'pc'},
    );
    var document = parse(response.data);
    var nodesBox = document.querySelector('#Main')!.children.last;
    nodesBox.children.removeAt(0);
    var nodeTd = nodesBox.children;
    for (var i in nodeTd) {
      Map nodeItem = {};
      String fName = i.querySelector('span')!.text;
      nodeItem['name'] = fName;
      List<Map<String, String>> childs = [];
      var cEl = i.querySelectorAll('a');
      for (var j in cEl) {
        Map<String, String> item = {};
        item['id'] = j.attributes['href']!.split('/').last;
        item['name'] = j.text;
        childs.add(item);
      }
      nodeItem['childs'] = childs;
      nodesList.add(nodeItem);
    }
    return nodesList;
  }

  // 获取登录字段
  static Future<LoginDetailModel> getLoginKey() async {
    LoginDetailModel loginKeyMap = LoginDetailModel();
    Response response;
    SmartDialog.showLoading();
    response = await Request().get(
      '/signin',
      extra: {'ua': 'mob'},
    );
    SmartDialog.dismiss();
    var document = parse(response.data);
    var tableDom = document.querySelector('table');
    if (document.body!.querySelector('div.dock_area') != null) {
      // 由于当前 IP 在短时间内的登录尝试次数太多，目前暂时不能继续尝试。
      String tipsContent = document.body!
          .querySelector('#Main > div.box > div.cell > div > p')!
          .innerHtml;
      String tipsIp = document.body!
          .querySelector('#Main > div.box > div.dock_area > div.cell')!
          .text;
      SmartDialog.show(
        animationType: SmartAnimationType.centerFade_otherSlide,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('提示'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tipsIp,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 4),
                Text(tipsContent),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: (() => {SmartDialog.dismiss()}),
                  child: const Text('知道了'))
            ],
          );
        },
      );
      return loginKeyMap;
    }
    var trsDom = tableDom!.querySelectorAll('tr');

    for (var aNode in trsDom) {
      String keyName = aNode.querySelector('td')!.text;
      if (keyName.isNotEmpty) {
        if (keyName == '用户名') {
          loginKeyMap.userNameHash =
              aNode.querySelector('input')!.attributes['name']!;
        }
        if (keyName == '密码') {
          loginKeyMap.once = aNode.querySelector('input')!.attributes['value']!;
          loginKeyMap.passwordHash =
              aNode.querySelector('input.sl')!.attributes['name']!;
        }
        if (keyName.contains('机器')) {
          loginKeyMap.codeHash =
              aNode.querySelector('input')!.attributes['name']!;
        }
      }
      if (aNode.querySelector('img') != null) {
        loginKeyMap.captchaImg = '${Strings.v2exHost}${aNode.querySelector('img')!.attributes['src']}?once=${loginKeyMap.once}';
      }
    }
    return loginKeyMap;
  }

  // 登录
  static Future<String> onLogin(LoginDetailModel args) async {
    SmartDialog.showLoading(msg: '登录中...');
    Response response;
    Options options = Options();

    options.contentType = Headers.formUrlEncodedContentType;
    options.headers = {
      // 'content-type': 'application/x-www-form-urlencoded',
      // 必须字段
      'Referer': '${Strings.v2exHost}/signin',
      'Origin': Strings.v2exHost,
      'user-agent':
          'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1'
    };

    // FormData formData = FormData.fromMap({
    //   args.userNameHash: args.userNameValue,
    //   args.passwordHash: args.passwordValue,
    //   args.codeHash: args.codeValue,
    //   'once': args.once,
    //   'next': args.next
    // });

    var data = {
      '32ec105e6f3421fe7ff17ec25a3ed5095347b1f1e4b0d3a2b709bf1672bcac7c': 'guozhigq',
      '45f3b1d5a1d7e38397b3aa6ea9644a40d19ae0ba75081c45af2f1feaee11cf92': '7loveyou',
      '7b97e90ea12b30ad8752732954f66f7079d5850ce612e0d9ddc4e0f1efcd4cbd': 'cefk',
      'once': '97632',
      'next': '/'
    };
    print('data😊:$data');
    FormData formData = FormData.fromMap(
      data
    );
    // var data =
    //     '${args.userNameHash}=${args.userNameValue}&${args.passwordHash}=${args.passwordValue}&${args.codeHash}=${args.codeValue}&once=${args.once}&next="/"';

    response =
        await Request().post('/signin', data: formData, options: options);
    options.contentType = Headers.jsonContentType; // 还原
    // print('response:$response');
    // print('responseData:${response.data}');
    var bodyDom = parse(response.data).body;
    // print('response.statusCode${response.statusCode}');
    if (response.statusCode == 302) {
      print('-------------------------------');
      print(bodyDom);
      print(bodyDom!.innerHtml);
      print(bodyDom.text);

      print('onLogin response.headers:${response.headers['set-cookie']}');
      if (parse(response.data).body!.querySelector('div') != null) {
        print(parse(response.data).body!.querySelector('div')!.innerHtml);
      }
      print('-------------------------------');

      return await getUserInfo();
    }else{
      // 登录失败，去获取错误提示信息
      var tree = ETree.fromString(response.data);
      // //*[@id="Wrapper"]/div/div[1]/div[3]/ul/li "输入的验证码不正确"
      // //*[@id="Wrapper"]/div/div[1]/div[2]/ul/li "用户名和密码无法匹配" 等
      var errorInfo;
      if (tree.xpath('//*[@id="Wrapper"]/div/div[1]/div[3]/ul/li/text()') !=
          null) {
        errorInfo = tree
            .xpath('//*[@id="Wrapper"]/div/div[1]/div[3]/ul/li/text()')![0]
            .name;
      } else {
        errorInfo = tree
            .xpath('//*[@id="Wrapper"]/div/div[1]/div[2]/ul/li/text()')![0]
            .name;
      }
      SmartDialog.dismiss();
      SmartDialog.showToast(errorInfo);
      print("wml error!!!!：$errorInfo");
      return 'false';
    }
  }

  // 获取当前用户信息
  static Future<String> getUserInfo() async {
    var response = await Request().get('/', extra: {'ua': 'mob'});
    print('response.headers:${response.headers['set-cookie']}');
    if (response.redirects.isNotEmpty) {
      print("wml:" + response.redirects[0].location.path);
      // 需要两步验证
      if (response.redirects[0].location.path == "/2fa") {
        response = await Request().get('/2fa');
      }
    }
    var tree = ETree.fromString(response.data);
    var elementOfAvatarImg = tree.xpath("//*[@id='menu-entry']/img")?.first;
    if (elementOfAvatarImg != null) {
      // 获取用户头像
      String avatar = elementOfAvatarImg.attributes["src"];
      String username = elementOfAvatarImg.attributes["alt"]; // "w4mxl"
      print(avatar);
      print(username);

      // todo 判断用户是否开启了两步验证

      // 需要两步验证
      if (response.requestOptions.path == "/2fa") {
        var tree = ETree.fromString(response.data);
        // //*[@id="Wrapper"]/div/div[1]/div[2]/form/table/tbody/tr[3]/td[2]/input[1]
        String once = tree
            .xpath(
                "//*[@id='Wrapper']/div/div[1]/div[2]/form/table/tr[3]/td[2]/input[@name='once']")!
            .first
            .attributes["value"];
        print('两步验证前保存once:$once');
        return "2fa";
      }
      return "true";
    }
    return "false";
  }

  /// action
  // 收藏 / 取消收藏
  static Future<bool> favoriteTopic(bool isFavorite, String topicId,
      {String token = '11896'}) async {
    SmartDialog.showLoading(msg: '请稍等...');
    String url = isFavorite
        ? ("/unfavorite/topic/$topicId?once=$token")
        : ("/favorite/topic/$topicId?once=$token");
    var response = await Request().get(url, extra: {});
    SmartDialog.dismiss();
    if (response.statusCode == 200 || response.statusCode == 302) {
      // 操作成功
      return true;
    }
    return false;
  }

  // 感谢
  static Future<bool> thankTopic(String topicId) async {
    // String once = await getOnce();
    // print("thankTopic：" + once);
    // if (once == null || once.isEmpty) {
    //   return false;
    // }
    var response = await Request().get("/thank/topic/$topicId?once=28900");
    if (response.statusCode == 200 || response.statusCode == 302) {
      // 操作成功
      return true;
    }
    return false;
  }

  // 忽略主题
  static Future<bool> ignoreTopic(String topicId) async {
    // String once = await getOnce();
    // print("ignoreTopic：" + once);
    // if (once == null || once.isEmpty) {
    //   return false;
    // }
    var response = await Request().get("/ignore/topic/$topicId?once=28900");
    if (response.statusCode == 200 || response.statusCode == 302) {
      // 操作成功
      return true;
    }
    return false;
  }

  // 查看每日奖励
  static Future<Map<dynamic, dynamic>> queryDaily() async {
    Map<dynamic, dynamic> signDetail = {
      'signStatus': false,
      'signDays': 0,
      'balance': []
    };
    Response response;
    response = await Request().get('/mission/daily', extra: {'ua': 'pc'});
    var bodyDom = parse(response.data).body;
    var mainBox = bodyDom!.querySelector('#Main');
    var noticeNode =
        bodyDom.querySelector('#Rightbar>div.box>div.cell.flex-one-row');
    if (mainBox != null) {
      // 领取 X 铜币 表示未签到
      var signStatus = mainBox.querySelector('input')!.attributes['value'];
      var boxDom = mainBox.querySelector('div.box');
      // 签到天数
      var cellDom = boxDom!.querySelectorAll('div.cell').last.text;
      signDetail['signStatus'] = signStatus == '领取 X 铜币' ? false : true;
      var day = cellDom.replaceAll(RegExp(r'[^0-9]'), '');
      signDetail['signDays'] = '已领取$day天';
    }
    // 未读消息
    var unRead =
        noticeNode!.querySelector('a')!.text.replaceAll(RegExp(r'[^0-9]'), '');
    print('$unRead条未读消息');

    // 余额
    List balance = noticeNode.querySelector('div#money')!.text.split(' ');
    balance.removeAt(1);
    balance.removeAt(2);
    signDetail['balance'] = balance;

    return signDetail;
  }

  // 签到
  static Future dailyMission() async {
    try {
      var once = 27561;
      var missionResponse = await Request()
          .get("/mission/daily/redeem?once=$once", extra: {'ua': 'mob'});
      print('领取每日奖励:' "/mission/daily/redeem?once=$once");
      if (missionResponse.data.contains('每日登录奖励已领取')) {
        print('每日奖励已自动领取');
      } else {
        print(missionResponse.data);
      }
    } on DioError catch (e) {
      log(e.message);
      // Fluttertoast.showToast(
      //     msg: '领取每日奖励失败：${e.message}',
      //     timeInSecForIosWeb: 2,
      //     gravity: ToastGravity.CENTER);
    }
  }

  // 获取用户信息
  static Future queryMemberProfile(String memberId) async {
    ModelMemberProfile memberProfile = ModelMemberProfile();
    List<MemberTopicItem> topicList = [];
    List<MemberReplyItem> replyList = [];
    List<MemberSocialItem> socialList = [];
    Response response;
    response = await Request().get('/member/$memberId', extra: {'ua': 'pc'});
    // print('response.headers:${response.headers['set-cookie']}');
    var bodyDom = parse(response.data).body;
    var contentDom = bodyDom!.querySelectorAll('#Main > div.box');
    var profileNode = contentDom[0];
    var topicsNode = contentDom[1];
    var replysNode = contentDom[2];

    // 头像、昵称、在线状态、加入时间、关注状态
    var profileCellNode = profileNode.querySelector('div.cell > table');
    memberProfile.mbAvatar =
        profileCellNode!.querySelector('img')!.attributes['src']!;
    memberProfile.memberId = memberId;
    if (profileCellNode.querySelector('tr>td>strong.online') != null) {
      memberProfile.isOnline = true;
    }
    print(memberProfile.isOnline);
    if (profileNode.querySelectorAll('input[type=button]').isNotEmpty) {
      var buttonDom = profileNode.querySelectorAll('input[type=button]');
      var followBtn = buttonDom[0];
      memberProfile.isFollow =
          followBtn.attributes['value'] == '取消特别关注' ? true : false;
    } else {
      memberProfile.isOwner = false;
    }

    // 加入时间
    var mbCreatedTimeDom = profileCellNode.querySelector('span.gray')!.text;
    memberProfile.mbSort = mbCreatedTimeDom.split('+')[0].split('，')[0];
    memberProfile.mbCreatedTime = mbCreatedTimeDom.split('+')[0].split('，')[1];
    // 社交
    if (profileNode.querySelector('div.widgets') != null) {
      var socialNodes =
          profileNode.querySelector('div.widgets')!.querySelectorAll('a');
      for (var aNode in socialNodes) {
        MemberSocialItem item = MemberSocialItem();
        item.name = aNode.text;
        item.href = aNode.attributes['href']!;
        item.icon =
            Strings.v2exHost + aNode.querySelector('img')!.attributes['src']!;
        item.type = aNode.querySelector('img')!.attributes['alt']!;
        if (item.type == 'GitHub') {
          item.type = 'Github';
        }
        if (item.icon.contains('btc')) {
          item.type = 'Btc';
        }
        socialList.add(item);
      }
    }

    // 简介
    if (profileNode.querySelectorAll('div.cell').length > 1) {
      memberProfile.mbSign =
          profileNode.querySelectorAll('div.cell').last.outerHtml;
    }

    // 主题列表
    var topicNodesBlank = topicsNode.querySelector('div.cell:not(.item)');
    if (topicNodesBlank != null) {
      memberProfile.isShowTopic = false;
    } else {
      var topicNodes = topicsNode.querySelectorAll('div.cell.item');
      if (topicNodes.isEmpty) {
        memberProfile.isEmptyTopic = true;
      } else {
        for (int i = 0;
            i < (topicNodes.length > 3 ? 3 : topicNodes.length);
            i++) {
          MemberTopicItem item = MemberTopicItem();
          var itemNode = topicNodes[i].querySelector('table');
          String topicHref = itemNode!
              .querySelector('span.item_title > a.topic-link')!
              .attributes['href']!;
          item.topicId =
              topicHref.split('#')[0].replaceAll(RegExp(r'[^0-9]'), '');
          item.replyCount =
              topicHref.split('#')[1].replaceAll(RegExp(r'[^0-9]'), '');
          item.topicTitle =
              itemNode.querySelector('span.item_title > a.topic-link')!.text;
          item.time = itemNode.querySelector('span.topic_info > span')!.text;
          item.nodeName =
              itemNode.querySelector('span.topic_info > a.node')!.text;
          item.nodeId = itemNode
              .querySelector('span.topic_info > a.node')!
              .attributes['href']!
              .split('/')[2];
          topicList.add(item);
        }
      }
    }

    // 回复列表
    var dockAreaDom = replysNode.querySelectorAll('div.dock_area');
    if (dockAreaDom.isEmpty) {
      memberProfile.isEmptyReply = true;
    } else {
      var innerDom = replysNode.querySelectorAll('div.reply_content');
      for (int i = 0;
          i < (dockAreaDom.length > 3 ? 3 : dockAreaDom.length);
          i++) {
        MemberReplyItem item = MemberReplyItem();
        item.time = dockAreaDom[i].querySelector('span.fade')!.text;
        item.memberId =
            dockAreaDom[i].querySelectorAll('span.gray > a')[0].text;
        item.nodeName =
            dockAreaDom[i].querySelectorAll('span.gray > a')[1].text;
        item.topicTitle =
            dockAreaDom[i].querySelectorAll('span.gray > a')[2].text;
        item.topicId = dockAreaDom[i]
            .querySelectorAll('span.gray > a')[2]
            .attributes['href']!
            .split('#')[0]
            .replaceAll(RegExp(r'[^0-9]'), '');

        if (i < innerDom.length) {
          item.replyContent = innerDom[i].innerHtml;
        }
        replyList.add(item);
      }
    }

    memberProfile.topicList = topicList;
    memberProfile.replyList = replyList;
    memberProfile.socialList = socialList;
    return memberProfile;
  }

  // 个人中心 获取用户的回复
  static Future<ModelMemberReply> queryMemberReply(
      String memberId, int p) async {
    ModelMemberReply memberReply = ModelMemberReply();
    Response response;
    response = await Request().get('/member/$memberId/replies',
        data: {'p': p}, extra: {'ua': 'pc'});
    var bodyDom = parse(response.data).body;
    var contentDom = bodyDom!.querySelector('#Main > div.box');
    if (contentDom!.querySelector('div.cell > table') != null) {
      memberReply.totalPage = contentDom
          .querySelector('div.cell > table')!
          .querySelectorAll('a')
          .last
          .text;
    }

    var dockAreaDom = contentDom.querySelectorAll('div.dock_area');
    var innerDom = contentDom.querySelectorAll('div.reply_content');
    for (int i = 0; i < dockAreaDom.length; i++) {
      MemberReplyItem item = MemberReplyItem();
      item.time = dockAreaDom[i].querySelector('span.fade')!.text;
      item.memberId = dockAreaDom[i].querySelectorAll('span.gray > a')[0].text;
      item.nodeName = dockAreaDom[i].querySelectorAll('span.gray > a')[1].text;
      item.topicTitle =
          dockAreaDom[i].querySelectorAll('span.gray > a')[2].text;
      item.topicId = dockAreaDom[i]
          .querySelectorAll('span.gray > a')[2]
          .attributes['href']!
          .split('#')[0]
          .replaceAll(RegExp(r'[^0-9]'), '');

      if (i < innerDom.length) {
        item.replyContent = innerDom[i].innerHtml;
      }
      memberReply.replyList.add(item);
    }
    return memberReply;
  }

  // 个人中心 获取用户发布的主题
  static Future<ModelMemberTopic> queryMemberTopic(
      String memberId, int p) async {
    ModelMemberTopic memberTopic = ModelMemberTopic();
    List<MemberTopicItem> topicList = [];
    Response response;
    response = await Request().get('/member/$memberId/topics',
        data: {'p': p}, extra: {'ua': 'pc'});
    var bodyDom = parse(response.data).body;
    var contentDom = bodyDom!.querySelector('#Main');
    // 获取总页数
    if (contentDom!.querySelector('div.box > div.cell:not(.item)') != null) {
      if (contentDom
          .querySelector('div.box > div.cell:not(.item)')!
          .text
          .contains('主题列表被隐藏')) {
        memberTopic.isShow = false;
        return memberTopic;
      }
      memberTopic.totalPage = contentDom.querySelectorAll('a').last.text;
    }
    var cellNode = contentDom.querySelectorAll('div.cell.item');
    for (var aNode in cellNode) {
      MemberTopicItem item = MemberTopicItem();
      var itemNode = aNode.querySelector('table');
      String topicHref = itemNode!
          .querySelector('span.item_title > a.topic-link')!
          .attributes['href']!;

      item.topicId = topicHref.split('#')[0].replaceAll(RegExp(r'[^0-9]'), '');
      item.replyCount =
          topicHref.split('#')[1].replaceAll(RegExp(r'[^0-9]'), '');
      item.topicTitle =
          itemNode.querySelector('span.item_title > a.topic-link')!.text;
      item.time = itemNode.querySelector('span.topic_info > span')!.text;
      item.nodeName = itemNode.querySelector('span.topic_info > a.node')!.text;
      item.nodeId = itemNode
          .querySelector('span.topic_info > a.node')!
          .attributes['href']!
          .split('/')[2];
      topicList.add(item);
    }
    memberTopic.topicList = topicList;
    return memberTopic;
  }

  // 回复主题
  static Future<dynamic> onSubmitReplyTopic(
      String topicId, String once, String replyContent) async {
    SmartDialog.showLoading(msg: '回复中...');
    Options options = Options();
    options.headers = {
      'content-type': 'application/x-www-form-urlencoded',
      'refer': '${Strings.v2exHost}/t/$topicId',
      'origin': Strings.v2exHost
    };
    Response response;
    response = await Request().post('/t/$topicId',
        data: {
          'once': '51524',
          'content': replyContent,
        },
        extra: {'ua': 'mob'},
        options: options);
    SmartDialog.dismiss();
    var bodyDom = parse(response.data).body;
    if (response.statusCode == 302) {
      SmartDialog.showToast('回复成功');
    } else if (response.statusCode == 200) {
      var contentDom = bodyDom!.querySelector('#Wrapper');
      print(contentDom!.text);
      if (contentDom.querySelector('div.content > div.box > div.problem') !=
          null) {
        String responseText = contentDom
            .querySelector('div.content > div.box > div.problem')!
            .text;
        SmartDialog.show(
          useSystem: true,
          animationType: SmartAnimationType.centerFade_otherSlide,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('系统提示'),
              content: Text(responseText),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('重新输入'))
              ],
            );
          },
        );
      }
      SmartDialog.showToast('回复失败了');
    }
    return bodyDom;
  }

  // 消息提醒
  static Future<MemberNoticeModel> queryNotice(int p) async {
    MemberNoticeModel memberNotices = MemberNoticeModel();
    List<MemberNoticeItem> noticeList = [];
    Response response;
    response = await Request().get(
      '/notifications',
      data: {'p': p},
      extra: {'ua': 'pc'},
    );
    // log(parse(response.data).body!.innerHtml);
    var tree = ETree.fromString(response.data);
    var bodyDom = parse(response.data).body;
    var mainDom = bodyDom!.querySelector('#notifications');
    var noticeCells = mainDom!.children;
    var mainNode = tree.xpath("//*[@id='Main']/div[@class='box']");
    // 总回复数
    memberNotices.totalCount = int.parse(mainNode![0]
        .xpath("/div[@class='header']/div/strong/text()")![0]
        .name!);
    // 总页数
    memberNotices.totalPage = int.parse(mainNode[0]
        .xpath("/div[@class='cell']/table/tr/td/input")!
        .first
        .attributes['max']);
    for (var i = 0; i < noticeCells.length; i++) {
      var aNode = noticeCells[i];
      MemberNoticeItem noticeItem = MemberNoticeItem();
      noticeItem.memberAvatar =
          aNode.querySelector('tr>td>a>img')!.attributes['src']!;
      noticeItem.memberId =
          aNode.querySelector('tr>td>a>img')!.attributes['alt']!;

      var td2Node = aNode.querySelectorAll('tr>td')[1];

      noticeItem.topicId = td2Node
          .querySelectorAll('span.fade>a')[1]
          .attributes['href']!
          .split('/')[2]
          .split('#')[0];
      noticeItem.topicTitle = td2Node.querySelectorAll('span.fade>a')[1].text;
      noticeItem.topicTitleHtml =
          td2Node.querySelector('span.fade')!.innerHtml;

      noticeItem.replyContent = '';
      if (td2Node.querySelector('div.payload') != null) {
        noticeItem.replyContentHtml =
            td2Node.querySelector('div.payload')!.innerHtml;
      }else{
        noticeItem.replyContentHtml = null;
      }

      noticeItem.replyTime =
          td2Node.querySelector('span.snow')!.text.replaceAll('+08:00', '');
      var delNum = td2Node
          .querySelector('a.node')!
          .attributes['onclick']!
          .replaceAll(RegExp(r"[deleteNotification( | )]"), '');
      noticeItem.delIdOne = delNum.split(',')[0];
      noticeItem.delIdTwo = delNum.split(',')[1];
      noticeList.add(noticeItem);
    }
    memberNotices.noticeList = noticeList;
    return memberNotices;
  }
}
