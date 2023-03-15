import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_v2ex/http/init.dart';

class SoV2ex {
  static Future onSearch(String q, int from, int size, {String sort  = 'created', int order = 0, int gte = 0, int lte = 0 } ) async {
    // sort 排序方式 （默认 sumup) ｜ sumup（权重）created（发帖时间）
    // order 升降序，sort 为 created 时有效（默认 降序）｜ 0（降序）, 1（升序）
    Response response;
    print('soV2ex gte: $gte');
    print('soV2ex lte: $lte');
    Options options = Options();
    Map<String, dynamic> data = {
      'q': q,
      'from': from,
      'size': size,
      'sort': sort,
      'order': order,
      'gte': gte,
      'lte': lte
    };
    if(gte!= 0){
      data['gte'] = gte;
      data['lte'] = DateTime.now().millisecondsSinceEpoch~/1000;
    }
    if(lte!= 0){
      data['lte'] = lte;
    }
    response = await Request().get(
      'https://www.sov2ex.com/api/search',
      data: data,
      options: options,
    );
    return SoV2exRes.fromMap(response.data);
  }
}

class SoV2exRes {
  int took = 0;
  bool timedOut = false;
  int total = 0;
  List<HitsList> hits = [];

  static SoV2exRes fromMap(Map<String, dynamic> map){
    SoV2exRes soV2exRes = SoV2exRes();
    soV2exRes.took = map['took'];
    soV2exRes.timedOut = map['timed_out'];
    soV2exRes.total = map['total'];
    soV2exRes.hits = HitsList.fromMapList(map['hits'], soV2exRes.total);

    return soV2exRes;
  }
}

class HitsList {
  String index = '';
  String type = '';
  String id = '';
  double score = 0.0;
  SourceMap source = SourceMap();
  HighlightList highlight = HighlightList();

  static List<HitsList> fromMapList(List mapList, total) {
    List<HitsList> list = [];
    for (int i = 0; i < mapList.length; i++) {
      list.add(fromMap(mapList[i]));
    }
    return list;
  }

  static HitsList fromMap(Map<String, dynamic> map) {
    HitsList hitsList = HitsList();
    hitsList.index = map['_index'];
    hitsList.type = map['_type'];
    hitsList.id = map['_id'];
    hitsList.score = map['_score'] ?? 0.0;
    hitsList.source = SourceMap.fromMap(map['_source']);
    hitsList.highlight = HighlightList.fromMap(map['highlight']);
    return hitsList;
  }
}

class SourceMap {
  int node = 0;
  int replies = 0;
  String created = '';
  String member = '';
  int id = 0;
  String title = '';
  String content = '';

  static SourceMap fromMap(Map<String, dynamic> map) {
    SourceMap sourceMap = SourceMap();
    sourceMap.created = map['created'].split('T').join(' ');
    sourceMap.member = map['member'];
    sourceMap.title = map['title'];
    sourceMap.content = map['content'];
    sourceMap.node = map['node'];
    sourceMap.replies = map['replies'];
    sourceMap.id = map['id'];
    return sourceMap;
  }
}

class HighlightList {
  List<String> reply_list = [];
  List<String> title = [];
  List<String> postscript_list = [];
  List<String> content = [];

  static HighlightList fromMap(Map<String, dynamic> map) {
    HighlightList highlightList = HighlightList();
    if(map['reply_list.content'] != null) {
      List<dynamic> reply_list = map['reply_list.content'];
      highlightList.reply_list.addAll(reply_list.map((e) => e.toString()));
    }
    if(map['title'] != null) {
      List<dynamic> title = map['title'];
      highlightList.title.addAll(title.map((e) => e.toString()));
    }
    if(map['postscript_list.content'] != null) {
      List<dynamic> postscript_list = map['postscript_list.content'];
      highlightList.postscript_list.addAll(postscript_list.map((e) => e.toString()));
    }
    if(map['content'] != null) {
      List<dynamic> content = map['content'];
      highlightList.content.addAll(content.map((e) => e.toString()));
    }

    return highlightList;
  }

}
