import 'dart:async';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_v2ex/models/web/model_topic_follow.dart';
import 'package:flutter_v2ex/utils/event_bus.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:flutter_v2ex/http/init.dart';
import 'package:html/dom.dart'
    as dom; // Contains DOM related classes for extracting data from elements
import 'package:html/parser.dart'; // Contains HTML parsers to generate a Document object
import 'package:flutter_v2ex/package/xpath/xpath.dart';

import 'package:flutter_v2ex/models/web/item_tab_topic.dart'; // 首页tab主题列表
import 'package:flutter_v2ex/models/web/model_topic_fav.dart'; // 收藏的主题
import 'package:flutter_v2ex/models/web/model_node_fav.dart';
import 'package:flutter_v2ex/models/web/model_member_reply.dart';
import 'package:flutter_v2ex/models/web/item_member_reply.dart';
import 'package:flutter_v2ex/models/web/model_member_topic.dart';
import 'package:flutter_v2ex/models/web/item_member_topic.dart';
import 'package:flutter_v2ex/models/web/item_member_social.dart';
import 'package:flutter_v2ex/models/web/model_member_profile.dart';
import 'package:flutter_v2ex/models/web/model_member_notice.dart';
import 'package:flutter_v2ex/models/web/item_member_notice.dart';

import 'package:flutter_v2ex/utils/string.dart';
import 'package:flutter_v2ex/utils/storage.dart';

class UserWebApi {
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

    var menuBodyNode =
        bodyDom.querySelector("div[id='Top'] > div > div.site-nav > div.tools");
    var loginOutNode = menuBodyNode!.querySelectorAll('a').last;
    if (loginOutNode.attributes['onclick'] != null) {
      // 登录状态
      var loginOutHref = loginOutNode.attributes['onclick']!;
      RegExp regExp = RegExp(r'\d{3,}');
      Iterable<Match> matches = regExp.allMatches(loginOutHref);
      for (Match m in matches) {
        GStorage().setOnce(int.parse(m.group(0)!));
      }
    }
    // 头像、昵称、在线状态、加入时间、关注状态
    var profileCellNode = profileNode.querySelector('div.cell > table');
    memberProfile.mbAvatar =
        profileCellNode!.querySelector('img')!.attributes['src']!;
    memberProfile.memberId = memberId;
    if (profileCellNode.querySelector('tr>td>strong.online') != null) {
      memberProfile.isOnline = true;
    }
    print('line 1189: ${memberProfile.isOnline}');
    if (profileNode.querySelectorAll('input[type=button]').isNotEmpty) {
      var buttonDom = profileNode.querySelectorAll('input[type=button]');
      var followBtn = buttonDom[0];
      memberProfile.isFollow =
          followBtn.attributes['value'] == '取消特别关注' ? true : false;
      print('line 1195: ${memberProfile.isFollow}');

      var blockBtn = buttonDom[1];
      // true 已屏蔽
      memberProfile.isBlock =
          blockBtn.attributes['value'] == 'Unblock' ? true : false;
      print('line 1199: ${blockBtn.attributes['value']}');
    }
    // else {
    //   memberProfile.isOwner = false;
    // }

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
          item.topicId = topicHref.split('#')[0].replaceAll(RegExp(r'\D'), '');
          item.replyCount =
              topicHref.split('#')[1].replaceAll(RegExp(r'\D'), '');
          item.topicTitle =
              itemNode.querySelector('span.item_title > a.topic-link')!.text;
          item.time = itemNode.querySelector('span.topic_info > span')!.text;
          item.nodeName =
              itemNode.querySelector('span.topic_info > a.node')!.text;
          item.nodeId = itemNode
              .querySelector('span.topic_info > a.node')!
              .attributes['href']!
              .split('/')[2];
          item.lastReplyTime = item.time;
          item.avatar = memberProfile.mbAvatar;
          item.memberId = memberProfile.memberId;
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
            .replaceAll(RegExp(r'\D'), '');

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

