import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_v2ex/utils/login.dart';
import 'package:flutter_v2ex/utils/storage.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // print("请求之前");
    // 在请求之前添加头部或认证信息
    // options.headers['Authorization'] = 'Bearer token';
    // options.headers['Content-Type'] = 'application/json';
    loginAuth(options.path, options.method);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // print("响应之前");
    loginAuth(
      // response.realUri.toString(),
      response.requestOptions.path,
      response.requestOptions.method,
      redirtct: response.realUri.toString(),
    );
    handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    // 处理网络请求错误
    SmartDialog.showToast(_dioError(err),
        displayTime: const Duration(seconds: 3));
    handler.next(err);
    // super.onError(err, handler);
  }

  static String _dioError(DioError error) {
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
      SmartDialog.show(
        useSystem: true,
        animationType: SmartAnimationType.centerFade_otherSlide,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('权限不足'),
            content: const Text('该操作需要登录'),
            actions: [
              TextButton(
                  onPressed: () {
                    SmartDialog.dismiss();
                  },
                  child: const Text('返回')),
              TextButton(
                  // TODO
                  onPressed: () {
                    SmartDialog.dismiss().then(
                        (res) => {Navigator.of(context).pushNamed('/login')});
                  },
                  child: const Text('去登录'))
            ],
          );
        },
      );
      throw ('该操作需要登录！');
    }
  }
}
