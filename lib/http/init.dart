import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:dio/adapter.dart';
import 'package:flutter/foundation.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_v2ex/utils/utils.dart';
import 'package:flutter_v2ex/utils/string.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio_http2_adapter/dio_http2_adapter.dart';
// import 'package:dio_smart_retry/dio_smart_retry.dart'; // dio 重试

String reqCookie = '';

class Request {
  static final Request _instance = Request._internal();

  factory Request() => _instance;

  Dio dio = Dio()
    ..httpClientAdapter = Http2Adapter(
      ConnectionManager(
        idleTimeout: 10000,
        // Ignore bad certificate
        onClientCreate: (_, config) => config.onBadCertificate = (_) => true,
      ),
    );

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

  ///设置cookie
  void _getLocalFile() async {
    var cookiePath = await Utils.getCookiePath();
    var cookieJar =
        PersistCookieJar(ignoreExpires: true, storage: FileStorage(cookiePath));
    dio.interceptors.add(CookieManager(cookieJar));
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

    _getLocalFile();
    //添加拦截器
    dio.interceptors
      // ..add(CookieManager(cookieJar))
      ..add(LogInterceptor())
      ..add(DioCacheManager(CacheConfig(baseUrl: Strings.v2exHost)).interceptor)
      // ..add(RetryInterceptor(
      //   dio: dio,
      //   logPrint: print, // specify log function
      //   retries: 3, // retry count
      //   retryDelays: const [
      //     Duration(seconds: 10), // wait 1 sec before first retry
      //     Duration(seconds: 2), // wait 2 sec before second retry
      //     Duration(seconds: 3), // wait 3 sec before third retry
      //   ],
      // ))
      ..add(
        InterceptorsWrapper(
          onRequest: (RequestOptions options, handler) {
            print("请求之前");
            return handler.next(options);
          },
          onResponse: (Response response, handler) {
            // 更新用户信息 消息计数 ...
            print("响应之前");
            return handler.next(response);
          },
          onError: (DioError e, handler) {
            // print("错误之前");
            SmartDialog.showToast(e.message,
                displayTime: const Duration(seconds: 3));
            return handler.next(e);
          },
        ),
      );
    // (dio.transformer as DefaultTransformer).jsonDecodeCallback = parseJson;
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      // config the http client
      client.findProxy = (uri) {
        // proxy all request to localhost:8888
        // return 'PROXY 192.168.1.60:7890';
        // return 'PROXY 172.16.48.249:7890';
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
  }

  /*
   * get请求
   */
  get(url, {data, cacheOptions, options, cancelToken, extra}) async {
    Response response;
    Options options;
    String ua = 'mob';
    bool cache = false;
    ResponseType resType = ResponseType.json;
    if (extra != null) {
      ua = extra!['ua'] ?? 'mob';
      cache = extra!['cache'] ?? false;
      resType = extra!['resType'] ?? ResponseType.json;
    }
    // String channel = extra['channel'] ?? 'web';
    if (cacheOptions != null) {
      // Options cacheOptions = buildCacheOptions(const Duration(days: 7),
      //     options: Options(
      //       headers: {'user-agent': headerUa(ua)},
      //     ));
      // Options cacheOptions = buildCacheOptions(
      //     customOptions,
      //     options: Options(
      //             headers: {'user-agent': headerUa(ua)},
      //           )
      // );
      // options = cacheOptions;
      cacheOptions.headers = {'user-agent': headerUa(ua)};
      options = cacheOptions;
    } else {
      options = Options();
      options.headers = {'user-agent': headerUa(ua)};
      options.responseType = resType;
    }
    try {
      response = await dio.get(
        url,
        queryParameters: data,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioError catch (e, handler) {
      print('get error---------$e');
      int statusCode = e.response!.statusCode!;
      // if(statusCode == 503){
      //   return handleError(statusCode);
      // }else{
        return Future.error(_dioError(e));
      // }
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
        // print("$count $total");
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

  String headerUa(ua) {
    String headerUa = '';
    if (ua == 'mob') {
      headerUa = Platform.isIOS
          ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1'
          : 'Mozilla/5.0 (Linux; Android 4.4.2; Nexus 4 Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.75 Mobile Safari/537.36';
    } else {
      headerUa =
          'Mozilla/5.0 (MaciMozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36';
    }
    return headerUa;
  }

  handleError(error) async{
    print('266： ${error.toString()}');
    Response response = await dio.get('https://www.v2ex.com/my/following?p=1');
    return response;
    // try {
    // if (
    // isObjectLike(error) &&
    // isObjectLike(error.config) &&
    // error.message.includes(`503`) &&
    // error.config.method === 'get' &&
    // !error.config.url.startsWith('http')
    // ) {
    // const open503UrlTime = await store.get(open503UrlTimeAtom)
    // if (dayjs().diff(open503UrlTime, 'hour') > 8) {
    // store.set(open503UrlTimeAtom, Date.now())
    // openURL(`${baseURL}${error.config.url}`)
    // }
    // }
    // } catch {
    // // empty
    // }
  }
}
