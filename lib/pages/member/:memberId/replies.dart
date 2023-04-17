import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_v2ex/components/common/pull_refresh.dart';
import 'package:flutter_v2ex/components/member/reply_item.dart';
import 'package:flutter_v2ex/models/web/item_member_reply.dart';
import 'package:flutter_v2ex/models/web/model_member_reply.dart';
import 'package:flutter_v2ex/http/user.dart';

class MemberRepliesPage extends StatefulWidget {
  const MemberRepliesPage({Key? key}) : super(key: key);

  @override
  State<MemberRepliesPage> createState() => _MemberRepliesPageState();
}

class _MemberRepliesPageState extends State<MemberRepliesPage> {
  String memberId = '';
  final ScrollController _controller = ScrollController();
  ModelMemberReply replyListData = ModelMemberReply();
  List<MemberReplyItem> replyList = [];
  int _currentPage = 0;
  int _totalPage = 1;
  bool showBackTopBtn = false;
  bool _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    memberId = Get.parameters['memberId'] ?? 'guozhigq';

    _controller.addListener(
      () {
        var screenHeight = MediaQuery.of(context).size.height;
        if (_controller.offset >= screenHeight && showBackTopBtn == false) {
          setState(() {
            showBackTopBtn = true;
          });
        } else if (_controller.offset < screenHeight && showBackTopBtn) {
          setState(() {
            showBackTopBtn = false;
          });
        }
      },
    );

    queryMemberReply();
  }

  Future<ModelMemberReply> queryMemberReply() async {
    ModelMemberReply res =
        await UserWebApi.queryMemberReply(memberId, _currentPage + 1);
    setState(() {
      if (_currentPage == 0) {
        replyList = res.replyList;
      } else {
        replyList.addAll(res.replyList);
      }
      _isLoading = false;
      _currentPage += 1;
      _totalPage = res.totalPage;
      replyListData = res;
    });
    return res;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('最近回复'),
        actions: [
          if(replyListData.replyCount > 0)
          Text('回复总数 ${replyListData.replyCount}', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(width: 12)
        ],
      ),
      body: Stack(
        children: [
          Scrollbar(
            controller: _controller,
            radius: const Radius.circular(10),
            child: _isLoading
                ? showLoading()
                : replyList.isNotEmpty
                    ? PullRefresh(
                        totalPage: _totalPage,
                        currentPage: _currentPage,
                        onChildLoad:
                            _totalPage > 1 && _currentPage <= _totalPage
                                ? queryMemberReply
                                : null,
                        onChildRefresh: () {
                          setState(() {
                            _currentPage = 0;
                          });
                          queryMemberReply();
                        },
                        child: content(),
                      )
                    : const Text('没有数据'),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: AnimatedScale(
              scale: showBackTopBtn ? 1 : 0,
              curve: Curves.easeOut,
              duration: const Duration(milliseconds: 300),
              child: FloatingActionButton(
                heroTag: null,
                child: const Icon(Icons.vertical_align_top_rounded),
                onPressed: () {
                  _controller.animateTo(0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget content() {
    return CustomScrollView(
      controller: _controller,
      slivers: [
        SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
          return ReplyItem(replyItem: replyList[index]);
        }, childCount: replyList.length))
      ],
    );
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
