import 'package:flutter/material.dart';
import 'package:flutter_v2ex/components/message/notice_item.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:flutter_v2ex/models/web/model_member_notice.dart';
import 'package:flutter_v2ex/models/web/item_member_notice.dart';
import 'package:flutter_v2ex/components/common/pull_refresh.dart';
import 'package:flutter_v2ex/service/local_notice.dart';
import 'package:flutter_v2ex/utils/event_bus.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final ScrollController _controller = ScrollController();
  List<MemberNoticeItem> noticeList = [];
  int _currentPage = 0;
  int _totalPage = 1;
  int totalCount = 0;
  bool showBackTopBtn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    queryNotice();
    // 清除所有通知
    LocalNoticeService().cancelAll();
    // eventBus.emit('unRead', 0);
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
  }

  Future<MemberNoticeModel> queryNotice() async {
    var res = await DioRequestWeb.queryNotice(_currentPage + 1);

    setState(() {
      if (_currentPage == 0) {
        noticeList = res.noticeList;
        _totalPage = res.totalPage;
        totalCount = res.totalCount;
      } else {
        noticeList.addAll(res.noticeList);
      }
      _isLoading = false;
      _currentPage += 1;
    });
    return res;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('消息提醒'),
      ),
      body: Stack(
        children: [
          Scrollbar(
            controller: _controller,
            radius: const Radius.circular(10),
            // child: PullRefresh(
            //   currentPage: _currentPage,
            //   totalPage: _totalPage,
            //   onChildRefresh: () {
            //     setState(() {
            //       _currentPage = 0;
            //     });
            //     queryNotice();
            //   },
            //   onChildLoad: _totalPage > 1 && _currentPage <= _totalPage
            //       ? queryNotice
            //       : null,
            //   child: CustomScrollView(
            //     controller: _controller,
            //     slivers: [
            //       // SliverAppBar(
            //       //   expandedHeight: 120,
            //       //   pinned: true,
            //       //   flexibleSpace: FlexibleSpaceBar(
            //       //       title: Text(
            //       //         '消息提醒',
            //       //         style: Theme.of(context).textTheme.titleMedium,
            //       //       ),
            //       //       centerTitle: false,
            //       //       titlePadding: const EdgeInsetsDirectional.only(
            //       //           start: 42, bottom: 16),
            //       //       expandedTitleScale: 1.5),
            //       // ),
            //       const SliverToBoxAdapter(
            //         child: SizedBox(height: 8),
            //       ),
            //       if (_isLoading)
            //         const SliverToBoxAdapter(
            //           child: Text('加载中'),
            //         )
            //       else if (noticeList.isEmpty)
            //         const SliverToBoxAdapter(
            //           child: Text('没数据'),
            //         )
            //       else if (noticeList.isNotEmpty)
            //         SliverList(
            //           delegate: SliverChildBuilderDelegate(
            //             (context, index) {
            //               return NoticeItem(noticeItem: noticeList[index]);
            //             },
            //             childCount: noticeList.length,
            //           ),
            //         ),
            //     ],
            //   ),
            // ),
            child: _isLoading
                ? showLoading()
                : noticeList.isNotEmpty
                ? PullRefresh(
              totalPage: _totalPage,
              currentPage: _currentPage,
              onChildLoad:
              _totalPage > 1 && _currentPage <= _totalPage
                  ? queryNotice
                  : null,
              onChildRefresh: () {
                setState(() {
                  _currentPage = 0;
                });
                queryNotice();
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
        const SliverToBoxAdapter(
          child:  SizedBox(height: 8),
        ),
        SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return NoticeItem(noticeItem: noticeList[index]);
            }, childCount: noticeList.length))
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
