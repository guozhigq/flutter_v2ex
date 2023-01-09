import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
// import 'package:dio/adapter.dart';
import 'package:flutter_v2ex/utils/string.dart';

class Request {
  static final BaseOptions _options = BaseOptions(
    // baseUrl: Strings.v2exHost,
    baseUrl: 'https://www.baidu.com',
    connectTimeout: 12000,
    receiveTimeout: 12000,
    headers: {
      'Authorization': 'Bearer 68fb8a7e-d4c3-402c-99a1-8ff845f9dcb3',
      'user-agent': Platform.isIOS
          ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1'
          : 'Mozilla/5.0 (Linux; Android 4.4.2; Nexus 4 Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.75 Mobile Safari/537.36'
    },
    validateStatus: (status) {
      return status! >= 200 && status < 300 || status == 304 || status == 302;
    },
  );

  static final Dio _dio = Dio(_options);

  static Future<T> _request<T>(String path,
      {String method = 'get', required Map params, data, Map? extra}) async {
    // restful 请求处理
    params.forEach((key, value) {
      if (path.contains(key)) {
        path = path.replaceAll(":$key", value.toString());
      }
    });
    try {
      Response response = await _dio.request(path,
          data: data, options: Options(method: method));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
        // try {
        //   if (response.data['status'] != 200) {
        //     return Future.error(response.data['msg']);
        //   } else {
        //     if (response.data is Map) {
        //       return response.data;
        //     } else {
        //       return json.decode(response.data.toString());
        //     }
        //   }
        // } catch (e) {
        //   return Future.error('解析响应数据异常');
        // }
      } else {
        _handleHttpError(response.statusCode as int);
        return Future.error('HTTP错误');
      }
    } on DioError catch (e) {
      return Future.error(_dioError(e));
    } catch (e) {
      return Future.error('未知异常');
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

  // 处理 Http 错误码
  static void _handleHttpError(int errorCode) {
    String message;
    switch (errorCode) {
      case 400:
        message = '请求语法错误';
        break;
      case 401:
        message = '未授权，请登录';
        break;
      case 403:
        message = '拒绝访问';
        break;
      case 404:
        message = '请求出错';
        break;
      case 408:
        message = '请求超时';
        break;
      case 500:
        message = '服务器异常';
        break;
      case 501:
        message = '服务未实现';
        break;
      case 502:
        message = '网关错误';
        break;
      case 503:
        message = '服务不可用';
        break;
      case 504:
        message = '网关超时';
        break;
      case 505:
        message = 'HTTP版本不受支持';
        break;
      default:
        message = '请求失败，错误码：$errorCode';

        // ignore: avoid_print
        print(message);
    }
  }

  static Future<T> get<T>(String path,
      {required Map params, required Map<String, String> extra}) {
    return _request(path, method: 'get', params: params);
  }

  static Future<T> post<T>(String path, {required Map params, data}) {
    return _request(path, method: 'post', params: params, data: data);
  }
}
