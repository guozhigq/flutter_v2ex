import 'dart:typed_data';

class LoginDetailModel {
  String userNameHash = ''; // 用户名key 随机
  String passwordHash = ''; // 用户密码key 随机
  String codeHash = ''; // 验证码key 随机
  String once = ''; // 用户标识id 随机
  String captchaImg = ''; // 验证码图片 随机
  Uint8List? captchaImgBytes;
  String next = '/';

  String userNameValue = '';
  String passwordValue = '';
  String codeValue = '';

  bool twoFa = false;
}