  // 获取收藏的主题
  static Future<FavTopicModel> getFavTopics(int p) async {
    FavTopicModel favTopicDetail = FavTopicModel();
    List<TabTopicItem> topicList = [];

    Response response;
    response = await Request().get(
      '/my/topics',
      data: {'p': p},
      extra: {
        'ua': 'mobMoto',
      },
    );
    var document = parse(response.data);
    var mainBox = document.querySelector('#Main div.box:not(.box-title)');
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
        item.topicId = aNode
            .querySelector('td:nth-child(5) > span.item_title > a')!
            .attributes['href']!
            .replaceAll("/t/", "")
            .split("#")[0];
      }
      if (aNode.querySelector('tr > td:last-child > a') != null) {
        String? topicUrl = aNode
            .querySelector('tr > td:last-child > a')!
            .attributes['href']; // 得到是 /t/522540#reply17
        item.replyCount = int.parse(topicUrl!
            .replaceAll("/t/", "")
            .split("#")[1]
            .replaceAll(RegExp(r'\D'), ''));
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
    response = await Request().get('/my/nodes', extra: {'ua': 'pc'});
    var bodyDom = parse(response.data).body;
    var nodeListWrap = bodyDom!.querySelector('div[id="my-nodes"]');
    List<dom.Element> nodeListDom = [];
    if (nodeListWrap != null) {
      nodeListDom = nodeListWrap.querySelectorAll('a');
      for (var i in nodeListDom) {
        NodeFavModel item = NodeFavModel();
        if (i.querySelector('img') != null) {
          item.nodeCover = i.querySelector('img')!.attributes['src']!;
          if (item.nodeCover.contains('/static')) {
            item.nodeCover = '';
          }
          item.nodeId = i.attributes['href']!.split('/')[2];
        }
        item.nodeName = i.querySelector('span.fav-node-name')!.text;
        item.topicCount = i.querySelector('span.f12.fade')!.text;
        favNodeList.add(item);
      }
    }

    var noticeNode =
        bodyDom.querySelector('#Rightbar>div.box>div.cell.flex-one-row');
    if (noticeNode != null) {
      // 未读消息
      var unRead =
          noticeNode.querySelector('a')!.text.replaceAll(RegExp(r'\D'), '');
      if (int.parse(unRead) > 0) {
        eventBus.emit('unRead', int.parse(unRead));
      }
    }
    return favNodeList;
  }

  // 关注用户
  static Future<bool> onFollowMember(String followId, bool followStatus) async {
    SmartDialog.showLoading();
    int once = GStorage().getOnce();
    var url = followStatus ? '/unfollow/$followId' : '/follow/$followId';
    final Response response = await Request().get(url, data: {'once': once});
    SmartDialog.dismiss();
    // if(response.statusCode == 302){
    // 操作成功
    return true;
    // }else{
    //   return false;
    // }
  }

  // 屏蔽用户
  static Future<bool> onBlockMember(String blockId, bool blockStatus) async {
    SmartDialog.showLoading();
    int once = GStorage().getOnce();
    var url = blockStatus ? '/unblock/$blockId' : '/block/$blockId';
    Response response = await Request().get(url, data: {'once': once});
    SmartDialog.dismiss();
    // if(response.statusCode == 302){
    // 操作成功
    return true;
    // }else{
    //   return false;
    // }
  }

  // 个人中心 获取用户的回复
  static Future<ModelMemberReply> queryMemberReply(
      String memberId, int p) async {
    ModelMemberReply memberReply = ModelMemberReply();
    Response response;
    response = await Request()
        .get('/member/$memberId/replies', data: {'p': p}, extra: {'ua': 'pc'});
    var bodyDom = parse(response.data).body;
    var contentDom = bodyDom!.querySelector('#Main > div.box');
    if (contentDom!.querySelector('div.cell > table') != null) {
      memberReply.totalPage = int.parse(contentDom
          .querySelector('div.cell > table')!
          .querySelectorAll('a')
          .last
          .text);
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
          .replaceAll(RegExp(r'\D'), '');

      if (i < innerDom.length) {
        item.replyContent = innerDom[i].innerHtml;
      }
      memberReply.replyList.add(item);
    }
    memberReply.replyCount = int.parse(contentDom
        .querySelector('div.header > div')!
        .innerHtml
        .replaceAll(RegExp(r'\D'), ''));
    return memberReply;
  }

