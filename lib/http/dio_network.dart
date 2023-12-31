import 'package:dio/dio.dart';
import 'package:flutter_v2ex/http/init.dart';
// import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter_v2ex/models/network/item_node.dart';
import 'package:flutter_v2ex/models/network/item_topic.dart';
import 'package:flutter_v2ex/models/network/item_node_topic.dart';

class DioRequestNet {
  // 所有节点
  final String allNodes = '/api/nodes/all.json';

  // 所有节点 topic
  final String allNodesT =
      '/api/nodes/list.json';

  // 热议
  final String hotTopics = '/api/topics/hot.json';

  // var cacheOptions = buildCacheOptions(
  //   const Duration(days: 4),
  //   forceRefresh: false,
  // );

  // 所有节点
  static Future<List<NodeItem>> getAllNodes() async {
    Response response = await Request().get(
      DioRequestNet().allNodes,
      // cacheOptions: DioRequestNet().cacheOptions,
    );
    List<dynamic> list = response.data;
    return list.map((e) => NodeItem.fromJson(e)).toList();
  }

  // 热议
  static Future<List<TopicItem>> getHotTopic() async {
    Response response = await Request().get(
      DioRequestNet().hotTopics,
    );
    List<dynamic> list = response.data;
    return list.map((e) => TopicItem.fromJson(e)).toList();
  }

  // 所有节点 topic
  static Future<List<TopicNodeItem>> getAllNodesT() async {
    Response response = await Request().get(
      DioRequestNet().allNodesT,
      data: {
        'fields': 'name,title,topics,aliases',
        'sort_by': 'topics',
        'reverse': 1
      },
      // cacheOptions: DioRequestNet().cacheOptions,
    );
    List<dynamic> list = response.data;
    return list.map((e) => TopicNodeItem.fromJson(e)).toList();
  }

}
