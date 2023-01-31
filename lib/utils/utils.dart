// import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_v2ex/pages/profile_page.dart';
import 'package:flutter_v2ex/utils/global.dart';

// import 'package:device_info/device_info.dart';
// import 'package:ovprogresshud/progresshud.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:url_launcher/url_launcher.dart';

class Utils {
//   static IosDeviceInfo iosInfo;
//   static AndroidDeviceInfo androidInfo;

  // // 获取设备系统版本号
  // static deviceInfo() async {
  //   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //   if (Platform.isAndroid) {
  //     androidInfo = await deviceInfo.androidInfo;
  //     print('Running on ${androidInfo.version.sdkInt}');
  //   } else if (Platform.isIOS) {
  //     iosInfo = await deviceInfo.iosInfo;
  //     print('Running on ${iosInfo.systemVersion}');
  //   }
  // }

  static Future<String> getCookiePath() async {
    Directory tempDir = await getApplicationDocumentsDirectory();
    String tempPath = "${tempDir.path}/.vvex_cookie";
    Directory dir = Directory(tempPath);
    bool b = await dir.exists();
    if (!b) {
      dir.createSync(recursive: true);
    }
    return tempPath;
  }

  // 外链跳转
  // static launchURL(String url) async {
  //   // 处理有些链接是 //xxxx 形式
  //   if (url.startsWith('//')) {
  //     url = 'https:$url';
  //   }

  //   if (await canLaunch(url)) {
  //     await launch(url,
  //         statusBarBrightness: Platform.isIOS ? Brightness.light : null);
  //   } else {
  //     Progresshud.showErrorWithStatus('Could not launch $url');
  //   }
  // }

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

  static void routeProfile(memberId, memberAvatar) {
    Navigator.push(
      Routes.navigatorKey.currentContext!,
      MaterialPageRoute(
        builder: (context) => ProfilePage(
          memberId: memberId,
          memberAvatar: memberAvatar,
        ),
      ),
    );
  }
}
