import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio/adapter.dart';
import 'package:flutter/foundation.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_v2ex/utils/utils.dart';
import 'package:flutter_v2ex/utils/string.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio_http_cache/dio_http_cache.dart';

String reqCookie =
    '_ga=GA1.2.612053446.1661838358; cf_clearance=w5gszBpOjxFGAsofiFwJxqxfmRkE27GOtrMm4x_OQp4-1672997746-0-150; V2EXTP="2|1:0|10:1673193021|6:V2EXTP|280:eyI4Nzg2MDMiOiAyLCAiOTAwNDU4IjogMiwgIjg5ODcxOCI6IDIsICI4ODMxNzMiOiAyLCAiODk5MDQ1IjogMiwgIjg3NjY2OCI6IDIsICI5MDY4MzQiOiAyLCAiOTA2OTI5IjogMiwgIjg3NzYxNCI6IDIsICI4NzI3ODciOiA1LCAiODk0MzMwIjogMiwgIjcxMTcwMSI6IDQsICIzMzkzNzEiOiAyLCAiODEyOTE0IjogMiwgIjg3NjM5MiI6IDIsICI5MDQyMjYiOiAyfQ==|43cdf44cc15322220d1b5ea1cef5369941072c0120e1a40e711d309130878310"; V2EX_LANG=zhcn; PB3_SESSION="2|1:0|10:1673795902|11:PB3_SESSION|36:djJleDoyMDIuOC4xMDQuMzA6NTI4MzU1NTk=|6d752b99437703c93e53b4209363dabb45109797e644e081167c82e74d1cf910"; V2EX_REFERRER="2|1:0|10:1673855615|13:V2EX_REFERRER|16:bW90ZWNzaGluZQ==|e3433970eb6c7803cee94b64a9368bd6377a057c06a767c43a863c50e2924edd"; A2="2|1:0|10:1673882557|2:A2|56:MzZhZjViMDEwMmNjYWI4MjI2ODhhNDZjMWM2N2M2ZDRhZDZhMTJlOA==|190fc2899cde15502eabd6b2a1d203df0b4f9ccb5b3accc5b34572762de89089"; V2EX_TAB="2|1:0|10:1673922445|8:V2EX_TAB|12:Y3JlYXRpdmU=|36e8c0360b1d9b4ad30859053e6ba8ef1562416593543ce46f1d2a98e494e25a"';

class Request {
  static final Request _instance = Request._internal();
  factory Request() => _instance;

  Dio dio = Dio();
  // final CancelToken _cancelToken = CancelToken();
  // static Request getInstance() {
  //   _instance ??= Request();
  //   return _instance;
  // }

  dynamic _parseAndDecode(String response) {
    return jsonDecode(response);
  }

  Future parseJson(String text) {
    return compute(_parseAndDecode, text);
  }

  /*
   * config it and create
   */
  Request._internal() {
    //BaseOptions、Options、RequestOptions 都可以配置参数，优先级别依次递增，且可以根据优先级别覆盖参数
    BaseOptions options = BaseOptions(
      //请求基地址,可以包含子路径
      baseUrl: Strings.v2exHost,
      //连接服务器超时时间，单位是毫秒.
      connectTimeout: 12000,
      //响应流上前后两次接受到数据的间隔，单位为毫秒。
      receiveTimeout: 12000,
      //Http请求头.
      headers: {
        'cookie': reqCookie,
        // 'Authorization': 'Bearer 68fb8a7e-d4c3-402c-99a1-8ff845f9dcb3',
        'user-agent': Platform.isIOS
            ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1'
            : 'Mozilla/5.0 (Linux; Android 4.4.2; Nexus 4 Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.75 Mobile Safari/537.36'
      },
      //请求的Content-Type，默认值是"application/json; charset=utf-8",Headers.formUrlEncodedContentType会自动编码请求体.
      // contentType: Headers.formUrlEncodedContentType,
      //表示期望以那种格式(方式)接受响应数据。接受四种类型 `json`, `stream`, `plain`, `bytes`. 默认值是 `json`,
      // responseType: ResponseType.plain,
    );

    dio = Dio(options);
    // var cookiePath = Utils.getCookiePath();
    // print('line 66: $cookiePath');

    // var cookieJar = PersistCookieJar(
    //   ignoreExpires: true,
    //   storage: FileStorage(cookiePath),
    // ); // 持久化 cookie
    // dio.interceptors
    //   ..add(CookieManager(cookieJar))
    //   ..add(LogInterceptor())
    //   ..add(
    //       DioCacheManager(CacheConfig(baseUrl: Strings.v2exHost)).interceptor);

    (dio.transformer as DefaultTransformer).jsonDecodeCallback = parseJson;
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      // config the http client
      client.findProxy = (uri) {
        // proxy all request to localhost:8888
        // return 'PROXY 192.168.1.60:7890';
        // return 'PROXY 172.16.48.249:7890';
        return 'PROXY localhost:7890';
        // return 'PROXY 127.0.0.1:9090';
        // 不设置代理 TODO 打包前关闭代理
        // return 'DIRECT';
      };
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      // return null;
      // you can also create a HttpClient to dio
      return client;
    };

