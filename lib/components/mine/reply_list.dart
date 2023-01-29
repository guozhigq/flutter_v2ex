import 'package:flutter/material.dart';
import 'package:flutter_v2ex/components/common/pull_refresh.dart';
import 'package:flutter_v2ex/components/mine/reply_item.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:flutter_v2ex/models/web/item_member_reply.dart';
import 'package:flutter_v2ex/models/web/model_member_reply.dart';

class ReplyList extends StatefulWidget {
  String memberId = '';
  ReplyList({required this.memberId, Key? key}) : super(key: key);

  @override
  State<ReplyList> createState() => _ReplyListState();
}

class _ReplyListState extends State<ReplyList>
    with AutomaticKeepAliveClientMixin {
  // ModelMemberReply replyListData = ModelMemberReply();
  List<MemberReplyItem> replyList = [];
  int _currentPage = 0;
  int _totalPage = 1;

  @override
  // TODO: implement wantKeepAlive
  bool wantKeepAlive = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    queryMemberReply();
  }

  Future<ModelMemberReply> queryMemberReply() async {
    var res = await DioRequestWeb.queryMemberReply(widget.memberId, _currentPage + 1);
    if (_currentPage == 0) {
      setState(() {
        replyList = res.replyList;
      });
    } else {
      setState(() {
        replyList.addAll(res.replyList);
      });
    }
    setState(() {
      _currentPage += 1;
      _totalPage = int.parse(res.totalPage);
    });
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return replyList.isNotEmpty
        ? PullRefresh(
            totalPage: _totalPage,
            currentPage: _currentPage,
            onChildLoad: queryMemberReply,
            onChildRefresh: ()  {
              setState(() {
                _currentPage = 0;
              });
              queryMemberReply();
            },
            child: content(),
          )
        : loading();
  }

  Widget content() {
    return CustomScrollView(
      slivers: [
        SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
          return ReplyItem(replyItem: replyList[index]);
        }, childCount: replyList.length))
      ],
    );
  }

  Widget loading() {
    return Center(child: Text('加载中'));
  }
}
