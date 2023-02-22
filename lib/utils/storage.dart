import 'package:get_storage/get_storage.dart';
import 'package:flutter_v2ex/models/web/item_topic_reply.dart';
import 'package:flutter_v2ex/utils/string.dart';
import 'package:path_provider/path_provider.dart';

enum StoreKeys {
  token,
  userInfo,
  loginStatus,
  once,
  replyContent,
  replyItem,
  statusBarHeight,
  themeType,
  signStatus,
  nodes,
  linkOpenInApp,
}

class GStorage {
  static final GStorage _storage = GStorage._internal();
  final GetStorage _box = GetStorage();

  GStorage._internal();

  factory GStorage() => _storage;

  // setToken, getToken
  setToken(String token) => _box.write(StoreKeys.token.toString(), token);

  String getToken() => _box.read<String>(StoreKeys.token.toString())!;

  // 用户信息
  setUserInfo(Map info) => _box.write(StoreKeys.userInfo.toString(), info);

  Map getUserInfo() => _box.read<Map>(StoreKeys.userInfo.toString()) ?? {};

  // 登陆状态
  setLoginStatus(bool status) =>
      _box.write(StoreKeys.loginStatus.toString(), status);

  bool getLoginStatus() =>
      _box.read<bool>(StoreKeys.loginStatus.toString()) ?? false;

  // once
  setOnce(int once) => _box.write(StoreKeys.once.toString(), once);

  int getOnce() => _box.read<int>(StoreKeys.once.toString()) ?? 0;

  // 回复内容
  setReplyContent(String content) =>
      _box.write(StoreKeys.replyContent.toString(), content);

  String getReplyContent() =>
      _box.read<String>(StoreKeys.replyContent.toString()) ?? '';

  setReplyItem(ReplyItem item) =>
      _box.write(StoreKeys.replyItem.toString(), item);

  ReplyItem getReplyItem() =>
      _box.read<ReplyItem>(StoreKeys.replyItem.toString()) ?? ReplyItem();

  setStatusBarHeight(num height) =>
      _box.write(StoreKeys.statusBarHeight.toString(), height);

  num getStatusBarHeight() =>
      _box.read<num>(StoreKeys.statusBarHeight.toString()) ?? 0;

  // 主题风格 默认跟随系统
  setSystemType(ThemeType type) =>
      _box.write(StoreKeys.themeType.toString(), type.name.toString());

  clearSystemType() => _box.remove(StoreKeys.themeType.toString());

  ThemeType getSystemType() {
    var value = _box.read(StoreKeys.themeType.toString());
    ThemeType f = ThemeType.system;
    if (value != null) {
      f = ThemeType.values.firstWhere((e) => e.name.toString() == value);
    }
    return f;
  }

  // 签到状态
  setSignStatus(String date) =>
      _box.write(StoreKeys.signStatus.toString(), date);

  String getSignStatus() =>
      _box.read<String>(StoreKeys.signStatus.toString()) ?? '';

  // 节点信息
  setNodes(List data) => _box.write(StoreKeys.nodes.toString(), data);
  List getNodes() =>
      _box.read<List>(StoreKeys.nodes.toString()) ?? [];

  // 链接打开方式 默认应用内打开
  setLinkOpenInApp(bool value) => _box.write(StoreKeys.linkOpenInApp.toString(), value);
  bool getLinkOpenInApp() =>
      _box.read<bool>(StoreKeys.linkOpenInApp.toString()) ?? true;

}