    dio.options.validateStatus = (status) {
      return status! >= 200 && status < 300 || status == 304 || status == 302;
    };

    //Cookie管理
    // dio.interceptors.add(CookieManager(CookieJar()));

    //添加拦截器
    dio.interceptors
      // ..add(CookieManager(cookieJar))
      ..add(LogInterceptor())
      ..add(
          DioCacheManager(CacheConfig(baseUrl: Strings.v2exHost)).interceptor);
    (dio.transformer as DefaultTransformer).jsonDecodeCallback = parseJson;
    // dio.interceptors.add(

    //   // InterceptorsWrapper(
    //   //   onRequest: (RequestOptions options) {
    //   //     print("请求之前");
    //   //     return options; //continue
    //   //   },
    //   //   onResponse: (Response response) {
    //   //     print("响应之前");
    //   //     return response; // continue
    //   //   },
    //   //   onError: (DioError e) {
    //   //     print("错误之前");
    //   //     return e; //continue
    //   //   },
    //   // ),
    // );
  }

  /*
   * get请求
   */
  get(url, {data, options, cancelToken, extra}) async {
    Response response;
    String ua = extra!['ua'] ?? 'mob';
    // String channel = extra['channel'] ?? 'web';
    if (ua == 'mob') {
      options = Options(headers: {
        'cookie':
            '_ga=GA1.2.612053446.1661838358; cf_clearance=w5gszBpOjxFGAsofiFwJxqxfmRkE27GOtrMm4x_OQp4-1672997746-0-150; V2EXTP="2|1:0|10:1673193021|6:V2EXTP|280:eyI4Nzg2MDMiOiAyLCAiOTAwNDU4IjogMiwgIjg5ODcxOCI6IDIsICI4ODMxNzMiOiAyLCAiODk5MDQ1IjogMiwgIjg3NjY2OCI6IDIsICI5MDY4MzQiOiAyLCAiOTA2OTI5IjogMiwgIjg3NzYxNCI6IDIsICI4NzI3ODciOiA1LCAiODk0MzMwIjogMiwgIjcxMTcwMSI6IDQsICIzMzkzNzEiOiAyLCAiODEyOTE0IjogMiwgIjg3NjM5MiI6IDIsICI5MDQyMjYiOiAyfQ==|43cdf44cc15322220d1b5ea1cef5369941072c0120e1a40e711d309130878310"; V2EX_LANG=zhcn; PB3_SESSION="2|1:0|10:1673795902|11:PB3_SESSION|36:djJleDoyMDIuOC4xMDQuMzA6NTI4MzU1NTk=|6d752b99437703c93e53b4209363dabb45109797e644e081167c82e74d1cf910"; V2EX_REFERRER="2|1:0|10:1673855615|13:V2EX_REFERRER|16:bW90ZWNzaGluZQ==|e3433970eb6c7803cee94b64a9368bd6377a057c06a767c43a863c50e2924edd"; A2="2|1:0|10:1673882557|2:A2|56:MzZhZjViMDEwMmNjYWI4MjI2ODhhNDZjMWM2N2M2ZDRhZDZhMTJlOA==|190fc2899cde15502eabd6b2a1d203df0b4f9ccb5b3accc5b34572762de89089"; V2EX_TAB="2|1:0|10:1673922445|8:V2EX_TAB|12:Y3JlYXRpdmU=|36e8c0360b1d9b4ad30859053e6ba8ef1562416593543ce46f1d2a98e494e25a"',
        // 'Authorization': 'Bearer 68fb8a7e-d4c3-402c-99a1-8ff845f9dcb3',
        'user-agent': Platform.isIOS
            ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1'
            : 'Mozilla/5.0 (Linux; Android 4.4.2; Nexus 4 Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.75 Mobile Safari/537.36'
      });
    } else {
      print('else');
      options = Options(headers: {
        'cookie':
            '_ga=GA1.2.612053446.1661838358; cf_clearance=w5gszBpOjxFGAsofiFwJxqxfmRkE27GOtrMm4x_OQp4-1672997746-0-150; V2EXTP="2|1:0|10:1673193021|6:V2EXTP|280:eyI4Nzg2MDMiOiAyLCAiOTAwNDU4IjogMiwgIjg5ODcxOCI6IDIsICI4ODMxNzMiOiAyLCAiODk5MDQ1IjogMiwgIjg3NjY2OCI6IDIsICI5MDY4MzQiOiAyLCAiOTA2OTI5IjogMiwgIjg3NzYxNCI6IDIsICI4NzI3ODciOiA1LCAiODk0MzMwIjogMiwgIjcxMTcwMSI6IDQsICIzMzkzNzEiOiAyLCAiODEyOTE0IjogMiwgIjg3NjM5MiI6IDIsICI5MDQyMjYiOiAyfQ==|43cdf44cc15322220d1b5ea1cef5369941072c0120e1a40e711d309130878310"; V2EX_LANG=zhcn; PB3_SESSION="2|1:0|10:1673795902|11:PB3_SESSION|36:djJleDoyMDIuOC4xMDQuMzA6NTI4MzU1NTk=|6d752b99437703c93e53b4209363dabb45109797e644e081167c82e74d1cf910"; V2EX_REFERRER="2|1:0|10:1673855615|13:V2EX_REFERRER|16:bW90ZWNzaGluZQ==|e3433970eb6c7803cee94b64a9368bd6377a057c06a767c43a863c50e2924edd"; A2="2|1:0|10:1673882557|2:A2|56:MzZhZjViMDEwMmNjYWI4MjI2ODhhNDZjMWM2N2M2ZDRhZDZhMTJlOA==|190fc2899cde15502eabd6b2a1d203df0b4f9ccb5b3accc5b34572762de89089"; V2EX_TAB="2|1:0|10:1673922445|8:V2EX_TAB|12:Y3JlYXRpdmU=|36e8c0360b1d9b4ad30859053e6ba8ef1562416593543ce46f1d2a98e494e25a"',
        // 'Authorization': 'Bearer 68fb8a7e-d4c3-402c-99a1-8ff845f9dcb3',
        'user-agent': ''
      });
    }
    try {
      response = await dio.get(
        url,
        queryParameters: data,
        options: options,
        cancelToken: cancelToken,
      );
      // print('get success---------${response.statusCode}');
      // print('get success---------${response.data}');

//      response.data; 响应体
//      response.headers; 响应头
//      response.request; 请求体
//      response.statusCode; 状态码
      return response;
    } on DioError catch (e) {
      print('get error---------$e');
      return Future.error(_dioError(e));
    }
  }

  /*
   * post请求
   */
  post(url, {data, options, cancelToken}) async {
    Response response;
    try {
      response = await dio.post(
        url,
        queryParameters: data,
        options: options,
        cancelToken: cancelToken,
      );
      // print('post success---------${response.data}');
      return response;
    } on DioError catch (e) {
      print('post error---------$e');
      return Future.error(_dioError(e));
    }
  }

  /*
   * 下载文件
   */
  downloadFile(urlPath, savePath) async {
    Response response;
    try {
      response = await dio.download(urlPath, savePath,
          onReceiveProgress: (int count, int total) {
        //进度
        // print("$count $total");
      });
      // print('downloadFile success---------${response.data}');

      return response.data;
    } on DioError catch (e) {
      print('downloadFile error---------$e');
      return Future.error(_dioError(e));
    }
  }

  // 处理 Dio 异常
  static String _dioError(DioError error) {
    print(error);
    switch (error.type) {
      case DioErrorType.connectTimeout:
        return "ini.dart 网络连接超时，请检查网络设置";
      case DioErrorType.receiveTimeout:
        return "响应超时，请稍后重试！";
      case DioErrorType.sendTimeout:
        return "发送请求超时，请检查网络设置";
      case DioErrorType.response:
        return "服务器异常，请稍后重试！";
      case DioErrorType.cancel:
        return "请求已被取消，请重新请求";
      case DioErrorType.other:
        return "网络异常，请稍后重试！";
      default:
        return "Dio异常";
    }
  }

  /*
   * 取消请求
   *
   * 同一个cancel token 可以用于多个请求，当一个cancel token取消时，所有使用该cancel token的请求都会被取消。
   * 所以参数可选
   */
  void cancelRequests(CancelToken token) {
    token.cancel("cancelled");
  }
}
