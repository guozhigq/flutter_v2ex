// ignore_for_file: avoid_print

import 'dart:convert' show utf8, base64;
import 'dart:io';
import 'dart:async';
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

  static openURL(aUrl) async{
    bool linkOpenType = GStorage().getLinkOpenInApp();
    if(!linkOpenType) {
      // 1. openWithSystemBrowser
      await InAppBrowser.openWithSystemBrowser(
          url: WebUri(aUrl)
      );
    }else {
      // 2. openWithAppBrowser
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

  static void onLogin() {
    Navigator.push(
      Routes.navigatorKey.currentContext!,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
        fullscreenDialog: true,
      ),
    ).then(
      (value) => {
        if (value['loginStatus'] == 'cancel')
          {SmartDialog.showToast('取消登录'), EventBus().emit('login', 'cancel')},
        if (value['loginStatus'] == 'success')
          {SmartDialog.showToast('登录成功'), EventBus().emit('login', 'success')}
      },
    );
  }

  static void loginDialog(
    String content, {
    String title = '提示',
    String cancelText = '取消',
    String confirmText = '去登录',
    bool isPopContext = false,
    bool isPopDialog = true,
  }) {
    SmartDialog.show(
      useSystem: true,
      animationType: SmartAnimationType.centerFade_otherSlide,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
                onPressed: () {
                  SmartDialog.dismiss();
                  isPopContext ? Navigator.pop(context) : null;
                },
                child: Text(cancelText)),
            TextButton(
                onPressed: () async {
                  if (isPopDialog) {
                    SmartDialog.dismiss()
                        .then((value) => Get.toNamed('/login'));
                  } else {
                    Get.toNamed('/login');
                  }
                },
                child: Text(confirmText))
          ],
        );
      },
    );
  }

  static void twoFADialog() {
    var twoFACode = '';
    SmartDialog.show(
      useSystem: true,
      animationType: SmartAnimationType.centerFade_otherSlide,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('2FA 验证'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('你的 V2EX 账号已经开启了两步验证，请输入验证码继续'),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: '验证码',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                ),
                onChanged: (e) {
                  twoFACode = e;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('取消')),
            TextButton(
                onPressed: () async {
                  if (twoFACode.length == 6) {
                    var res = await DioRequestWeb.twoFALOgin(twoFACode);
                    if (res == 'true') {
                      SmartDialog.showToast('登录成功');
                      GStorage().setLoginStatus(true);
                      EventBus().emit('login', 'success');
                      // 关闭loading
                      SmartDialog.dismiss();
                      // 关闭2fa dialog
                      if(context.mounted){
                        Navigator.pop(context);
                      }
                      // 关闭login page
                      Get.back();
                    } else {
                      twoFACode = '';
                    }
                  } else {
                    SmartDialog.showToast(
                      '验证码有误',
                      displayTime: const Duration(milliseconds: 500),
                    );
                  }
                },
                child: const Text('登录'))
          ],
        );
      },
    );
  }

  static stringToMap(str) {
    Map result = {};
    var strArr = str.split('#');
    for(var i in strArr){
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
      RegExp exp = RegExp(r'^[a-zA-Z][a-zA-Z\d]*={0,2}$');
      var expMatch = exp.allMatches(content);
      var wechat = '';
      for (var i in expMatch) {
        if (!blacklist.contains(content) && i
            .group(0)!
            .trim()
            .length % 4 == 0) {
          wechat = utf8.decode(base64.decode(i.group(0)!));
        }
      }
      return wechat;
    }catch(err) {
      print(err);
      return '';
    }

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
  void onCompletedInitialLoad(didLoadSuccessfully) async{
    // print("😊flutter ChromeSafari browser initial load completed");
    // final cookieManager = CookieManager.instance();
    // List<Cookie> cookies = await cookieManager.getCookies(url: WebUri.uri(Uri.parse('https://www.v2ex.com/signin')));
    // print('😊flutter: $cookies');
  }

  @override
  void onInitialLoadDidRedirect(WebUri? url) {

  }
  @override
  void onClosed() async{
    // final cookieManager = CookieManager.instance();
    // List<Cookie> cookies = await cookieManager.getCookies(url: WebUri.uri(Uri.parse('https://www.v2ex.com')));
    // print('😊flutter: $cookies');
    // print("😊flutter ChromeSafari browser closed");
  }
}