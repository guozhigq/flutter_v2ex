import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_v2ex/models/web/item_tab_topic.dart';
import 'package:flutter_v2ex/models/web/item_topic_reply.dart';
import 'package:flutter_v2ex/models/web/item_topic_subtle.dart';
import 'package:flutter_v2ex/models/web/model_topic_detail.dart';

Future<void> initHive() async {
  var databasesPath = await getApplicationSupportDirectory();
  //Hive.init('./');
  await Hive.initFlutter('${databasesPath.path}/hive_db');

  Hive.registerAdapter(TabTopicItemAdapter()); // 话题列表item
  Hive.registerAdapter(TopicDetailModelAdapter()); // 话题详情
  Hive.registerAdapter(ReplyItemAdapter()); // 回复item
  Hive.registerAdapter(TopicSubtleItemAdapter()); // 附言item

  // 打开历史浏览盒子
  await Hive.openBox('recentTopicsBox');
  // 历史搜索
  await Hive.openBox('recentSearchBox');
}

void closeHive() {
  Hive.close();
}