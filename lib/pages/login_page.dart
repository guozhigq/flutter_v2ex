import 'package:flutter/material.dart';
import 'package:flutter_v2ex/http/init.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
  var codeImg =
      'https://www.v2ex.com/_captcha?now=${DateTime.now().millisecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    // getCodeImg();
  }

  Future getCodeImg() async {
    var res = await Request().get(
        '/_captcha?now=${DateTime.now().millisecondsSinceEpoch}',
        extra: {});
    setState(() {
      codeImg = res;
      print(codeImg);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          Container(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).padding.top + 100),
            child: Expanded(
              child: Form(
                key: _formKey, //设置globalKey，用于后面获取FormState
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '登录',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Text('使用您的v2ex账号',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 50),
                    Container(
                      // height: 70,
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
                      child: TextFormField(
                        autofocus: true,
                        controller: _userNameController,
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
                      ),
                    ),
                    Container(
                      // height: 70,
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          labelText: '密码',
                        ),
                        //校验密码
                        validator: (v) {
                          return v!.trim().length > 5 ? null : "密码不能少于6位";
                        },
                      ),
                    ),
                    Container(
                      // height: 70,
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
                      child: Stack(
                        children: [
                          TextFormField(
                            controller: _codeController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              labelText: '验证码',
                            ),
                            validator: (v) {
                              return v!.trim().isNotEmpty ? null : "验证码不能为空";
                            },
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              clipBehavior: Clip.hardEdge,
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(6)),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    codeImg =
                                        'https://www.v2ex.com/_captcha?now=${DateTime.now().millisecondsSinceEpoch}';
                                  });
                                },
                                child: CachedNetworkImage(
                                    imageUrl: codeImg,
                                    width: 200,
                                    alignment: Alignment.centerLeft,
                                    fadeOutDuration:
                                        const Duration(milliseconds: 600),
                                    fit: BoxFit.fitHeight,
                                    progressIndicatorBuilder:
                                        (context, url, downloadProgress) =>
                                            const Center(
                                              child: Text('加载中...'),
                                            )),
                              ),
                            ),
                          ),
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
                        onPressed: () {
                          if ((_formKey.currentState as FormState).validate()) {
                            //验证通过提交数据
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
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 14,
            right: 14,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: '取消登录',
                  onPressed: () => {Navigator.pop(context)},
                  icon: const Icon(
                    Icons.close,
                    size: 28,
                  ),
                ),
                TextButton(onPressed: () => {}, child: const Text('注册账号'))
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
