import 'package:get_storage/get_storage.dart';
import 'package:flutter_v2ex/models/web/item_topic_reply.dart';

enum StoreKeys { token, userInfo, loginStatus, once, replyContent, replyItem}

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

  // once
  setOnce(int once) => _box.write(StoreKeys.once.toString(), once);
  int getOnce() => _box.read<int>(StoreKeys.once.toString()) ?? 0;

  // 回复内容
  setReplyContent(String content) => _box.write(StoreKeys.replyContent.toString(), content);
  String getReplyContent() => _box.read<String>(StoreKeys.replyContent.toString()) ?? '';

  setReplyItem(ReplyItem item) => _box.write(StoreKeys.replyItem.toString(), item);
  ReplyItem getReplyItem() => _box.read<ReplyItem>(StoreKeys.replyItem.toString()) ?? ReplyItem();

}