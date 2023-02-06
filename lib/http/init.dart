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

String reqCookie = 'cf_clearance=sDEwyv8l1D3JaxndDewBLcOgp9TJe1eMC_0c.JuK2P4-1675239032-0-150; _ga=GA1.2.1710244246.1675527700; V2EX_LANG=zhcn; V2EX_REFERRER="2|1:0|10:1675584821|13:V2EX_REFERRER|16:Y2hlbnBlaTQ2Ng==|c6a531ddfcc08f43ae88a733685054fd78f1493879c9a13a4159038cf6ef9f90"; A2="2|1:0|10:1675644381|2:A2|56:MzZhZjViMDEwMmNjYWI4MjI2ODhhNDZjMWM2N2M2ZDRhZDZhMTJlOA==|2068c4286dd124f859c4b47e3ebaf5a735c477407d1afdcb70a30e72eb1104b5"; V2EXTP="2|1:0|10:1675644848|6:V2EXTP|36:eyI5MDQ5NDAiOiAzLCAiOTA0OTQwIjogM30=|e9a2b78fa61cbc2a5c1b108035dd3abe0f26da09b74c39f8b268e1c369dd1760"; PB3_SESSION="2|1:0|10:1675672821|11:PB3_SESSION|36:djJleDoyMDIuOC4xMDQuMzA6NTk4NjA1Mjc=|54fe8468090ba837eec46d51042c6987beb4f39d8aeccc29c8285d1477cfc950"; V2EX_TAB="2|1:0|10:1675675421|8:V2EX_TAB|8:dGVjaA==|f4e297caab26c46b4a03fd8c96d1110257ffbe4f1bfee5f7eb1adb97ad2329c8"';

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
        // return 'PROXY 172.16.32.186:7890';
        return 'PROXY localhost:7890';
        // return 'PROXY 127.0.0.1:7890';
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
    Options options = Options();
    String ua = extra!['ua'] ?? 'mob';
    // String channel = extra['channel'] ?? 'web';
    if (ua == 'mob') {
      options.headers = {
        'user-agent': Platform.isIOS
            ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1'
            : 'Mozilla/5.0 (Linux; Android 4.4.2; Nexus 4 Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.75 Mobile Safari/537.36'
      };
    } else {
      print('else');
      // options.headers = {'user-agent': ''};
      options.headers = {
        'user-agent':
            'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36'
      };
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
  post(url, {data, options, cancelToken, extra}) async {
    print('post-data: $data');
    Response response;
    try {
      response = await dio.post(
        url,
        data: data,
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
        return "网络连接超时，请检查网络设置";
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
