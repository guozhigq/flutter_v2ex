// import 'package:flutter_v2ex/models/web/item_node_list.dart';
// 某节点下的主题列表
import 'package:flutter_v2ex/models/web/item_tab_topic.dart';

class NodeListModel {
  Map<String, dynamic> toCache() => {
        'nodeId': nodeId,
        'nodeName': nodeName,
        'nodeIntro': nodeIntro,
        'topicCount': topicCount,
        'isFavorite': isFavorite,
        'favoriteCount': favoriteCount,
        'totalPage': totalPage,
        'nodeCover': nodeCover,
        'topicList': topicList,
      };

  static NodeListModel fromCache(Map data) => NodeListModel()
    ..nodeId = data['nodeId']
    ..nodeName = data['nodeName']
    ..nodeIntro = data['nodeIntro']
    ..topicCount = data['topicCount']
    ..isFavorite = data['isFavorite']
    ..favoriteCount = data['favoriteCount']
    ..totalPage = data['totalPage']
    ..nodeCover = data['nodeCover']
    ..topicList = List<TabTopicItem>.from(data['topicList']);

  String nodeId = ''; // 节点id
  String nodeName = ''; // 节点名称
  String nodeIntro = ''; // 节点描述
  String topicCount = ''; // 主题数量
  bool isFavorite = false; // 是否收藏节点
  int favoriteCount = 0; // 收藏人数
  int totalPage = 1; // 总页数
  String nodeCover = ''; // 封面

  List<TabTopicItem> topicList = [];
}
