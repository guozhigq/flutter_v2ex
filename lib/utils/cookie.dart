
import 'dart:developer';
import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:flutter_v2ex/utils/utils.dart';
import 'package:flutter_v2ex/http/init.dart';

class setCookie {
  static onSet(List cookiesList, String url) async {
    // 接收 flutter_inappwebview Cookie List
    // domain url
    List<Cookie> jarCookies = [];
    for(var i in cookiesList) {
      print('🔥🔥: $i');
      print('🔥🔥🌲：${i.value}');
      print('🔥🔥🌲🌲：${i.name}');
      Cookie jarCookie = Cookie(
        i.name,
        i.value
      );
      jarCookies.add(jarCookie);
    }
    String cookiePath = await Utils.getCookiePath();
    PersistCookieJar cookieJar = PersistCookieJar(
      ignoreExpires: true,
      storage: FileStorage(cookiePath),
    );
    await cookieJar.saveFromResponse(
        Uri.parse("https://www.v2ex.com/"), jarCookies);
    print(await cookieJar.loadForRequest(Uri.parse("https://www.v2ex.com/")));
    // Response result = await  Request().get('https://www.v2ex.com/');
    // log(result.data);
  }
}