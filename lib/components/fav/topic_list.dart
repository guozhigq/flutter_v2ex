import 'package:flutter/material.dart';
import 'package:flutter_v2ex/models/web/item_tab_topic.dart';
import 'package:flutter_v2ex/components/home/list_item.dart';
import 'package:flutter_v2ex/components/common/pull_refresh.dart';
import 'package:flutter_v2ex/models/web/model_topic_fav.dart';
import 'package:flutter_v2ex/http/dio_web.dart';

class FavTopicList extends StatefulWidget {
  const FavTopicList({super.key});

  @override
  State<FavTopicList> createState() => _FavTopicListState();
}

class _FavTopicListState extends State<FavTopicList>
    with AutomaticKeepAliveClientMixin {
  bool _isLoading = true;
  List<TabTopicItem> topicList = [];
  late int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    //
    getTopics();
  }

  Future<FavTopicModel> getTopics() async {
    FavTopicModel res = await DioRequestWeb.getFavTopics(_currentPage + 1);
    setState(() {
      _isLoading = false;
      topicList = res.topicList;
      _currentPage = _currentPage + 1;
    });
    return res;
  }

  Future getTopicsInt() async {
    getTopics();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return !_isLoading
        ? topicList.isNotEmpty
            ? Container(
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.only(right: 12, top: 8, left: 12),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                // TODO： onLoad
                child: PullRefresh(
                  onChildRefresh: getTopicsInt,
                  onChildLoad: () {},
                  currentPage: 0,
                  totalPage: 1,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 1, bottom: 0),
                    physics: const ClampingScrollPhysics(), //重要
                    itemCount: topicList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListItem(topic: topicList[index]);
                    },
                  ),
                ),
              )
            : const Text('没有数据')
        : showLoading();
  }

  Widget showLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(
            strokeWidth: 3,
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
