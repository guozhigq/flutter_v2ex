import 'dart:io';
import 'dart:async';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_v2ex/pages/page_login.dart';
import 'package:flutter_v2ex/utils/global.dart';
import 'package:device_info_plus/device_info_plus.dart';

// import 'package:ovprogresshud/progresshud.dart';
import 'package:path_provider/path_provider.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'event_bus.dart';
import 'package:flutter_v2ex/utils/storage.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

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
    // Directory dir = Directory(tempPath);
    // bool b = await dir.exists();
    // if (!b) {
    //   dir.createSync(recursive: true);
    // }

    return tempPath;
  }

  // 外链跳转
  static launchURL(url, {String scheme = 'https'}) async {
    Uri _url;
    if (scheme == 'https') {
      if (url.startsWith('//')) {
        // 处理有些链接是 //xxxx 形式
        url = 'https:$url';
      }
      _url = Uri.parse(url);
    } else {
      // sms email tel
      _url = url;
    }
    if (await canLaunchUrl(_url)) {
      launchUrl(_url);
    } else {
      SmartDialog.showToast('Could not launch $_url');
    }
  }

  static openURL(aUrl) async{
    // 1. openWithSystemBrowser
    // await InAppBrowser.openWithSystemBrowser(
    //     url: WebUri(aUrl)
    // );

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
                      Navigator.pop(context);
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
}

class MyChromeSafariBrowser extends ChromeSafariBrowser {
  @override
  void onOpened() {
    print("ChromeSafari browser opened");
  }

  @override
  void onCompletedInitialLoad(didLoadSuccessfully) {
    print("ChromeSafari browser initial load completed");
  }

  @override
  void onClosed() {
    print("ChromeSafari browser closed");
  }
}