
import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_v2ex/http/init.dart';
import 'package:flutter_v2ex/utils/utils.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

class setCookie {
  static onSet(List cookiesList, String url) async {
    // 接收 flutter_inappwebview Cookie List
    // domain url
    List<Cookie> jarCookies = [];
    if(cookiesList.isNotEmpty){
      for(var i in cookiesList) {
        Cookie jarCookie = Cookie(
            i.name,
            i.value
        );
        jarCookies.add(jarCookie);
      }
    }
    String cookiePath = await Utils.getCookiePath();
    PersistCookieJar cookieJar = PersistCookieJar(
      ignoreExpires: true,
      storage: FileStorage(cookiePath),
    );
    await cookieJar.saveFromResponse(
        Uri.parse("https://www.v2ex.com/"), jarCookies);
    // 重新设置 cookie
    Request().dio.interceptors.add(CookieManager(cookieJar));
    return true;
  }
}