import 'package:flutter/material.dart';
import 'package:flutter_v2ex/components/mine/topic_list.dart';
import 'package:flutter_v2ex/components/mine/reply_list.dart';
import 'package:flutter_v2ex/components/common/avatar.dart';

class MinePage extends StatefulWidget {
  String memberId = '';

  MinePage({required this.memberId, super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  // 自定义、 缓存 、 api获取
  final List<Map<dynamic, dynamic>> _mineTab = [
    {
      'title': '主题',
    },
    {
      'title': '回复',
    }
  ];

  @override
  void initState() {
    print('memberId ${widget.memberId}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _mineTab.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.memberId}的动态'),
        ),
        body: Column(
          children: <Widget>[
            // Container(
            //   padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
            //   child: Row(
            //     children: [
            //       CAvatar(url: '', size: 55),
            //       SizedBox(width: 20,),
            //       Column(
            //         children: [
            //           Text('guozhigq'),
            //           Text('加入xxxxx')
            //         ],
            //       )
            //     ],
            //   ),
            // ),
            TabBar(
              dividerColor: Colors.transparent,
              onTap: (index) {},
              enableFeedback: true,
              splashBorderRadius: BorderRadius.circular(6),
              tabs: _mineTab.map((item) {
                return Tab(text: item['title']);
              }).toList(),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  TopicList(memberId: widget.memberId),
                  ReplyList(memberId: widget.memberId)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
