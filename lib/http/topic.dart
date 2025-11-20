import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart' as dom;
import 'package:flutter/material.dart';
import 'package:flutter_v2ex/http/init.dart';
import 'package:flutter_v2ex/utils/utils.dart';
import 'package:flutter_v2ex/utils/string.dart'; // 常量
import 'package:flutter_v2ex/utils/storage.dart'; // 本地存储
// import 'package:dio_http_cache/dio_http_cache.dart'; // dio缓存
import 'package:flutter_v2ex/models/web/item_tab_topic.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart'; // 弹窗
import 'package:flutter_v2ex/models/web/model_topic_detail.dart'; // 主题详情
import 'package:flutter_v2ex/models/web/item_topic_reply.dart'; // 主题回复
import 'package:flutter_v2ex/models/web/item_topic_subtle.dart'; // 主题附言

class TopicWebApi {
  // 获取帖子详情及下面的评论信息
  static Future<TopicDetailModel> getTopicDetail(String topicId, int p) async {
    TopicDetailModel detailModel = TopicDetailModel();
    List<TopicSubtleItem> subtleList = []; // 附言
    List<ReplyItem> replies = [];
    var response = await Request().get(
      "/t/$topicId",
      data: {'p': p},
      // cacheOptions:
      //     buildCacheOptions(const Duration(days: 4), forceRefresh: true),
      extra: {'ua': 'mob'},
    );
    // Use html parser and query selector
    var document = parse(response.data);
    detailModel.topicId = topicId;

    if (response.redirects.isNotEmpty ||
        document.querySelector('#Main > div.box > div.message') != null) {
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
                  // TODO
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

    void updateOnceFromMenu() {
      final menuCells = document.querySelectorAll('#menu-body > div.cell');
      if (menuCells.isEmpty) {
        return;
      }
      final href = menuCells.last.querySelector('a')?.attributes['href'];
      if (href == null || !href.contains('once=')) {
        return;
      }
      final onceStr = href.split('once=').last;
      final onceValue = int.tryParse(onceStr);
      if (onceValue != null) {
        GStorage().setOnce(onceValue);
      }
    }

    updateOnceFromMenu();

    final dom.Element wrapperEl = document.querySelector('#Wrapper')!;
    final dom.Element wrapperContent = wrapperEl.querySelector('div')!;
    final dom.Element mainBox = wrapperContent.children.first;

    /// 标题、头像、昵称、发布时间、浏览量
    final dom.Element headerEl = mainBox.querySelector('.header')!;

    final dom.Element? innerEl = mainBox.querySelector('.inner');

    /// 头像
    detailModel.avatar =
        headerEl.querySelector('div.fr > a > img')!.attributes["src"]!;

    /// 昵称
    detailModel.createdId = headerEl.querySelector('small > a')!.text;

    /// 节点id 和 节点名称
    final dom.Element nodeAnchor = headerEl.querySelector('a[href^="/go/"]')!;
    detailModel.nodeId = nodeAnchor.attributes["href"]!.replaceAll('/go/', '');
    detailModel.nodeName = nodeAnchor.text;

    ///  at 9 小时 26 分钟前，1608 次点击
    var pureStr = headerEl.querySelector('small')!.text.split('at ')[1];
    List pureStrList = pureStr.split('·');
    detailModel.createdTime = pureStrList[0].replaceFirst(' +08:00', '');
    detailModel.visitorCount = pureStrList.length >= 2
        ? pureStrList[1].replaceAll(RegExp(r'\D'), '')
        : '';

    /// APPEND EIDT MOVE
    var opActionNode = headerEl.querySelector('small');
    if (opActionNode!.querySelector('a.op') != null) {
      var opNodes = opActionNode.querySelectorAll('a.op');
      for (var i in opNodes) {
        if (i.text.contains('APPEND')) {
          detailModel.isAPPEND = true;
        }
        if (i.text.contains('EDIT')) {
          detailModel.isEDIT = true;
        }
        if (i.text.contains('MOVE')) {
          detailModel.isMOVE = true;
        }
      }
    }
    detailModel.topicTitle = headerEl.querySelector('h1')!.text;

    // [email_protected] 转码回到正确的邮件字符串
    List<dom.Element> aRootNode =
        document.querySelectorAll("a[class='__cf_email__']");
    List<dom.Element> bRootNode =
        document.querySelectorAll("span[class='__cf_email__']");
    var emailNode = aRootNode.isNotEmpty
        ? aRootNode
        : bRootNode.isNotEmpty
            ? bRootNode
            : [];
    if (emailNode.isNotEmpty) {
      for (var aNode in emailNode) {
        String encodedCf = aNode.attributes["data-cfemail"].toString();
        var newEl = document.createElement('a');
        newEl.innerHtml = Utils.cfDecodeEmail(encodedCf);
        newEl.attributes['href'] = 'mailto:${Utils.cfDecodeEmail(encodedCf)}';
        aNode.replaceWith(newEl);
      }
    }

    // 判断是否有正文
    final dom.Element? contentDom = mainBox.querySelector('div.cell > div');
    if (contentDom != null) {
      detailModel.content = contentDom.text;
      detailModel.contentRendered = Utils.linkMatch(contentDom);
      var imgNodes = contentDom.querySelectorAll('img');
      if (imgNodes.isNotEmpty) {
        detailModel.imgCount += imgNodes.length;
        detailModel.imgList = [];
        for (var imgNode in imgNodes) {
          detailModel.imgList.add(Utils().imageUrl(imgNode.attributes['src']!));
        }
      }
    }

    // 附言
    List<dom.Element> appendNodes = mainBox.querySelectorAll("div.subtle");
    if (appendNodes.isNotEmpty) {
      for (var node in appendNodes) {
        TopicSubtleItem subtleItem = TopicSubtleItem();
        subtleItem.fade = node
            .querySelector('span.fade')!
            .text
            .replaceFirst(' +08:00', ''); // 时间（去除+ 08:00）;
        var topicContentDom = node.querySelector('div.topic_content')!;
        subtleItem.content = Utils.linkMatch(topicContentDom);
        var subImgNodes = topicContentDom.querySelectorAll('img');
        if (subImgNodes.isNotEmpty) {
          detailModel.imgCount += subImgNodes.length;
          for (var subImgNode in subImgNodes) {
            detailModel.imgList
                .add(Utils().imageUrl(subImgNode.attributes['src']!));
          }
        }
        subtleList.add(subtleItem);
      }
    }
    detailModel.subtleList = subtleList;

    /// 收藏、感谢、屏蔽区域 未登录为null
    var opElement = innerEl?.querySelector("div > a.op");
    if (opElement != null) {
      /// 收藏状态  isFavorite:true 已收藏
      String collect = opElement.attributes["href"]!;
      detailModel.isFavorite = collect.startsWith('/unfavorite');

      // once
      updateOnceFromMenu();

      /// 收藏人数
      var spanElement = innerEl?.querySelector("div > span");
      if (spanElement != null) {
        final regex = RegExp(r'(\d+)');
        final match = regex.firstMatch(spanElement.text);
        if (match != null) {
          detailModel.favoriteCount = int.parse(match.group(1)!);
        }
      }

      /// 是否感谢 isThank: true已感谢
      detailModel.isThank =
          innerEl?.querySelector("#topic_thank > span") != null;
    }

    /// 判断是否有评论
    if (document.querySelector('#no-comments-yet') == null) {
      /// 回复数 发布时间 评论
      dom.Element replyBoxDom;

      /// tag标签判断：过滤掉分隔符
      final wrapperChildren = wrapperContent.children
          .where((element) => !(element.localName == 'div' &&
              (element.classes.contains('sep') ||
                  element.id.contains('topic-tip-box'))))
          .toList();
      // var isHasTag = wrapperChildren.length > 2 &&
      //     wrapperChildren[2].querySelector('a.tag') != null;

      replyBoxDom = wrapperChildren[2];
      final replyInfoCell = replyBoxDom.querySelector('div.cell');
      if (replyInfoCell != null) {
        final replyInfoSpan = replyInfoCell.querySelector('span');
        if (replyInfoSpan != null) {
          detailModel.replyCount = int.parse(replyInfoSpan.text
              .replaceAll(RegExp(r"\s+"), "")
              .split('条回复')[0]);
        }

        int? extractTotalPage(dom.Element? scope) {
          if (scope == null) {
            return null;
          }
          int? maxPage;
          final paginationNodes = scope
              .querySelectorAll('a.page_normal, a.page_current, span.page_current');
          if (paginationNodes.isEmpty) {
            return null;
          }
          for (final element in paginationNodes) {
            final value = int.tryParse(element.text.trim());
            if (value == null) {
              continue;
            }
            if (maxPage == null || value > maxPage) {
              maxPage = value;
            }
          }
          return maxPage;
        }

        int? totalPageFromPagination = extractTotalPage(replyInfoCell);

        if (totalPageFromPagination == null) {
          final pageNodes = replyInfoCell.querySelectorAll('div.fr.fade');
          if (pageNodes.isNotEmpty) {
            totalPageFromPagination = extractTotalPage(pageNodes.last);
          }
        }

        if (totalPageFromPagination != null) {
          detailModel.totalPage = totalPageFromPagination;
        }
      }

      if (detailModel.totalPage == 1 && detailModel.replyCount > 100) {
        detailModel.totalPage = ((detailModel.replyCount - 1) ~/ 100) + 1;
      }

      /// 回复楼层
      /// first td user avatar
      /// third td main content
      List<dom.Element> rootNode =
          replyBoxDom.querySelectorAll(".box > div[id].cell");
      var replyTrQuery = 'table > tbody > tr';
      for (var aNode in rootNode) {
        ReplyItem replyItem = ReplyItem();
        final dom.Element replyItemEl = aNode.querySelector(replyTrQuery)!;
        final dom.Element mainContentEl =
            replyItemEl.querySelector('td:nth-child(5)')!;

        /// 用户资料
        replyItem.avatar = Uri.encodeFull(replyItemEl
            .querySelector('td:nth-child(1) > img')!
            .attributes["src"]!);
        replyItem.userName = mainContentEl.querySelector('strong > a')!.text;
        var badgeElement =
            mainContentEl.querySelector('div.badges > div.badge');
        String? status = badgeElement?.text;
        replyItem.isMod = status == 'MOD';
        replyItem.isOwner = status == 'OP';

        /// 回复时间
        replyItem.lastReplyTime = mainContentEl
            .querySelector('span.fade.small')!
            .text
            .replaceFirst(' +08:00', ''); // 时间（去除+ 08:00）和平台（Android/iPhone）

        /// 平台
        if (replyItem.lastReplyTime.contains('via')) {
          var platform = replyItem.lastReplyTime
              .split('via')[1]
              .replaceAll(RegExp(r"\s+"), "");
          replyItem.lastReplyTime =
              replyItem.lastReplyTime.split('via')[0].replaceAll("/t/", "");
          replyItem.platform = platform;
        }

        /// 感谢数 和 状态
        var smallFade = mainContentEl.querySelector("span[class='small fade']");
        if (smallFade != null) {
          replyItem.favorites = int.parse(smallFade.text.split(" ")[1]);
          if (mainContentEl.querySelector("div.fr > div.thanked") != null) {
            replyItem.favoritesStatus = true;
          }
        }

        /// 楼层
        replyItem.floorNumber =
            int.parse(mainContentEl.querySelector('div.fr > span')!.text);

        /// 评论内容
        var contentDom = mainContentEl.querySelector('div.reply_content')!;
        replyItem.contentRendered = Utils.linkMatch(contentDom);
        replyItem.content = contentDom.text;
        var replyImgs = contentDom.querySelectorAll('img');
        if (replyImgs.isNotEmpty) {
          for (var imgNode in replyImgs) {
            replyItem.imgList.add(Utils().imageUrl(imgNode.attributes['src']!));
          }
        }
        var replyMemberNodes = contentDom.querySelectorAll('a');
        if (replyMemberNodes.isNotEmpty) {
          for (var aNode in replyMemberNodes) {
            if (aNode.attributes['href']!.startsWith('/member')) {
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

  // 感谢主题
  static Future thankTopic(String topicId) async {
    int once = GStorage().getOnce();
    SmartDialog.showLoading(msg: '表示感谢ing');
    try {
      var response = await Request().post("/thank/topic/$topicId?once=$once");
      // ua mob
      var data = jsonDecode(response.toString());
      SmartDialog.dismiss();
      bool responseStatus = data['success'];
      if (responseStatus) {
        SmartDialog.showToast('操作成功');
      } else {
        SmartDialog.showToast(data['message']);
      }
      if (data['once'] != null) {
        int onceR = data['once'];
        GStorage().setOnce(onceR);
      }
      // 操作成功
      return responseStatus;
    } on DioException catch (e) {
      SmartDialog.dismiss();
      SmartDialog.showToast(e.message!);
    }
  }

  // 收藏主题
  static Future<bool> favoriteTopic(bool isFavorite, String topicId) async {
    int once = GStorage().getOnce();
    SmartDialog.showLoading(msg: isFavorite ? '取消中...' : '收藏中...');
    String url = isFavorite
        ? ("/unfavorite/topic/$topicId?once=$once")
        : ("/favorite/topic/$topicId?once=$once");
    var response = await Request().get(url, extra: {'ua': 'mob'});
    SmartDialog.dismiss();
    // 返回的pc端ua
    if (response.statusCode == 200 || response.statusCode == 302) {
      if (response.statusCode == 200) {
        var document = parse(response.data);
        var menuBodyNode = document
            .querySelector("div[id='Top'] > div > div.site-nav > div.tools");
        var loginOutNode = menuBodyNode!.querySelectorAll('a').last;
        var loginOutHref = loginOutNode.attributes['onclick']!;
        RegExp regExp = RegExp(r'\d{3,}');
        Iterable<Match> matches = regExp.allMatches(loginOutHref);
        for (Match m in matches) {
          GStorage().setOnce(int.parse(m.group(0)!));
        }
      }
      // 操作成功
      return true;
    }
    return false;
  }

  // 举报主题
  static Future<bool> onReportTopic(String topicId) async {
    SmartDialog.showLoading();
    int once = GStorage().getOnce();
    Response response;
    response =
        await Request().get('/report/topic/$topicId', data: {'once': once});
    SmartDialog.dismiss();
    if (response.statusCode == 200) {
      // 操作成功
      return true;
    } else {
      return false;
    }
  }

  // 屏蔽主题 完成后返回上一页
  static Future<bool> onIgnoreTopic(String topicId) async {
    SmartDialog.showLoading();
    int once = GStorage().getOnce();
    Response response;
    response =
        await Request().get('/ignore/topic/$topicId', data: {'once': once});
    SmartDialog.dismiss();
    if (response.statusCode == 200) {
      // 操作成功
      return true;
    } else {
      return false;
    }
  }

  // 历史浏览主题
  static Future<List<TabTopicItem>> getTopicsHistory() async {
    var topics = <TabTopicItem>[];
    Response response;
    try {
      response = await Request().get(
        '/',
        extra: {'ua': 'pc'},
      );
    } catch (err) {
      rethrow;
    }
    var document = parse(response.data);
    var historyDom = document.body!.querySelector('div[id="my-recent-topics"]');
    if (historyDom != null) {
      var topicNodes =
          historyDom.querySelectorAll('div.cell:not(.flex-one-row)');
      if (topicNodes.isNotEmpty) {
        for (var aNode in topicNodes) {
          var item = TabTopicItem();
          item.memberId = aNode.querySelector('img')!.attributes['alt']!;
          item.avatar = aNode.querySelector('img')!.attributes['src']!;
          item.topicId = aNode
              .querySelectorAll('a')
              .last
              .attributes['href']!
              .replaceAll(RegExp(r'\D'), '');
          item.topicTitle = aNode.querySelectorAll('a').last.text;
          topics.add(item);
        }
      }
    }
    return topics;
  }

  // 回复主题
  static Future<String> onSubmitReplyTopic(
      String topicId, String replyContent, int totalPage) async {
    SmartDialog.showLoading(msg: '回复中...');
    int once = GStorage().getOnce();
    Options options = Options();
    options.contentType = Headers.formUrlEncodedContentType;
    options.headers = {
      // 'content-type': 'application/x-www-form-urlencoded',
      'refer': '${Strings.v2exHost}/t/$topicId',
      'origin': Strings.v2exHost
    };
    FormData formData =
        FormData.fromMap({'once': once, 'content': replyContent});
    Response response;
    response = await Request().post('/t/$topicId',
        data: formData, extra: {'ua': 'mob'}, options: options);
    SmartDialog.dismiss();
    var bodyDom = parse(response.data).body;
    if (response.statusCode == 302) {
      SmartDialog.showToast('回复成功');
      // 获取最后一页最近一条
      SmartDialog.showLoading(msg: '获取最新回复');
      var replyDetail = await getTopicDetail(topicId, totalPage + 1);
      var lastReply = replyDetail.replyList.reversed.firstWhere(
          (item) => item.userName == GStorage().getUserInfo()['userName']);
      SmartDialog.dismiss();
      GStorage().setReplyItem(lastReply);
      return 'true';
    } else if (response.statusCode == 200) {
      String responseText = '回复失败了';
      var contentDom = bodyDom!.querySelector('#Main');
      if (contentDom!.querySelector('div.problem') != null) {
        responseText = contentDom.querySelector('div.problem')!.text;
      }
      return responseText;
    } else {
      SmartDialog.dismiss();
      return 'false';
    }
  }
}
