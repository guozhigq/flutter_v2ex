import 'package:get_storage/get_storage.dart';

enum StoreKeys { token, userInfo, loginStatus }

class Storage {
  static final Storage _storage = Storage._internal();
  final GetStorage _box = GetStorage();

  Storage._internal();

  factory Storage() => _storage;

  // setToken, getToken
  setToken(String token) => _box.write(StoreKeys.token.toString(), token);
  String getToken() => _box.read<String>(StoreKeys.token.toString())!;

  // 用户信息
  setUserInfo(Map info) => _box.write(StoreKeys.userInfo.toString(), info);
  Map getUserInfo() => _box.read<Map>(StoreKeys.userInfo.toString()) ??  {};

  // 签到状态
  setLoginStatus(bool status) => _box.write(StoreKeys.loginStatus.toString(), status);
  bool getLoginStatus() => _box.read<bool>(StoreKeys.loginStatus.toString()) ?? false;

}