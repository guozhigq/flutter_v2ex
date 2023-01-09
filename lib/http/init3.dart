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

class Request {
  static final Request _instance = Request._internal();
  factory Request() => _instance;

  Dio dio = Dio();
  // final CancelToken _cancelToken = CancelToken();
  // static Request getInstance() {
  //   _instance ??= Request();
  //   return _instance;
  // }

  // var cookiePath = Utils.getCookiePath().then(
  //   (res) =>{
  //     print(res)
  //   }
  // );
  // var cookieJar = PersistCookieJar(
  //   ignoreExpires: true,
  //   storage: FileStorage(cookiePath),
  // );

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
      connectTimeout: 10000,
      //响应流上前后两次接受到数据的间隔，单位为毫秒。
      receiveTimeout: 5000,
      //Http请求头.
      headers: {
        'Authorization': 'Bearer 68fb8a7e-d4c3-402c-99a1-8ff845f9dcb3',
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

    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      // config the http client
      client.findProxy = (uri) {
        // proxy all request to localhost:8888
        // return 'PROXY 192.168.1.60: 7890';
        // return 'PROXY 172.16.32.186:7890';
        return 'PROXY localhost:7890';
        // return 'PROXY 127.0.0.1:9090';
        // 不设置代理 TODO 打包前关闭代理
        // return 'DIRECT';
      };
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return null;
      // you can also create a HttpClient to dio
      // return HttpClient();
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
        'Authorization': 'Bearer 68fb8a7e-d4c3-402c-99a1-8ff845f9dcb3',
        'user-agent': Platform.isIOS
            ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1'
            : 'Mozilla/5.0 (Linux; Android 4.4.2; Nexus 4 Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.75 Mobile Safari/537.36'
      });
    } else {
      options = Options(headers: {
        'Authorization': 'Bearer 68fb8a7e-d4c3-402c-99a1-8ff845f9dcb3',
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
      print('get success---------${response.statusCode}');
      print('get success---------${response.data}');

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
      print('post success---------${response.data}');
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
        print("$count $total");
      });
      print('downloadFile success---------${response.data}');

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
