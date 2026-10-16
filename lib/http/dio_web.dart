// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_v2ex/service/read.dart';
import 'package:flutter_v2ex/utils/event_bus.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_v2ex/http/init.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:flutter_v2ex/package/xpath/xpath.dart';
import 'package:flutter_v2ex/models/web/item_tab_topic.dart'; // 首页tab主题列表
import 'package:flutter_v2ex/models/web/model_login_detail.dart'; // 用户登录字段
import 'package:flutter_v2ex/utils/string.dart';
import 'package:flutter_v2ex/utils/storage.dart';
import './node.dart';
import 'package:flutter_v2ex/utils/logger.dart';

class DioRequestWeb {
  static dynamic _parseAndDecode(String response) {
    return jsonDecode(response);
  }

  static Future parseJson(String text) {
    return compute(_parseAndDecode, text);
  }

  GetStorage storage = GetStorage();

  // 获取主页分类内容
  static Future getTopicsByTabKey(String type, String id, int p,
      {bool silent = false}) async {
    var res = {};
    List topicList = <TabTopicItem>[];
    List childNodeList = [];
    List actionCounts = [];
    String balance = '';
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
          extra: {'ua': 'pc', 'silentError': silent},
        );
        break;
      case 'recent':
        return await getTopicsRecent('recent', p, silent: silent);
      case 'changes':
        return await getTopicsRecent('changes', p, silent: silent);
      case 'go':
        final model = await NodeWebApi.getTopicsByNodeId(id, p, silent: silent);
        return {
          'topicList': model.topicList,
          'childNodeList': [],
          'actionCounts': [],
          'balance': ''
        };
      default:
        response = await Request().get(
          '/',
          data: {'tab': 'all'},
          extra: {'ua': 'mob', 'silentError': silent},
        );
        break;
    }
    DioRequestWeb().resolveNode(response, 'pc');
    // 用户信息解析 mob
    var rootDom = parse(response.data);

    var userCellWrap = rootDom.querySelectorAll('div.tools > a');
    if (userCellWrap.length >= 6) {
      var onceHref = userCellWrap.last.attributes['onclick'];
      final RegExp regex = RegExp(r"once=(\d+)");
      final RegExpMatch match = regex.firstMatch(onceHref!)!;
      GStorage().setOnce(int.parse(match.group(1)!));
    }

    var aRootNode = rootDom.querySelectorAll("div[class='cell item']");
    if (aRootNode.isNotEmpty) {
      for (var aNode in aRootNode) {
        var item = TabTopicItem();
        var titleInfo = aNode.querySelector("span[class='item_title'] > a");
        item.topicTitle = titleInfo!.text;
        var titleInfoUrl = titleInfo.attributes['href'];
        final match = RegExp(r'(\d+)').allMatches(titleInfoUrl!);
        final result = match.map((m) => m.group(0)).toList();
        item.topicId = result[0]!;
        item.replyCount = int.parse(result[1]!);
        item.avatar = aNode.querySelector('img')!.attributes['src']!;
        var topicInfo = aNode.querySelector('span[class="topic_info"]');
        if (topicInfo!.querySelector('span') != null) {
          item.lastReplyTime = topicInfo.querySelector('span')!.text;
        }
        var tagANodes = topicInfo.querySelectorAll('a');
        if (tagANodes[0].attributes['class'] == 'node') {
          item.nodeName = tagANodes[0].text;
          item.nodeId =
              tagANodes[0].attributes['href']!.replaceFirst('/go/', '');
        }
        if (tagANodes[1].attributes['href'] != null) {
          item.memberId =
              tagANodes[1].attributes['href']!.replaceFirst('/member/', '');
        }
        if (tagANodes.length >= 3 && tagANodes[2].attributes['href'] != null) {
          item.lastReplyMId =
              tagANodes[2].attributes['href']!.replaceFirst('/member/', '');
        }
        topicList.add(item);
      }
    }
    try {
      Read().mark(topicList);
    } catch (err) {
      logDebug(err);
    }
    res['topicList'] = topicList;
    var childNode = rootDom.querySelector("div[id='SecondaryTabs']");
    if (childNode != null) {
      var childNodeEls = childNode
          .querySelectorAll('a')
          .where((el) => el.attributes['href']!.startsWith('/go'));
      if (childNodeEls.isNotEmpty) {
        for (var i in childNodeEls) {
          logDebug(i);
          var nodeItem = {};
          nodeItem['nodeId'] = i.attributes['href']!.split('/go/')[1];
          nodeItem['nodeName'] = i.text;
          childNodeList.add(nodeItem);
        }
      }
    }
    res['childNodeList'] = childNodeList;

    var rightBarNode = rootDom.querySelector('#Rightbar > div.box');
    List tableList = rightBarNode!.querySelectorAll('table');
    if (tableList.isNotEmpty) {
      var actionNodes = tableList[1]!.querySelectorAll('span.bigger');
      for (var i in actionNodes) {
        actionCounts.add(int.parse(i.text ?? 0));
      }
      if (rightBarNode.querySelector('#money') != null) {
        balance = rightBarNode.querySelector('#money >a')!.innerHtml;
      }
      var noticeEl = rightBarNode.querySelectorAll('a.fade');
      if (noticeEl.isNotEmpty) {
        var unRead = noticeEl[0].text.replaceAll(RegExp(r'\D'), '');
        logDebug('$unRead条未读消息');
        if (int.parse(unRead) > 0) {
          eventBus.emit('unRead', int.parse(unRead));
        }
      }
    }
    res['actionCounts'] = actionCounts;
    res['balance'] = balance;
    return res;
  }

  static List<TabTopicItem> _parsePcTopicItems(dom.Document document) {
    var topicList = <TabTopicItem>[];
    var topicNodes = document.querySelectorAll('div.cell.item');
    for (var aNode in topicNodes) {
      var titleInfo = aNode.querySelector('span.item_title > a');
      if (titleInfo == null) continue;

      var item = TabTopicItem();
      item.topicTitle = titleInfo.text.trim();

      var topicUrl = titleInfo.attributes['href'] ?? '';
      var topicIdMatch = RegExp(r'/t/(\d+)').firstMatch(topicUrl);
      if (topicIdMatch == null) continue;
      item.topicId = topicIdMatch.group(1)!;

      var avatarSrc = aNode.querySelector('img.avatar')?.attributes['src'] ??
          aNode.querySelector('img')?.attributes['src'];
      if (avatarSrc != null) {
        item.avatar = Uri.encodeFull(avatarSrc);
      }

      var countText = aNode.querySelector('a.count_livid')?.text.trim();
      if (countText != null && countText.isNotEmpty) {
        item.replyCount = int.tryParse(countText) ?? 0;
      }

      var topicInfo = aNode.querySelector('span.topic_info');
      if (topicInfo != null) {
        item.lastReplyTime = topicInfo.querySelector('span')?.text.trim() ?? '';

        var nodeEl = topicInfo.querySelector('a.node');
        if (nodeEl != null) {
          item.nodeName = nodeEl.text.trim();
          item.nodeId =
              nodeEl.attributes['href']?.replaceFirst('/go/', '') ?? '';
        }

        var memberEls = topicInfo
            .querySelectorAll('a')
            .where(
                (el) => el.attributes['href']?.startsWith('/member/') ?? false)
            .toList();
        if (memberEls.isNotEmpty) {
          item.memberId =
              memberEls[0].attributes['href']!.replaceFirst('/member/', '');
        }
        if (memberEls.length >= 2) {
          item.lastReplyMId =
              memberEls[1].attributes['href']!.replaceFirst('/member/', '');
        }
      }

      topicList.add(item);
    }
    return topicList;
  }

  // 获取最新的主题
  static Future getTopicsRecent(String path, int p,
      {bool silent = false}) async {
    var res = {};
    var topicList = <TabTopicItem>[];
    List childNodeList = [];
    List<int> actionCounts = [];
    String balance = '';
    Response response;
    try {
      response = await Request().get(
        '/$path',
        data: {'p': p},
        extra: {'ua': 'pc', 'silentError': silent},
      );
    } catch (err) {
      rethrow;
    }
    var document = parse(response.data);
    topicList = _parsePcTopicItems(document);
    try {
      Read().mark(topicList);
    } catch (err) {
      logDebug(err);
    }
    var rightBarNode = document.querySelector('#Rightbar > div.box');
    List tableList = rightBarNode?.querySelectorAll('table') ?? [];
    if (tableList.length >= 2) {
      var actionNodes = tableList[1].querySelectorAll('span.bigger');
      for (var i in actionNodes) {
        actionCounts.add(int.parse(i.text ?? 0));
      }
      if (rightBarNode?.querySelector('#money') != null) {
        balance = rightBarNode?.querySelector('#money >a')?.innerHtml ?? '';
      }
      var noticeEl = rightBarNode?.querySelectorAll('a.fade') ?? [];
      if (noticeEl.isNotEmpty) {
        var unRead = noticeEl[0].text.replaceAll(RegExp(r'\D'), '');
        // logDebug('$unRead条未读消息');
        if (int.parse(unRead) > 0) {
          eventBus.emit('unRead', int.parse(unRead));
        }
      }
    }
    res['topicList'] = topicList;
    res['childNodeList'] = childNodeList;
    res['actionCounts'] = actionCounts;
    res['balance'] = balance;
    return res;
  }

  // 获取所有节点 pc
  static Future getNodes() async {
    Response response;
    response = await Request().get(
      '/',
      // cacheOptions: buildCacheOptions(const Duration(days: 7)),
      extra: {'ua': 'pc'},
    );
    return DioRequestWeb().resolveNode(response, 'pc');
  }

  // 获取登录字段
  static Future<LoginDetailModel> getLoginKey() async {
    LoginDetailModel loginKeyMap = LoginDetailModel();
    Response response;
    SmartDialog.showLoading(msg: '获取验证码...');
    response = await Request().get(
      '/signin',
      extra: {'ua': 'mob'},
    );

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
      SmartDialog.dismiss();
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
        loginKeyMap.captchaImg =
            '${Strings.v2exHost}${aNode.querySelector('img')!.attributes['src']}?once=${loginKeyMap.once}';
      }
    }

    // 获取验证码
    ResponseType resType = ResponseType.bytes;
    Response res = await Request().get(
      "/_captcha",
      data: {'once': loginKeyMap.once},
      extra: {'ua': 'mob', 'resType': resType},
    );
    //  登录后未2fa 退出，第二次进入触发
    if (res.redirects.isNotEmpty && res.redirects[0].location.path == '/2fa') {
      loginKeyMap.twoFa = true;
    } else {
      if ((res.data as List<int>).isEmpty) {
        throw Exception('NetworkImage is an empty file');
      }
      loginKeyMap.captchaImgBytes = Uint8List.fromList(res.data!);
    }
    SmartDialog.dismiss();
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

    FormData formData = FormData.fromMap({
      args.userNameHash: args.userNameValue,
      args.passwordHash: args.passwordValue,
      args.codeHash: args.codeValue,
      'once': args.once,
      'next': args.next
    });

    response =
        await Request().post('/signin', data: formData, options: options);
    options.contentType = Headers.jsonContentType; // 还原
    if (response.statusCode == 302) {
      // 登录成功，重定向
      // SmartDialog.dismiss();
      return await getUserInfo();
    } else {
      // 登录失败，去获取错误提示信息
      var tree = ETree.fromString(response.data);
      // //*[@id="Wrapper"]/div/div[1]/div[3]/ul/li "输入的验证码不正确"
      // //*[@id="Wrapper"]/div/div[1]/div[2]/ul/li "用户名和密码无法匹配" 等
      String? errorInfo;
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
      SmartDialog.showToast(errorInfo!);
      return 'false';
    }
  }

  // 获取当前用户信息
  static Future<String> getUserInfo() async {
    logDebug('getUserInfo');
    var response = await Request().get('/write', extra: {'ua': 'mob'});
    // SmartDialog.dismiss();
    if (response.redirects.isNotEmpty) {
      logDebug('getUserInfo 2fa');
      // 需要两步验证
      if (response.redirects[0].location.path == "/2fa") {
        response = await Request().get('/2fa');
      }
    }
    var tree = ETree.fromString(response.data);
    var elementOfAvatarImg = tree.xpath("//*[@id='menu-entry']/img")?.first;
    if (elementOfAvatarImg != null &&
        elementOfAvatarImg.attributes['class'].contains('avatar')) {
      // 获取用户头像
      String avatar = elementOfAvatarImg.attributes["src"];
      String userName = elementOfAvatarImg.attributes["alt"];
      GStorage().setUserInfo({'avatar': avatar, 'userName': userName});
      // todo 判断用户是否开启了两步验证
      // 需要两步验证
      logDebug('两步验证判断');
      if (response.requestOptions.path == "/2fa") {
        logDebug('需要两步验证');
        var tree = ETree.fromString(response.data);
        // //*[@id="Wrapper"]/div/div[1]/div[2]/form/table/tbody/tr[3]/td[2]/input[1]
        String once = tree
            .xpath(
                "//*[@id='Wrapper']/div/div[1]/div[2]/form/table/tr[3]/td[2]/input[@name='once']")!
            .first
            .attributes["value"];
        GStorage().setOnce(int.parse(once));
        SmartDialog.dismiss();
        return "2fa";
      } else {
        GStorage().setLoginStatus(true);
        SmartDialog.dismiss();
        return "true";
      }
    }
    SmartDialog.dismiss();
    return "false";
  }

  // 2fa登录
  static Future<String> twoFALOgin(String code) async {
    SmartDialog.showLoading();
    Response response;
    FormData formData = FormData.fromMap({
      "once": GStorage().getOnce(),
      "code": code,
    });
    response = await Request().post('/2fa', data: formData);
    // var document = parse(response.data);
    // log(document.body!.innerHtml);
    // var menuBodyNode = document.querySelector("div[id='menu-body']");
    // var loginOutNode =
    // menuBodyNode!.querySelectorAll('div.cell').last.querySelector('a');
    // var loginOutHref = loginOutNode!.attributes['href'];
    // int once = int.parse(loginOutHref!.split('once=')[1]);
    // GStorage().setOnce(once);
    SmartDialog.dismiss();
    if (response.statusCode == 302) {
      logDebug('成功');
      return 'true';
    } else {
      SmartDialog.showToast('验证失败，请重新输入');
      return 'false';
    }
  }

  // 感谢回复
  static Future thankReply(String replyId, String topicId) async {
    int once = GStorage().getOnce();
    SmartDialog.showLoading(msg: '表示感谢ing');
    try {
      var response = await Request().post("/thank/reply/$replyId?once=$once");
      // logDebug('1019 thankReply: $response');
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

  // 忽略回复
  static Future<bool> ignoreReply(String replyId) async {
    // https://www.v2ex.com/ignore/reply/12751760?once=90371
    int once = GStorage().getOnce();
    await Request().post("/ignore/reply/$replyId?once=$once");
    // 操作成功
    return true;
  }

  // 查看每日奖励
  static Future<Map<dynamic, dynamic>> queryDaily() async {
    Map<dynamic, dynamic> signDetail = {
      'signStatus': false,
      'signDays': 0,
      'balanceRender': ''
    };
    Response response;
    response = await Request().get('/mission/daily', extra: {'ua': 'pc'});
    var bodyDom = parse(response.data).body;
    var mainBox = bodyDom!.querySelector('#Main');
    if (mainBox != null) {
      // 领取 X 铜币 表示未签到
      var signStatus = mainBox.querySelector('input')!.attributes['value'];
      var boxDom = mainBox.querySelector('div.box');
      // 签到天数
      var cellDom = boxDom!.querySelectorAll('div.cell').last.text;
      // false 未签到
      signDetail['signStatus'] = signStatus == '领取 X 铜币' ? false : true;
      var day = cellDom.replaceAll(RegExp(r'\D'), '');
      signDetail['signDays'] = '已领取$day天';
    }
    var noticeNode =
        bodyDom.querySelector('#Rightbar>div.box>div.cell.flex-one-row');
    if (noticeNode != null) {
      // 未读消息
      var unRead =
          noticeNode.querySelector('a')!.text.replaceAll(RegExp(r'\D'), '');
      // logDebug('$unRead条未读消息');
      if (int.parse(unRead) > 0) {
        eventBus.emit('unRead', int.parse(unRead));
      }

      // 余额
      // List balance = noticeNode.querySelector('div#money')!.text.split(' ');
      // balance.removeAt(1);
      // balance.removeAt(2);
      // signDetail['balance'] = balance;
      if (noticeNode.querySelector('div#money') != null) {
        signDetail['balanceRender'] =
            noticeNode.querySelector('div#money')!.innerHtml;
      } else {
        signDetail['balanceRender'] = null;
      }
    }
    return signDetail;
  }

  // 签到 北京时间8点之后
  static Future dailyMission() async {
    String lastSignDate = GStorage().getSignStatus(); // 2 23
    String currentDate = DateTime.now().toString().split(' ')[0]; // 2 24
    // 当前时
    int currentHour = DateTime.now().hour;
    if (currentHour >= 8) {
      GStorage().setEightQuery(false);
    }
    if (lastSignDate == currentDate || GStorage().getEightQuery()) {
      logDebug('已签到 / 不自动签到');
      return false;
    }
    try {
      Response response;
      int once = GStorage().getOnce();
      response = await Request()
          .get("/mission/daily/redeem?once=$once", extra: {'ua': 'mob'});
      if (response.statusCode == 302) {
        SmartDialog.showToast('签到成功');
      } else if (response.statusCode == 200) {
        // logDebug(response.redirect!);
        // log(parse(response.data).body!.innerHtml);
        var res = parse(response.data);
        var document = res.body;
        var mainBox = document!.querySelector('div[id="Main"]');
        if (mainBox!.querySelector('div.message') != null) {
          var tipsText = mainBox.querySelector('div.message')!.innerHtml;
          if (tipsText.contains('你要查看的页面需要先登录')) {
            SmartDialog.showToast('登录状态失效');
            // eventBus.emit('login', 'fail');
          } else {
            return mainBox.querySelector('div.message')!.text;
          }
        }

        /// 大于北京时间8点 签到状态为昨天，否则今天
        if (mainBox.querySelector('span.gray') != null) {
          var tipsText = mainBox.querySelector('span.gray')!.innerHtml;
          if (currentHour >= 8) {
            if (tipsText.contains('已领取')) {
              SmartDialog.showToast('今日已签到');
              GStorage().setSignStatus(DateTime.now().toString().split(' ')[0]);
              // eventBus.emit('login', 'fail');
              GStorage().setEightQuery(false);
            }
          } else if (currentHour < 8) {
            GStorage().setEightQuery(true);
            logDebug("未到8点");
          }
        }
      }
    } on DioException catch (e) {
      log(e.message!);
      SmartDialog.showToast('领取每日奖励失败：${e.message}');
    }
  }

  resolveNode(response, type) {
    List<Map<dynamic, dynamic>> nodesList = [];
    var document = parse(response.data);
    dynamic nodesBox;
    if (type == 'mob') {
      // 【设置】中可能关闭【首页显示节点导航】
      if (document.querySelector('#Wrapper > div.content')!.children.length >=
          4) {
        nodesBox = document.querySelector('#Main')!.children.last;
      }
    }
    if (type == 'pc') {
      // 【设置】中可能关闭【首页显示节点导航】
      if (document.querySelector('#Main')!.children.length >= 4) {
        nodesBox = document.querySelector('#Main')!.children.last;
      }
    }
    if (nodesBox != null) {
      nodesBox.children.removeAt(0);
      var nodeTd = nodesBox.children;
      for (var i in nodeTd) {
        Map nodeItem = {};
        String fName = i.querySelector('span')!.text;
        nodeItem['name'] = fName;
        List<Map> childs = [];
        var cEl = i.querySelectorAll('a');
        for (var j in cEl) {
          Map item = {};
          item['nodeId'] = j.attributes['href']!.split('/').last;
          item['nodeName'] = j.text;
          childs.add(item);
        }
        nodeItem['childs'] = childs;

        nodesList.add(nodeItem);
      }
      nodesList.insert(0, {'name': '已收藏', 'childs': []});
      GStorage().setNodes(nodesList);
      return nodesList;
    }
  }

  static Future loginOut() async {
    int once = GStorage().getOnce();
    Request().get('/signout?once=$once');
  }

  // 发布主题
  static postTopic(args) async {
    SmartDialog.showLoading(msg: '发布中...');
    Options options = Options();
    options.contentType = Headers.formUrlEncodedContentType;
    options.headers = {
      // 必须字段
      // Referer :  https://www.v2ex.com/write?node=qna
      'Referer': '${Strings.v2exHost}/write?node=${args['node_name']}',
      'Origin': Strings.v2exHost,
      'user-agent':
          'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1'
    };

    FormData formData = FormData.fromMap({
      'title': args['title'], // 标题
      'syntax': args['syntax'], // 语法 default markdown
      'content': args['content'], // 内容
      'node_name': args['node_name'], // 节点名称 en
      'once': GStorage().getOnce()
    });

    Response response =
        await Request().post('/write', data: formData, options: options);
    SmartDialog.dismiss();
    var document = parse(response.data);
    logDebug('1830：${response.headers["location"]}');
    if (document.querySelector('div.problem') != null) {
      SmartDialog.show(
        useSystem: true,
        animationType: SmartAnimationType.centerFade_otherSlide,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('提示'),
            content: Text(document.querySelector('div.problem')!.text),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('确定'))
            ],
          );
        },
      );
      return false;
    } else {
      return response.headers["location"];
    }
  }

  // 编辑主题 不可更改节点
  static eidtTopic(args) async {
    SmartDialog.showLoading(msg: '发布中...');
    Options options = Options();
    options.contentType = Headers.formUrlEncodedContentType;
    options.headers = {
      // 必须字段
      // Referer :  https://www.v2ex.com/edit/write/topic/918603
      'Referer': '${Strings.v2exHost}/edit/topic/${args['topicId']}',
      'Origin': Strings.v2exHost,
      'user-agent':
          'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1'
    };
    FormData formData = FormData.fromMap({
      'title': args['title'], // 标题
      'syntax': args['syntax'], // 语法 0: default 1: markdown
      'content': args['content'], // 内容
    });

    Response response = await Request().post('/edit/topic/${args['topicId']}',
        data: formData, options: options);
    SmartDialog.dismiss();
    var document = parse(response.data);
    var mainNode = document.querySelector('#Main');
    if (mainNode != null &&
        mainNode.querySelector('div.inner')!.text.contains('你不能编辑这个主题')) {
      return false;
    } else {
      return true;
    }
  }

  // 移动主题节点
  static moveTopicNode(topicId, nodeName) async {
    SmartDialog.showLoading(msg: '移动中...');
    Options options = Options();
    options.contentType = Headers.formUrlEncodedContentType;
    options.headers = {
      // 必须字段
      // Referer :  https://www.v2ex.com/write?node=qna
      'Referer': '${Strings.v2exHost}/move/topic/$topicId',
      'Origin': Strings.v2exHost,
      'user-agent':
          'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1'
    };

    FormData formData = FormData.fromMap({
      'destination': nodeName, // 节点
    });

    Response response = await Request()
        .post('/move/topic/$topicId', data: formData, options: options);
    SmartDialog.dismiss();
    var document = parse(response.data);
    var mainNode = document.querySelector('#Main');
    if (mainNode!.querySelector('div.inner') != null &&
        mainNode.querySelector('div.inner')!.text.contains('你不能移动这个主题。')) {
      return false;
    } else {
      return true;
    }
  }

  // 查询主题状态 pc
  static Future queryTopicStatus(topicId) async {
    SmartDialog.showLoading();
    Map result = {};
    Response response =
        await Request().get('/edit/topic/$topicId', extra: {'ua': 'pc'});
    SmartDialog.dismiss();
    var document = parse(response.data);
    var mainNode = document.querySelector('#Main');
    if (mainNode!.querySelector('div.inner') != null &&
        mainNode.querySelector('div.inner')!.text.contains('你不能编辑这个主题')) {
      // 不可编辑
      result['status'] = false;
    } else {
      Map topicDetail = {};
      var topicTitle = mainNode.querySelector('#topic_title');
      topicDetail['topicTitle'] = topicTitle!.text;
      var topicContent = mainNode.querySelector('#topic_content');
      topicDetail['topicContent'] = topicContent!.text;
      var select = mainNode.querySelector('#select_syntax');
      var syntaxs = select!.querySelectorAll('option');
      var selectSyntax = '';
      for (var i in syntaxs) {
        if (i.attributes['selected'] != null) {
          selectSyntax = i.attributes['value']!;
        }
      }
      topicDetail['syntax'] = selectSyntax;
      result['topicDetail'] = topicDetail;
      result['status'] = true;
    }
    return result;
  }

  // 查询是否可以增加附言
  static Future appendStatus(topicId) async {
    SmartDialog.showLoading();
    Response response =
        await Request().get('/append/topic/$topicId', extra: {'ua': 'mob'});
    SmartDialog.dismiss();
    logDebug(response);
    var document = parse(response.data);
    if (document.querySelectorAll('input').length > 2) {
      var onceNode = document.querySelectorAll('input')[1];
      GStorage().setOnce(int.parse(onceNode.attributes['value']!));
      return true;
    } else {
      return false;
    }
  }

  // 增加附言
  static Future appendContent(args) async {
    SmartDialog.showLoading(msg: '正在提交...');
    Options options = Options();
    options.contentType = Headers.formUrlEncodedContentType;
    options.headers = {
      // 必须字段
      // Referer :  https://www.v2ex.com/append/topic/918603
      'Referer': '${Strings.v2exHost}/append/topic/${args['topicId']}',
      'Origin': Strings.v2exHost,
      'user-agent':
          'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1'
    };

    FormData formData = FormData.fromMap({
      'content': args['content'], // 内容
      'syntax': args['syntax'],
      'once': GStorage().getOnce()
    });
    Response? response;
    try {
      response = await Request().post('/append/topic/${args['topicId']}',
          data: formData, options: options);
      SmartDialog.dismiss();
      var document = parse(response!.data);
      logDebug(document);
      return true;
    } catch (err) {
      SmartDialog.dismiss();
    }
  }

  // 检测更新
  // static Future<Map> checkUpdate() async {
  //   Map updata = {
  //     'lastVersion': '',
  //     'downloadHref': '',
  //     'needUpdate': false,
  //   };
  //   Response response = await Request().get(
  //       'https://api.github.com/repos/guozhigq/flutter_v2ex/releases/latest');
  //   var versionDetail = VersionModel.fromJson(response.data);
  //   logDebug(versionDetail.tag_name);
  //   // 版本号
  //   var version = versionDetail.tag_name;
  //   var updateLog = versionDetail.body;
  //   List<String> updateLogList = updateLog.split('\r\n');
  //   var needUpdate = Utils.needUpdate(Strings.currentVersion, version);
  //   if (needUpdate) {
  //     SmartDialog.show(
  //       useSystem: true,
  //       animationType: SmartAnimationType.centerFade_otherSlide,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: const Text('🎉 发现新版本 '),
  //           content: Column(
  //             mainAxisAlignment: MainAxisAlignment.start,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Text(
  //                 version,
  //                 style: const TextStyle(fontSize: 20),
  //               ),
  //               const SizedBox(height: 8),
  //               for (var i in updateLogList) ...[Text(i)]
  //             ],
  //           ),
  //           actions: [
  //             TextButton(
  //                 onPressed: () => SmartDialog.dismiss(),
  //                 child: const Text('取消')),
  //             TextButton(
  //                 // TODO
  //                 onPressed: () {
  //                   SmartDialog.dismiss();
  //                   Utils.openURL('${Strings.remoteUrl}/releases');
  //                 },
  //                 child: const Text('去更新'))
  //           ],
  //         );
  //       },
  //     );
  //   } else {
  //     updata[needUpdate] = true;
  //   }
  //   return updata;
  // }
}
