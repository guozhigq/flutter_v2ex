import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_v2ex/models/web/model_login_detail.dart';

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

  @override
  void initState() {
    super.initState();
    getSignKey();
  }

  Future<LoginDetailModel> getSignKey() async {
    var res = await DioRequestWeb.getLoginKey();
    setState(() {
      loginKey = res;
    });
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.close),
              onPressed: () =>
                Get.back(result: {
                  'loginStatus': 'cancel'
                }),
            );
          },
        ),
        actions: [TextButton(onPressed: () => {}, child: const Text('注册账号'))],
      ),
      body: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          Form(
            key: _formKey, //设置globalKey，用于后面获取FormState
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
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
                  child: Stack(
                    children: [
                      TextFormField(
                        controller: _codeController,
                        keyboardType: TextInputType.text,
                        focusNode: captchaTextFieldNode,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          labelText: '验证码',
                        ),
                        validator: (v) {
                          return v!.trim().isNotEmpty ? null : "验证码不能为空";
                        },
                        onSaved: (val) {
                          _code = val;
                        },
                      ),
                      if (loginKey.captchaImg != '') ...[
                        Positioned(
                          right: 0,
                          top: 0,
                          height: 64,
                          child: Container(
                            clipBehavior: Clip.hardEdge,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(6),
                                bottomRight: Radius.circular(6),
                              ),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  getSignKey();
                                });
                              },
                              // child: CachedNetworkImage(
                              //   imageUrl: loginKey.captchaImg,
                              //   width: 200,
                              //   alignment: Alignment.centerLeft,
                              //   fadeOutDuration:
                              //       const Duration(milliseconds: 600),
                              //   fit: BoxFit.fitHeight,
                              //   progressIndicatorBuilder:
                              //       (context, url, downloadProgress) =>
                              //           const Center(
                              //     child: Text('加载中...'),
                              //   ),
                              // ),
                              child: Image.memory(
                                loginKey.captchaImgBytes!,
                                height: 64.0,
                                // width: 200.0,
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
                Container(
                  height: 94,
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50)),
                    child: Text(
                      '登录',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    onPressed: () async {
                      if ((_formKey.currentState as FormState).validate()) {
                        //验证通过提交数据
                        (_formKey.currentState as FormState).save();
                        loginKey.userNameValue = _userName!;
                        loginKey.passwordValue = _password!;
                        loginKey.codeValue = _code!;
                        // 键盘收起
                        captchaTextFieldNode.unfocus();
                        var result = await DioRequestWeb.onLogin(loginKey);
                        if (result == 'true') {
                          Get.back(result: {
                            'loginStatus': 'finish'
                          });
                        } else {
                          getSignKey();
                        }
                      }
                    },
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    '忘记密码？',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 30,
            child: TextButton(
              onPressed: () => {},
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
