import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// import 'package:flutter_v2ex/http/init.dart';
import 'package:flutter_v2ex/http/init3.dart';
import 'package:html/dom.dart'
    as dom; // Contains DOM related classes for extracting data from elements
// import 'package:html/dom.dart';
import 'package:html/parser.dart'; // Contains HTML parsers to generate a Document object
// import 'package:xpath/xpath.dart';
import 'package:flutter_v2ex/package/xpath/xpath.dart';
// import 'package:html/dom_parsing.dart';
// import 'package:html/html_escape.dart';

import 'package:flutter_v2ex/models/web/item_tab_topic.dart';
import 'package:flutter_v2ex/models/web/model_topic_detail.dart';
import 'package:flutter_v2ex/models/web/item_topic_reply.dart';
import 'package:flutter_v2ex/models/web/item_topic_subtle.dart';
import 'package:flutter_v2ex/models/web/model_node_list.dart';
// import 'package:flutter_v2ex/models/web/item_node_list.dart';

import 'package:dio_http_cache/dio_http_cache.dart';
import '/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';

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
        response = await Request().get(
          '/recent',
          data: {'p': p},
          extra: {'ua': 'mob', 'channel': 'web'},
        );
        break;
      case 'go':
        // response = await Request().get(
        //   '/go/$id',
        //   extra: {'ua': 'mob', 'channel': 'web'},
        // );
        return await getTopicsByNodeKey(id, p).then((value) => value.topicList);
      // break;
      default:
        response = await Request().get(
          '/',
          data: {'tab': 'all'},
          extra: {'ua': 'mob', 'channel': 'web'},
        );
        break;
    }
    var tree = ETree.fromString(response.data);
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
      if (aNode.xpath("/table/tr/td[4]/a/text()") != null) {
        item.replyCount = aNode.xpath("/table/tr/td[4]/a/text()")![0].name!;
        item.lastReplyTime = aNode
            .xpath("/table/tr/td[3]/span[3]/text()[1]")![0]
            .name!
            .split(' &nbsp;')[0]
            .replaceAll("/t/", "");
        if (aNode.xpath("/table/tr/td[3]/span[3]/strong/a/text()") != null) {
          item.lastReplyMId =
              aNode.xpath("/table/tr/td[3]/span[3]/strong/a/text()")![0].name!;
        }
      }
      item.topicTitle = aNode
          .xpath("/table/tr/td[3]/span[2]/a/text()")![0]
          .name!
          .replaceAll('&quot;', '')
          .replaceAll('&amp;', '&')
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>');

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

  // 获取节点下的主题
  static Future<NodeListModel> getTopicsByNodeKey(String nodeKey, int p) async {
    print('getTopicsByNodeKey');
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
    var mainBox = document.querySelector('#Main');
    var mainHeader = mainBox!.querySelector('div.node-header');
    // 主题总数
    detailModel.topicCount = mainHeader!.querySelector('strong')!.text;
    // 节点描述
    detailModel.nodeIntro = mainHeader.querySelector('div.intro')!.text;
    // 节点收藏状态
    if (mainHeader.querySelector('div.cell_ops') != null) {
      detailModel.favorite =
          !mainHeader.querySelector('div.cell_ops')!.text.contains('取消');
    }
    // 总页数
    // 主题
    var topicEle =
        document.querySelector('#TopicsNode')!.querySelectorAll('div.cell');
    // var boxChildren = document.querySelector('#Main > div > div:nth-child(3)');
    // var cellBoxChildren = boxChildren!.querySelectorAll('div.cell');

    // if (cellBoxChildren[0].className == 'cell tab-alt-container') {
    //   cellBoxChildren.removeAt(0);
    // }

    for (var aNode in topicEle) {
      var item = TabTopicItem();

      //  头像 昵称
      if (aNode.querySelector('td > a > img') != null) {
        item.avatar = aNode.querySelector('td > a > img')!.attributes['src']!;
        item.memberId = aNode.querySelector('td > a > img')!.attributes['alt']!;
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
        item.replyCount = topicUrl
            .replaceAll("/t/", "")
            .split("#")[1]
            .replaceAll(RegExp(r'[^0-9]'), '');
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
    detailModel.topicList = topics;
    return detailModel;
  }

  // 获取收藏的主题
  static Future<List<TabTopicItem>> getFavTopics(int p) async {
    var topics = <TabTopicItem>[];
    Response response;
    response = await Request().get(
      '/my/topics',
      extra: {'ua': 'pc', 'channel': 'web'},
    );
    var document = parse(response.data);
    var mainBox = document.querySelector('#Main > div > div:nth-child(5)');
    // print('line 220:' + mainBox!.text);
    var cellBox = mainBox!.querySelectorAll('div.cell');
    print('line 222:${cellBox.length}');
    return topics;
  }

  // 获取帖子详情及下面的评论信息 [html 解析的] todo 关注 html 库 nth-child
  static Future<TopicDetailModel> getTopicDetail(String topicId, int p) async {
    // ignore: avoid_print
    print('line 228: 在请求第$p页面数据');
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
      detailModel.token = collect.split('?t=')[1];
      detailModel.isFavorite = collect.startsWith('/unfavorite');
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
        replyItem.floorNumber = aNode
            .querySelector('$replyTrQuery > td:nth-child(5) > div.fr > span')!
            .text;
        replyItem.contentRendered = aNode
            .querySelector(
                '$replyTrQuery > td:nth-child(5) > div.reply_content')!
            .innerHtml;
        replyItem.content = aNode
            .querySelector(
                '$replyTrQuery > td:nth-child(5) > div.reply_content')!
            .text;
        replyItem.replyId = aNode.attributes["id"]!.substring(2);
        replies.add(replyItem);
      }
    }
    detailModel.replyList = replies;
    return detailModel;
  }
}
