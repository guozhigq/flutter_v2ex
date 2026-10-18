import 'package:dio/dio.dart';
import 'package:flutter_v2ex/utils/login.dart';
import 'package:flutter_v2ex/utils/storage.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 请求之前
    // 在请求之前添加头部或认证信息
    // options.headers['Authorization'] = 'Bearer token';
    // options.headers['Content-Type'] = 'application/json';
    loginAuth(options.path, options.method);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    loginAuth(
      // response.realUri.toString(),
      response.requestOptions.path,
      response.requestOptions.method,
      redirtct: response.realUri.toString(),
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 处理网络请求错误
    // handler.next(err);
    if (err.requestOptions.extra['silentError'] != true) {
      SmartDialog.showToast(
        await dioError(err),
        displayType: SmartToastType.onlyRefresh,
      );
    }
    super.onError(err, handler);
  }

  static Future<String> dioError(DioException error) async {
    switch (error.type) {
      case DioExceptionType.badCertificate:
        return '证书有误！';
      case DioExceptionType.badResponse:
        return '服务器异常，请稍后重试！';
      case DioExceptionType.cancel:
        return "请求已被取消，请重新请求";
      case DioExceptionType.connectionError:
        return '连接错误，请检查网络设置';
      case DioExceptionType.connectionTimeout:
        return "网络连接超时，请检查网络设置";
      case DioExceptionType.receiveTimeout:
        return "响应超时，请稍后重试！";
      case DioExceptionType.sendTimeout:
        return "发送请求超时，请检查网络设置";
      case DioExceptionType.unknown:
        return "网络异常，请稍后重试！";
    }
  }

  // 登录验证
  loginAuth(reqPath, method, {redirtct}) {
    bool needLogin = !(GStorage().getLoginStatus());
    if (reqPath != '/write' && method == 'GET' && redirtct == '/2fa') {
      SmartDialog.dismiss();
      Login.twoFADialog();
      throw ('2fa验证');
    }
    bool authUrl = reqPath.startsWith('/favorite') ||
        reqPath.startsWith('/thank') ||
        reqPath.startsWith('/ignore') ||
        reqPath.startsWith('/report');
    if ((needLogin && authUrl) ||
        (needLogin && method == 'POST' && reqPath.startsWith('/t'))) {
      SmartDialog.dismiss();
      Login.loginDialog(
        '该操作需要登录',
        title: '权限不足',
        cancelText: '返回',
      );
      throw ('该操作需要登录！');
    }
  }
}
