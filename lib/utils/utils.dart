// ignore_for_file: avoid_print

import 'dart:convert' show utf8, base64;
import 'dart:io';
import 'dart:async';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_v2ex/utils/string.dart';

import 'event_bus.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_v2ex/utils/global.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:flutter_v2ex/utils/storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_v2ex/pages/page_login.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_v2ex/http/init.dart';

class Utils {
//   static IosDeviceInfo iosInfo;
//   static AndroidDeviceInfo androidInfo;

  final ChromeSafariBrowser browser = MyChromeSafariBrowser();

  // // 获取设备系统版本号
  static deviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Running on ${androidInfo.version.sdkInt}');
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print('Running on ${iosInfo.systemVersion}');
    }
  }

  static Future<String> getCookiePath() async {
    Directory tempDir = await getApplicationDocumentsDirectory();
    String tempPath = "${tempDir.path}/.vvexCookie";
    Directory dir = Directory(tempPath);
    bool b = await dir.exists();
    if (!b) {
      dir.createSync(recursive: true);
    }

    return tempPath;
  }

  // scheme 外链跳转
  static launchURL(url) async {
    if (await canLaunchUrl(url)) {
      launchUrl(url);
    } else {
      SmartDialog.showToast('无法打开scheme $url');
    }
  }

  static openURL(aUrl) async {
    bool linkOpenType = GStorage().getLinkOpenInApp();
    if (!linkOpenType) {
      // 1. openWithSystemBrowser
      try{
        await InAppBrowser.openWithSystemBrowser(url: WebUri(aUrl));
      }catch(err) {
        SmartDialog.showToast(err.toString());
      }
    } else {
      // 2. openWithAppBrowser
      try{
        await Utils().browser.open(
          url: WebUri(aUrl),
          settings: ChromeSafariBrowserSettings(
              shareState: CustomTabsShareState.SHARE_STATE_OFF,
              isSingleInstance: false,
              isTrustedWebActivity: false,
              keepAliveEnabled: true,
              startAnimations: [
                AndroidResource.anim(
                    name: "slide_in_left", defPackage: "android"),
                AndroidResource.anim(
                    name: "slide_out_right", defPackage: "android")
              ],
              exitAnimations: [
                AndroidResource.anim(
                    name: "abc_slide_in_top",
                    defPackage:
                    "com.pichillilorenzo.flutter_inappwebviewexample"),
                AndroidResource.anim(
                    name: "abc_slide_out_top",
                    defPackage:
                    "com.pichillilorenzo.flutter_inappwebviewexample")
              ],
              dismissButtonStyle: DismissButtonStyle.CLOSE,
              presentationStyle: ModalPresentationStyle.OVER_FULL_SCREEN),
        );
      }catch(err) {
        // SmartDialog.showToast(err.toString());
        // https://github.com/guozhigq/flutter_v2ex/issues/49
        GStorage().setLinkOpenInApp(false);
        await InAppBrowser.openWithSystemBrowser(url: WebUri(aUrl));
      }
    }
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  // 头像转成大图
  String avatarLarge(String avatar) {
    //// 获取到的是24*24大小，改成73*73
    ////cdn.v2ex.com/gravatar/3896b6baf91ec1933c38f370964647b7?s=24&d=retro%0A
    //cdn.v2ex.com/gravatar/3896b6baf91ec1933c38f370964647b7?s=32&d=retro 登录后获取的头像（移动端样式下）
    //cdn.v2ex.com/avatar/d8fe/ee94/193847_normal.png?m=1477551256
    //cdn.v2ex.com/avatar/d0df/5707/71698_mini.png?m=1408718789
    var regExp1 = RegExp(r's=24|s=32');
    var regExp2 = RegExp(r'normal');
    var regExp3 = RegExp(r'mini');
    if (avatar.contains(regExp1)) {
      avatar = avatar.replaceFirst(regExp1, 's=73');
    } else if (avatar.contains(regExp2)) {
      avatar = avatar.replaceFirst(regExp2, 'large');
    } else if (avatar.contains(regExp3)) {
      avatar = avatar.replaceFirst(regExp3, 'large');
    }

    return avatar;
  }

  // img链接
  String imageUrl(String imgUrl) {
    if (!imgUrl.startsWith('http')) {
      if (imgUrl.startsWith('//')) {
        imgUrl = 'https:$imgUrl';
      } else {
        imgUrl = 'https://www.v2ex.com$imgUrl';
      }
    }

    // var suffix =
    //     '(bmp|jpg|png|tif|gif|pcx|tga|exif|fpx|svg|psd|cdr|pcd|dxf|ufo|eps|ai|raw|WMF|webp|jpeg)';
    // RegExp exp = RegExp(r'.*\.' + suffix);
    // if (!exp.hasMatch(imgUrl)) {
    //   imgUrl = '$imgUrl.png';
    // }
    return imgUrl;
  }

  // https://usamaejaz.com/cloudflare-email-decoding/
  // cloudflare email 转码
  static String cfDecodeEmail(String encodedString) {
    var email = "",
        r = int.parse(encodedString.substring(0, 2), radix: 16),
        n,
        i;
    for (n = 2; encodedString.length - n > 0; n += 2) {
      i = int.parse(encodedString.substring(n, n + 2), radix: 16) ^ r;
      email += String.fromCharCode(i);
    }
    return email;
  }

  // debounce.dart

  /// 函数防抖
  ///
  /// [func]: 要执行的方法
  /// [delay]: 要迟延的时长
  static Function debounce(
    Function func, [
    Duration delay = const Duration(milliseconds: 2000),
  ]) {
    Timer? timer;
    target() {
      if (timer!.isActive) {
        timer!.cancel();
      }
      timer = Timer(delay, () {
        func.call();
      });
    }

    return target;
  }

  static stringToMap(str) {
    Map result = {};
    var strArr = str.split('#');
    for (var i in strArr) {
      var keyValue = i.split(':');
      result[keyValue[0]] = keyValue[1];
    }
    return result;
  }

  static Future<String> localTimeZone() async {
    if (kIsWeb || Platform.isLinux) {
      return '';
    }
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    return timeZoneName;
  }

  // base64 解析 wechat
  static base64Decode(contentDom) {
    try {
      var blacklist = Strings().base64BlackList;
      String content = contentDom.text;
      RegExp exp = RegExp(r'[a-zA-Z\d=]{8,}');
      RegExp exp2 = RegExp(r'^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{4}|[A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)$');
      var expMatch = exp.allMatches(content);
      var wechat = '';
      for (var i in expMatch) {
        if (!blacklist.contains(content) &&
            i.group(0)!.trim().length % 4 == 0) {
          wechat = utf8.decode(base64.decode(i.group(0)!));
        }
      }
      RegExp wechatRegExp = RegExp(r'^[a-zA-Z][a-zA-Z0-9_-]{5,19}$');
      RegExp emailRegExp = RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');
      if(wechatRegExp.hasMatch(wechat) || RegExp(r'^\d+$').hasMatch(wechat) || emailRegExp.hasMatch(wechat)){
        return wechat;
      }
      return '';
    } catch (err) {
      // print(err);
      return '';
    }
  }

  // 版本比较
  static bool needUpdate(localVersion, _emoteVersion) {
    List<String> localVersionList = localVersion.split('v')[1].split('.');
    List<String> remoteVersionList = _emoteVersion.split('v')[1].split('.');
    for (int i = 0; i < localVersionList.length; i++) {
      int localVersion = int.parse(localVersionList[i]);
      int remoteVersion = int.parse(remoteVersionList[i]);
      if (remoteVersion > localVersion) {
        return true;
      } else if (remoteVersion < localVersion) {
        return false;
      }
    }
    return false;
  }
}

class MyChromeSafariBrowser extends ChromeSafariBrowser {
  @override
  void onOpened() {
    // print("😊flutter ChromeSafari browser opened");
  }

  @override
  void onLoadStart() {
    // print('😊flutter flutter onloadStart');
  }

  // 加载完成
  @override
  void onCompletedInitialLoad(didLoadSuccessfully) async {
    // print("😊flutter ChromeSafari browser initial load completed");
    // final cookieManager = CookieManager.instance();
    // List<Cookie> cookies = await cookieManager.getCookies(url: WebUri.uri(Uri.parse('https://www.v2ex.com/signin')));
    // print('😊flutter: $cookies');
  }

  @override
  void onInitialLoadDidRedirect(WebUri? url) {}

  @override
  void onClosed() async {
    // final cookieManager = CookieManager.instance();
    // List<Cookie> cookies = await cookieManager.getCookies(url: WebUri.uri(Uri.parse('https://www.v2ex.com')));
    // print('😊flutter: $cookies');
    // print("😊flutter ChromeSafari browser closed");
  }
}
