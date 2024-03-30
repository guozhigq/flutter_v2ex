// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_v2ex/components/topic/reply_item.dart';

class ReplySheet extends StatefulWidget {
  double height = 0.0; // 容器高
  List resultList = []; // 回复列表
  String topicId = ''; // 主题id
  List replyMemberList = []; // user列表
  final int? totalPage;
  final List? replyList;

  ReplySheet(
      {required this.height,
      required this.resultList,
      required this.topicId,
      required this.replyMemberList,
      this.totalPage,
      this.replyList,
      Key? key})
      : super(key: key);

  @override
  State<ReplySheet> createState() => _ReplySheetState();
}

class _ReplySheetState extends State<ReplySheet> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController =
        TabController(length: widget.replyMemberList.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      constraints: BoxConstraints(maxHeight: widget.height, minHeight: 500),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 40,
            padding: const EdgeInsets.only(bottom: 2),
            child: Center(
              child: Container(
                width: 38,
                height: 2,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(3),
                    ),
                    color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
          ),
          // TabBar(tabs: )
          if (widget.replyMemberList.length == 1)
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(left: 12, right: 12),
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: ListView.builder(
                  physics: const ClampingScrollPhysics(), //重要
                  itemCount:
                      widget.resultList[0][widget.replyMemberList[0]].length,
                  itemBuilder: (BuildContext context, int index) {
                    return ReplyListItem(
                        reply: widget.resultList[0][widget.replyMemberList[0]]
                            [index],
                        topicId: widget.topicId,
                        totalPage: widget.totalPage,
                        source: 'sheet',
                        replyList: widget.replyList);
                  },
                ),
              ),
            )
          else ...[
            TabBar(
              dividerColor: Colors.transparent,
              controller: _tabController,
              onTap: (index) {},
              isScrollable: true,
              enableFeedback: true,
              splashBorderRadius: BorderRadius.circular(6),
              tabs: widget.replyMemberList.map((item) {
                return Tab(text: item);
              }).toList(),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(top: 8),
                child: TabBarView(
                  controller: _tabController,
                  children: widget.replyMemberList.map((e) {
                    var i = widget.replyMemberList.indexOf(e);
                    print('104: ${widget.resultList[i]}');
                    // return Text(e);
                    return widget.resultList[i][e] != null
                        ? ListView.builder(
                            physics: const ClampingScrollPhysics(), //重要
                            itemCount: widget.resultList[i][e]?.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: ReplyListItem(
                                  reply: widget.resultList[i][e][index],
                                  topicId: widget.topicId,
                                  totalPage: widget.totalPage,
                                  source: 'sheet',
                                ),
                              );
                              // return Text('123');
                            },
                          )
                        : const SizedBox(
                            child: Center(
                              child: Text('无回复内容'),
                            ),
                          );
                  }).toList(),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
