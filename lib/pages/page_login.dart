import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_v2ex/components/common/skeleton.dart';
import 'package:flutter_v2ex/utils/login.dart';
import 'package:flutter_v2ex/utils/utils.dart';
import 'package:flutter_v2ex/utils/string.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:flutter_v2ex/utils/storage.dart';
import 'package:flutter_v2ex/utils/event_bus.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_v2ex/models/web/model_login_detail.dart';
import 'package:flutter_v2ex/utils/logger.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final GlobalKey _formKey = GlobalKey<FormState>();

  var codeImg = '';
  late String? _userName;
  late String? _password;
  late String? _code;

  late LoginDetailModel loginKey = LoginDetailModel();
  final FocusNode userNameTextFieldNode = FocusNode();
  final FocusNode passwordTextFieldNode = FocusNode();
  final FocusNode captchaTextFieldNode = FocusNode();
  bool passwordVisible = true; // 默认隐藏密码
  bool _captchaLoading = false;
  String? _captchaError;
  CancelToken? _captchaRequest;

  @override
  void initState() {
    super.initState();
    getSignKey();
  }

  Future<void> getSignKey() async {
    if (!mounted || _captchaLoading) return;
    final request = CancelToken();
    _captchaRequest = request;
    setState(() {
      _captchaLoading = true;
      _captchaError = null;
      loginKey = LoginDetailModel();
      _codeController.clear();
    });
    try {
      final res = await DioRequestWeb.getLoginKey(cancelToken: request);
      if (!mounted || request.isCancelled) return;
      if (res.twoFa) {
        Login.twoFADialog();
      }
      setState(() {
        loginKey = res;
      });
    } catch (error) {
      if (!mounted || request.isCancelled) return;
      setState(() => _captchaError = error.toString());
    } finally {
      if (mounted && !request.isCancelled) {
        setState(() => _captchaLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _captchaRequest?.cancel('Login page closed');
    _userNameController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    userNameTextFieldNode.dispose();
    passwordTextFieldNode.dispose();
    captchaTextFieldNode.dispose();
    super.dispose();
  }

  Widget _captchaPlaceholder(BuildContext context) {
    final placeholder = ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const SizedBox.expand(),
    );
    return Semantics(
      key: const ValueKey('captcha-loading'),
      label: '验证码加载中',
      liveRegion: true,
      child: MediaQuery.disableAnimationsOf(context)
          ? placeholder
          : Skeleton(child: placeholder),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              tooltip: '关闭登录',
              icon: const Icon(Icons.close),
              onPressed: () => Get.back(result: {'loginStatus': 'cancel'}),
            );
          },
        ),
        actions: [
          TextButton(
              onPressed: () => Utils.openURL('https://www.v2ex.com/signup'),
              child: const Text('注册账号')),
          const SizedBox(width: 12)
        ],
      ),
      body: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          Form(
            key: _formKey, //设置globalKey，用于后面获取FormState
            autovalidateMode: AutovalidateMode.disabled,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 20),
                  Text(
                    '登录',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 10),
                  Text('使用您的v2ex账号',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 50),
                  Container(
                    // height: 70,
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
                    child: TextFormField(
                      controller: _userNameController,
                      focusNode: userNameTextFieldNode,
                      autofillHints: const [AutofillHints.username],
                      decoration: InputDecoration(
                        labelText: '用户名',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                      ),
                      // 校验用户名
                      validator: (v) {
                        return v!.trim().isNotEmpty ? null : "用户名不能为空";
                      },
                      onSaved: (val) {
                        _userName = val;
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: passwordVisible,
                      focusNode: passwordTextFieldNode,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        labelText: '密码',
                        suffixIcon: IconButton(
                          icon: Icon(
                            passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: () {
                            setState(() {
                              passwordVisible = !passwordVisible;
                            });
                          },
                        ),
                      ),
                      //校验密码
                      validator: (v) {
                        return v!.trim().length > 5 ? null : "密码不能少于6位";
                      },
                      onSaved: (val) {
                        _password = val;
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
                    child: TextFormField(
                      controller: _codeController,
                      keyboardType: TextInputType.text,
                      focusNode: captchaTextFieldNode,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        labelText: '验证码',
                        suffixIconConstraints: const BoxConstraints.tightFor(
                          width: 148,
                          height: 56,
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(
                              top: 3, bottom: 3, right: 3),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: _captchaLoading
                                ? _captchaPlaceholder(context)
                                : _captchaError != null
                                    ? Tooltip(
                                        message: _captchaError!,
                                        child: TextButton(
                                          onPressed: getSignKey,
                                          child: const Text('加载失败，重试'),
                                        ),
                                      )
                                    : InkWell(
                                        onTap: getSignKey,
                                        borderRadius: BorderRadius.circular(4),
                                        child: Tooltip(
                                          message: '点击刷新验证码',
                                          child:
                                              loginKey.captchaImgBytes == null
                                                  ? const Center(
                                                      child: Text('点击加载'))
                                                  : Image.memory(
                                                      loginKey.captchaImgBytes!,
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                      fit: BoxFit.fill,
                                                    ),
                                        ),
                                      ),
                          ),
                        ),
                      ),
                      validator: (v) {
                        return v!.trim().isNotEmpty ? null : "验证码不能为空";
                      },
                      onSaved: (val) {
                        _code = val;
                      },
                    ),
                  ),
                  Container(
                    height: 94,
                    padding: const EdgeInsets.all(20),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50)),
                      onPressed: _captchaLoading ||
                              loginKey.captchaImgBytes == null
                          ? null
                          : () async {
                              if ((_formKey.currentState as FormState)
                                  .validate()) {
                                TextInput.finishAutofillContext();
                                //验证通过提交数据
                                (_formKey.currentState as FormState).save();
                                loginKey.userNameValue = _userName!;
                                loginKey.passwordValue = _password!;
                                loginKey.codeValue = _code!;
                                // 键盘收起
                                captchaTextFieldNode.unfocus();
                                var result =
                                    await DioRequestWeb.onLogin(loginKey);
                                SmartDialog.dismiss(
                                    status: SmartStatus.loading);
                                if (!mounted) return;
                                if (result == 'true') {
                                  // 登录成功
                                  GStorage().setLoginStatus(true);
                                  Get.back(result: {'loginStatus': 'success'});
                                } else if (result == 'false') {
                                  // 登录失败
                                  setState(() {
                                    // _passwordController.value =
                                    //     const TextEditingValue(text: '');
                                    _codeController.value =
                                        const TextEditingValue(text: '');
                                  });
                                  getSignKey();
                                } else if (result == '2fa') {
                                  Login.twoFADialog();
                                }
                              }
                            },
                      child: Text(
                        '登录',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // TextButton(onPressed: () => Utils.launchURL('https://www.v2ex.com/signin'), child: Text(
                      //   '网页登录',
                      //   style: TextStyle(color: Colors.grey[600]),
                      // ),),
                      // const SizedBox(width: 10),
                      TextButton(
                        onPressed: () =>
                            Utils.openURL('https://www.v2ex.com/forgot'),
                        child: Text(
                          '忘记密码？',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 30,
            child: TextButton(
              onPressed: () async {
                int once = GStorage().getOnce();
                // Utils.openURL('https://www.v2ex.com/auth/google?once=$once');
                var result = await Get.toNamed('/webView', parameters: {
                  'aUrl': '${Strings.v2exHost}/auth/google?once=$once'
                });
                if (result != null && result['signInGoogle'] == 'success') {
                  SmartDialog.showLoading(msg: '获取信息...');
                  // 登录成功 获取用户信息 / 2FA
                  var signResult = await DioRequestWeb.getUserInfo();
                  if (signResult == 'true') {
                    // 登录成功
                    eventBus.emit('login', 'success');
                    Get.back(result: {'loginStatus': 'success'});
                  } else if (signResult == 'false') {
                    // 登录失败
                    SmartDialog.showToast('登录失败了');
                  } else if (result == '2fa') {
                    logDebug('login 需要两步验证 $result');
                    Login.twoFADialog();
                  }
                } else {
                  SmartDialog.showToast('取消登录');
                }
              },
              child: Row(children: [
                Image.asset('assets/images/google.png', width: 25, height: 25),
                const SizedBox(width: 10),
                Text('Sign in with Google',
                    style: Theme.of(context).textTheme.bodyMedium)
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
