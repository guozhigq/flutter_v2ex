// import 'package:flutter_v2ex/models/web/item_node_list.dart';
// 某节点下的主题列表
import 'package:flutter_v2ex/models/web/item_tab_topic.dart';

class NodeListModel {
  String nodeId = ''; // 节点id
  String nodeName = ''; // 节点名称
  String nodeIntro = ''; // 节点描述
  String topicCount = ''; // 主题数量
  bool isFavorite = false; // 是否收藏节点
  int favoriteCount = 0; // 收藏人数
  int totalPage = 1; // 总页数
  String nodeCover = ''; // 封面

  late List<TabTopicItem> topicList;
}
