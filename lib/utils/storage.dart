import 'package:get_storage/get_storage.dart';

enum StoreKeys { token, refreshToken, userInfo }

class Storage {
  static final Storage _storage = Storage._internal();
  final GetStorage _box = GetStorage();

  GetStorage get box => _box;

  Storage._internal();

  factory Storage() => _storage;

  // setToken, getToken
  setToken(String token) => _box.write(StoreKeys.token.toString(), token);
  String? getToken() => _box.read<String>(StoreKeys.token.toString());

  // setRefreshToken, getRefreshToken
  setRefreshToken(String refreshToken) =>
      _box.write(StoreKeys.refreshToken.toString(), refreshToken);
  String? getRefreshToken() =>
      _box.read<String>(StoreKeys.refreshToken.toString());

}