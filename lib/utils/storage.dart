import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_v2ex/utils/string.dart';
import 'package:flutter_v2ex/models/tabs.dart';
import 'package:flutter_v2ex/models/web/item_topic_reply.dart';

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
  expendAppBar,
  noticeOn,
  autoSign,
  eightQuery,
  globalFs,
  htmlFs,
  replyFs,
  tabs,
  autoUpdate,
  highlightOp,
  tempFs,
  sideslip,
  dragOffset,
  displayModeType
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

  List getNodes() => _box.read<List>(StoreKeys.nodes.toString()) ?? [];

  // 链接打开方式 默认应用内打开
  setLinkOpenInApp(bool value) =>
      _box.write(StoreKeys.linkOpenInApp.toString(), value);

  bool getLinkOpenInApp() =>
      _box.read<bool>(StoreKeys.linkOpenInApp.toString()) ?? true;

  // 拓展 appBar
  setExpendAppBar(bool value) =>
      _box.write(StoreKeys.expendAppBar.toString(), value);

  bool getExpendAppBar() =>
      _box.read<bool>(StoreKeys.expendAppBar.toString()) ?? false;

  // 消息通知
  setNoticeOn(bool value) => _box.write(StoreKeys.noticeOn.toString(), value);

  bool getNoticeOn() => _box.read<bool>(StoreKeys.noticeOn.toString()) ?? true;

  // 自动签到
  setAutoSign(bool value) => _box.write(StoreKeys.autoSign.toString(), value);

  bool getAutoSign() => _box.read<bool>(StoreKeys.autoSign.toString()) ?? true;

  setEightQuery(bool value) =>
      _box.write(StoreKeys.eightQuery.toString(), value);

  bool getEightQuery() =>
      _box.read<bool>(StoreKeys.eightQuery.toString()) ?? false;

  // 全局字体大小
  setGlobalFs(double value) => _box.write(StoreKeys.globalFs.toString(), value);

  double getGlobalFs() =>
      _box.read<double>(StoreKeys.globalFs.toString()) ?? 14;

  // html字体大小
  setHtmlFs(double value) => _box.write(StoreKeys.htmlFs.toString(), value);

  double getHtmlFs() => _box.read<double>(StoreKeys.htmlFs.toString()) ?? 15;

  // 回复字体
  setReplyFs(double value) => _box.write(StoreKeys.replyFs.toString(), value);

  double getReplyFs() => _box.read<double>(StoreKeys.replyFs.toString()) ?? 14;

  // 首页tabs
  setTabs(List<TabModel> value) => _box.write(StoreKeys.tabs.toString(), value);

  List<TabModel> getTabs() {
    List tabs = _box.read<List>(StoreKeys.tabs.toString()) ?? Strings.tabs;
    List<TabModel> list = [];
    for (var i in tabs) {
      list.add(i is TabModel ? i : TabModel.fromJson(i));
    }
    return list;
  }

  // 自动更新
  setAutoUpdate(bool value) => _box.write(StoreKeys.autoUpdate.toString(), value);

  bool getAutoUpdate() => _box.read<bool>(StoreKeys.autoUpdate.toString()) ?? true;

  // 自动更新
  setHighlightOp(bool value) => _box.write(StoreKeys.highlightOp.toString(), value);

  bool getHighlightOp() => _box.read<bool>(StoreKeys.highlightOp.toString()) ?? false;

  setTempFs(double value) => _box.write(StoreKeys.tempFs.toString(), value);

  double getTempFs() => _box.read<double>(StoreKeys.tempFs.toString()) ?? 14;

  // 侧滑返回
  setSideslip(bool value) => _box.write(StoreKeys.sideslip.toString(), value);

  bool getSideslip() => _box.read<bool>(StoreKeys.sideslip.toString()) ?? false;

  // iPad横屏拖拽距离
  setDragOffset(double value) => _box.write(StoreKeys.dragOffset.toString(), value);

  double getDragOffset() => _box.read<double>(StoreKeys.dragOffset.toString()) ?? 0.0;

  // 屏幕帧率
  // setDisplayModeType() => _box.write(key, value)

  setDisplayModeType(DisplayMode type) {
    return _box.write(StoreKeys.displayModeType.toString(), type.toString());
  }


  Future<DisplayMode> getDisplayModeType() async{
    var value = _box.read(StoreKeys.displayModeType.toString());
    DisplayMode f = DisplayMode.auto;
    if (value != null) {
      List<DisplayMode> modes = await FlutterDisplayMode.supported;
      f = modes.firstWhere((e) => e.toString() == value);
    }
    return f;
  }

}
