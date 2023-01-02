import 'package:dio/dio.dart';

import 'package:flutter_v2ex/http/init.dart';
import 'package:html/dom.dart'
    as dom; // Contains DOM related classes for extracting data from elements
import 'package:html/dom.dart';
import 'package:html/parser.dart'; // Contains HTML parsers to generate a Document object
import 'package:xpath/xpath.dart';
import 'package:html/dom_parsing.dart';
import 'package:html/html_escape.dart';

import 'package:flutter_v2ex/models/web/item_tab_topic.dart';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import '/utils/utils.dart';
import '/utils/string.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';

class DioRequestWeb {
  static var configStatus = false;

  static dynamic _parseAndDecode(String response) {
    return jsonDecode(response);
  }

  static Future parseJson(String text) {
    return compute(_parseAndDecode, text);
  }

  static init() async {
    var cookiePath = await Utils.getCookiePath();
    var cookieJar = PersistCookieJar(
        ignoreExpires: true, storage: FileStorage(cookiePath)); // 持久化 cookie
    dio.interceptors
      ..add(CookieManager(cookieJar))
      ..add(LogInterceptor())
      ..add(
          DioCacheManager(CacheConfig(baseUrl: Strings.v2exHost)).interceptor);
    (dio.transformer as DefaultTransformer).jsonDecodeCallback = parseJson;
    dio.options.connectTimeout = 12000;
    dio.options.receiveTimeout = 12000;
    dio.options.baseUrl = 'https://www.v2ex.com';
    dio.options.headers = {
      'user-agent':
          'Mozilla/5.0 (Linux; Android 4.4.2; Nexus 4 Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.75 Mobile Safari/537.36'
    };
    configStatus = true;
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

  static Future verifyLoginStatus() async {
    final response = await dio.get("/new");
    print(response);
  }

  // 获取主页分类内容
  static Future<List<TabTopicItem>> getTopicsByTabKey() async {
    print(configStatus);
    if (!configStatus) {
      await init();
    }
    var topics = <TabTopicItem>[];
    Response response;
    response = await dio.get('/?tab=all');
    var tree = ETree.fromString(response.data);
    // ignore: avoid_print
    var aRootNode = tree.xpath("//*[@class='cell item']");
    for (var aNode in aRootNode) {
      var item = TabTopicItem();
      // //*[@id="Wrapper"]/div/div[3]/div[3]/table/tbody/tr/td[3]/span[1]/strong/a
      item.memberId =
          aNode.xpath("/table/tr/td[3]/span[1]/strong/a/text()")[0].name;
      //*[@id="Wrapper"]/div/div[3]/div[3]/table/tbody/tr/td[1]/a/img
      item.avatar = aNode
          .xpath("/table/tr/td[1]/a[1]/img[@class='avatar']")
          .first
          .attributes["src"];
      //*[@id="Wrapper"]/div/div[3]/div[3]/table/tbody/tr/td[3]/span[2]/a
      String topicUrl = aNode
          .xpath("/table/tr/td[3]/span[2]/a")
          .first
          .attributes["href"]; // 得到是 /t/522540#reply17
      item.topicId = topicUrl.replaceAll("/t/", "").split("#")[0];
      //*[@id="Wrapper"]/div/div[3]/div[23]/table/tbody/tr/td[4]
      if (aNode.xpath("/table/tr/td[4]/a/text()") != null) {
        // 有评论数
        //*[@id="Wrapper"]/div/div/div[3]/table/tbody/tr/td[4]/a
        item.replyCount = aNode.xpath("/table/tr/td[4]/a/text()")[0].name;

        //*[@id="Wrapper"]/div/div[3]/div[22]/table/tbody/tr/td[3]/span[3]
        item.lastReplyTime = aNode
            .xpath("/table/tr/td[3]/span[3]/text()[1]")[0]
            .name
            .split(' &nbsp;')[0];

        //*[@id="Wrapper"]/div/div[3]/div[22]/table/tbody/tr/td[3]/span[3]/strong/a
        if (aNode.xpath("/table/tr/td[3]/span[3]/strong/a/text()") != null) {
          // 遇到有评论数，但是没有最后回复id的情况，这里多加一个判断
          item.lastReplyMId =
              aNode.xpath("/table/tr/td[3]/span[3]/strong/a/text()")[0].name;
        }
      }
      //*[@id="Wrapper"]/div/div[3]/div[3]/table/tbody/tr/td[3]/span[2]/a
      item.topicContent = aNode
          .xpath("/table/tr/td[3]/span[2]/a/text()")[0]
          .name
          .replaceAll('&quot;', '"')
          .replaceAll('&amp;', '&')
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>');

      //*[@id="Wrapper"]/div/div[3]/div[3]/table/tbody/tr/td[3]/span[1]/a
      item.nodeName = aNode.xpath("/table/tr/td[3]/span[1]/a/text()")[0].name;

      topics.add(item);
    }
    return topics;
  }
}
