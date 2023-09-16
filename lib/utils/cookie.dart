import 'dart:io';
import 'package:flutter_v2ex/http/init.dart';

class SetCookie {
  static onSet(List cookiesList, String url) async {
    // 接收 flutter_inappwebview Cookie List
    // domain url
    List<Cookie> jarCookies = [];
    if (cookiesList.isNotEmpty) {
      for (var i in cookiesList) {
        Cookie jarCookie = Cookie(i.name, i.value);
        jarCookies.add(jarCookie);
      }
    }
    await Request.cookieManager.cookieJar
        .saveFromResponse(Uri.parse("https://www.v2ex.com/"), jarCookies);
    var cookieString =
        jarCookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
    Request.dio.options.headers['cookie'] = cookieString;

    return true;
  }
}
