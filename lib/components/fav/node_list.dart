import 'package:flutter/material.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:flutter_v2ex/models/web/model_node_fav.dart';
import 'package:flutter_v2ex/components/common/pull_refresh.dart';
import 'package:flutter_v2ex/components/fav/node_list_item.dart';

class FavNodeList extends StatefulWidget {
  const FavNodeList({super.key});

  @override
  State<FavNodeList> createState() => _FavNodeListState();
}

class _FavNodeListState extends State<FavNodeList>
    with AutomaticKeepAliveClientMixin {
  bool _isLoading = true;
  List<NodeFavModel> nodeList = [];
  late int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    //
    getNodes();
  }

  @override
  bool get wantKeepAlive => true;

  Future<List<NodeFavModel>> getNodes() async {
    List<NodeFavModel> res = await DioRequestWeb.getFavNodes();
    setState(() {
      _isLoading = false;
      nodeList = res;
      _currentPage = _currentPage + 1;
    });
    return res;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return !_isLoading
        ? nodeList.isNotEmpty
            ? Container(
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.only(right: 12, top: 8, left: 12),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: PullRefresh(
                  onChildRefresh: getNodes,
                  onChildLoad: () {},
                  currentPage: 0,
                  totalPage: 1,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 1, bottom: 0),
                    physics: const ClampingScrollPhysics(), //重要
                    itemCount: nodeList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return NodeListItem(nodeItem: nodeList[index]);
                    },
                  ),
                ),
              )
            : const Text('没有数据')
        : const Text('加载中');
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
