// ignore_for_file: avoid_print

import 'dart:convert' show utf8, base64;
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_v2ex/utils/string.dart';
import 'package:flutter_v2ex/utils/upload.dart';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_v2ex/utils/storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class Utils {
//   static IosDeviceInfo iosInfo;
//   static AndroidDeviceInfo androidInfo;

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
      try {
        await InAppBrowser.openWithSystemBrowser(url: Uri.parse(aUrl));
      } catch (err) {
        SmartDialog.showToast(err.toString());
      }
    } else {
      // 2. openWithAppBrowser
      try {
        await ChromeSafariBrowser().open(url: Uri.parse(aUrl));
      } catch (err) {
        // SmartDialog.showToast(err.toString());
        // https://github.com/guozhigq/flutter_v2ex/issues/49
        GStorage().setLinkOpenInApp(false);
        try {
          await InAppBrowser.openWithSystemBrowser(url: Uri.parse(aUrl));
        } catch (err) {
          SmartDialog.showToast('openURL: $err');
        }
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

  // base64 解析 wechat
  static base64Decode(contentDom) {
    List decodeRes = [];
    try {
      String content = contentDom.text;
      RegExp exp = RegExp(r'[a-zA-Z\d=]{8,}');
      // RegExp exp2 = RegExp(
      //     r'^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{4}|[A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)$');
      var expMatch = exp.allMatches(content).toList();
      for (var i in expMatch) {
        var value = i.group(0);
        try {
          decodeRes.addAll(base64Resolve(value!, decodeRes));
        } catch (err) {
          // print(err);
        }
      }
      return decodeRes;
    } catch (err) {
      return decodeRes;
    }
  }

  //
  static base64Resolve(String str, decodeRes) {
    var wechat = '';
    var blacklist = Strings().base64BlackList;
    RegExp exp = RegExp(r'[a-zA-Z\d=]{4,}');
    str = str.trim();
    if (!blacklist.contains(str) && str.length % 4 == 0 ||
        (str.endsWith('%3D') && (str.length - 2) % 4 == 0)) {
      try {
        wechat = utf8.decode(base64.decode(str)).trim();
      } catch (err) {
        print('❌ base64Resolve error: $err');
      }
      RegExp wechatRegExp = RegExp(r'^_|[a-zA-Z][a-zA-Z\d_-]{5,19}$');
      RegExp emailRegExp =
          RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');
      if (wechat != '' &&
          (wechatRegExp.hasMatch(wechat) ||
              RegExp(r'^\d+$').hasMatch(wechat) ||
              emailRegExp.hasMatch(wechat))) {
        decodeRes.add(wechat);
      } else if (exp.allMatches(wechat).isNotEmpty &&
          !wechatRegExp.hasMatch(wechat) &&
          !RegExp(r'^\d+$').hasMatch(wechat)) {
        decodeRes.addAll(base64Resolve(wechat, decodeRes));
      } else {
        print('解析中断： $wechat');
      }
    } else {
      // print('err: 无效base64');
    }
    return decodeRes;
  }

  // 替换innerHtml中的文本链接
  static linkMatch(contentDom) {
    var innerHtml = contentDom.innerHtml;
    var innerContent = contentDom.text;

    // 暂时取消链接解析 https://www.v2ex.com/t/940105
    // RegExp linkRegExp = RegExp(r"^/go|/t/(\d+)");
    // var linkRes = linkRegExp.firstMatch(innerHtml);
    // if (linkRes != null) {
    //   var index = innerHtml.indexOf(linkRes.group(0));
    //   var lastWord = innerHtml[index - 1];
    //   if (lastWord != 'm') {
    //     var matchRes = linkRes.group(0);
    //     innerHtml = innerHtml.replaceAll(
    //         linkRegExp, "<a href='$matchRes'>$matchRes</a>");
    //   }
    // }

    // base64 替换
    RegExp base64RegExp = RegExp(r'[a-zA-Z\d=]{8,}');
    var base64Res = base64RegExp.allMatches(innerHtml);
    var wechat = '';
    for (var i in base64Res) {
      if (!Strings().base64BlackList.contains(i.group(0)) &&
          i.group(0)!.trim().length % 4 == 0) {
        try {
          wechat = utf8.decode(base64.decode(i.group(0)!));
        } catch (e) {
          print(e);
        }
        RegExp wechatRegExp = RegExp(r'^_|[a-zA-Z][a-zA-Z\d_-]{5,19}$');
        RegExp emailRegExp =
            RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');
        if (wechat != '' &&
            innerContent.contains(i.group(0)!) &&
            (wechatRegExp.hasMatch(wechat) ||
                RegExp(r'^\d+$').hasMatch(wechat) ||
                emailRegExp.hasMatch(wechat))) {
          try {
            innerHtml = innerHtml.replaceAll(i.group(0),
                '${i.group(0)} (<a href="base64Wechat: $wechat">$wechat</a>)');
          } catch (e) {}
        }
        print(wechat);
      }
    }

    return innerHtml;
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

  static openHrefByWebview(String? aUrl, BuildContext context) async {
    if (aUrl!.contains('base64Wechat')) {
      Clipboard.setData(ClipboardData(text: aUrl.split(':')[1]));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 3000),
          // showCloseIcon: true,
          content: Text('已复制【${aUrl.split(':')[1]}】'),
        ),
      );
      return;
    }
    RegExp exp = RegExp(
        r"((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?");
    RegExp v2exExp = RegExp(r"((https?:www\.)|(https?:\/\/)|(www\.))v2ex.com");
    RegExp linkExp = RegExp(r"^/go|/t|/member/");
    RegExp linkExp2 = RegExp(r"^<a(.*?)>(.*?)<\/a>$");
    bool isValidator = exp.hasMatch(aUrl);
    if (isValidator) {
      // http(s) 网址
      if (v2exExp.firstMatch(aUrl) != null) {
        // v2ex 链接 https://www.v2ex.com/t/919475#reply1
        List arr = aUrl.split('.com');
        // 获得链接 /t/919475#reply1 /t/919475?p=1 /t/919475?p=1#r_12345
        var tHref = arr[1];
        Map<String, String> parameters = {};
        if (linkExp.firstMatch(tHref) != null) {
          if (tHref.contains('p=')) {
            parameters['p'] = tHref.split('#r_')[0].split('p=')[1];
            if (tHref.contains('#r_')) {
              parameters['replyId'] = tHref.split('#r_')[1].toString();
            }
          }
          if (tHref.contains('#')) {
            // 去掉回复数  /t/919475#reply1
            // 获得链接 /t/919475
            tHref = tHref.split('#')[0].contains('?')
                ? tHref.split('#')[0].split('?')[0]
                : tHref.split('#')[0];
          }
          Get.toNamed(tHref, parameters: parameters);
        } else {
          Utils.openURL(aUrl);
        }
      } else {
        await Utils.openURL(aUrl);
      }
    } else if (aUrl.startsWith('/member/') ||
        aUrl.startsWith('/go/') ||
        aUrl.startsWith('/t/')) {
      if (aUrl.contains('#')) {
        aUrl = aUrl.split('#')[0];
      }
      Get.toNamed(aUrl);
    } else {
      // sms tel email schemeUrl
      final Uri url = Uri.parse(aUrl);
      if (await canLaunchUrl(url)) {
        launchUrl(url);
      } else if (linkExp2.hasMatch(aUrl)) {
        print(aUrl);
        try {
          String tagA =
              parse(aUrl).body!.querySelector('a')!.attributes['href']!;
          if (context.mounted) {
            openHrefByWebview(tagA, context);
          }
        } catch (err) {
          SmartDialog.showToast('openHref: $err');
          print(err);
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(milliseconds: 1000),
              // showCloseIcon: true,
              content: const Text('🔗链接打开失败'),
              action: SnackBarAction(
                label: '复制',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: aUrl!));
                },
              ),
            ),
          );
        }
        throw Exception('Could not launch $aUrl');
      }
    }
  }

  Future uploadImage() async {
    final List<AssetEntity>? assets = await AssetPicker.pickAssets(
      Get.context!,
      pickerConfig: const AssetPickerConfig(maxAssets: 1),
    );
    if (assets != null && assets.isNotEmpty) {
      SmartDialog.showLoading(msg: '上传中...');
      AssetEntity? file = assets[0];
      var res = await Upload.uploadImage('1', file);
      SmartDialog.dismiss();
      return res;
    }
    return ('no image selected');
  }
}