  // 个人中心 获取用户发布的主题
  static Future<ModelMemberTopic> queryMemberTopic(
      String memberId, int p) async {
    ModelMemberTopic memberTopic = ModelMemberTopic();
    List<MemberTopicItem> topicList = [];
    Response response;
    response = await Request()
        .get('/member/$memberId/topics', data: {'p': p}, extra: {'ua': 'pc'});
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

      item.topicId = topicHref.split('#')[0].replaceAll(RegExp(r'\D'), '');
      item.replyCount = topicHref.split('#')[1].replaceAll(RegExp(r'\D'), '');
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
    memberTopic.topicCount = int.parse(contentDom
        .querySelector('div.header > div')!
        .innerHtml
        .replaceAll(RegExp(r'\D'), ''));
    return memberTopic;
  }

  // 关注的用户&话题  TODO ua为mob时会503 pc正常
  static Future getFollowTopics(int p) async {
    FollowTopicModel followTopicModel = FollowTopicModel();
    List<TabTopicItem> topicList = [];

    Response response = await Request()
        .get('/my/following', data: {'p': p}, extra: {'ua': 'mobMoto'});
    var document = parse(response.data);
    var mainBox = document.querySelector('#Main > div.box:not(.box-title)');
    var totalPageNode =
        mainBox!.querySelector('div.cell:not(.tab-alt-container):not(.item)');
    if (totalPageNode != null) {
      if (totalPageNode.querySelectorAll('a.page_normal').isNotEmpty) {
        followTopicModel.totalPage = int.parse(
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
        item.topicId = aNode
            .querySelector('td:nth-child(5) > span.item_title > a')!
            .attributes['href']!
            .replaceAll("/t/", "")
            .split("#")[0];
      }
      if (aNode.querySelector('tr > td:last-child > a') != null) {
        String? topicUrl = aNode
            .querySelector('tr > td:last-child > a')!
            .attributes['href']; // 得到是 /t/522540#reply17
        item.replyCount = int.parse(topicUrl!
            .replaceAll("/t/", "")
            .split("#")[1]
            .replaceAll(RegExp(r'\D'), ''));
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
    followTopicModel.topicList = topicList;

    return followTopicModel;
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
    if (mainNode[0].xpath("/div[@class='cell']/table/tr/td/input") != null) {
      memberNotices.totalPage = int.parse(mainNode[0]
          .xpath("/div[@class='cell']/table/tr/td/input")!
          .first
          .attributes['max']);
    }

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
      noticeItem.topicTitleHtml = td2Node.querySelector('span.fade')!.innerHtml;
      var noticeTypeStr = td2Node.querySelector('span.fade')!.nodes[1];
      if (noticeItem.topicTitleHtml != null) {
        // print(noticeItem.topicTitleHtml.querySelectorAll('a'));
        noticeItem.topicHref = td2Node
            .querySelector('span.fade')!
            .querySelectorAll('a')[1]
            .attributes['href']!;
      }
      if (noticeTypeStr.text!.contains('在回复')) {
        noticeItem.noticeType = NoticeType.reply;
      }
      if (noticeTypeStr.text!.contains('收藏了你发布的主题')) {
        noticeItem.noticeType = NoticeType.favTopic;
      }
      if (noticeTypeStr.text!.contains('感谢了你发布的主题')) {
        noticeItem.noticeType = NoticeType.thanksTopic;
      }
      if (noticeTypeStr.text!.contains('感谢了你在主题')) {
        noticeItem.noticeType = NoticeType.thanksReply;
      }

      if (td2Node.querySelector('div.payload') != null) {
        noticeItem.replyContent =
            td2Node.querySelector('div.payload')!.text.trim();
        noticeItem.replyContentHtml =
            td2Node.querySelector('div.payload')!.innerHtml;
      } else {
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

  // 删除消息
  static Future<bool> onDelNotice(String noticeId, String once) async {
    // https://www.v2ex.com/delete/notification/19134720?once=22730
    Options options = Options();
    // options.contentType = Headers.textPlainContentType;
    options.headers = {
      // 必须字段
      'Referer': '${Strings.v2exHost}/notifications',
      'Origin': Strings.v2exHost,
      'user-agent':
          'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1'
    };
    FormData formData = FormData.fromMap({'once': once});
    var res = await Request().post('/delete/notification/$noticeId?once=$once',
        data: formData, options: options);
    log(res.data);
    return true;
  }
}
