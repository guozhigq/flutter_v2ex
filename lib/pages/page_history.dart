import 'package:flutter/material.dart';
import 'package:flutter_v2ex/components/home/list_item.dart';
import 'package:flutter_v2ex/service/read.dart';
import 'package:sticky_headers/sticky_headers.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // final ScrollController? controller;
  List historyList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getHistoryTopic();
  }


  void getHistoryTopic() {
    var res = Read().query();
    if(res.isNotEmpty){
      setState(() {
        historyList = res.reversed.toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('最近浏览'),
      ),
      body: ListView.builder(
          // primary: controller == null,
          // controller: controller,
          itemCount: historyList.length,
          itemBuilder: (context, index) {
        return StickyHeaderBuilder(
          // controller: controller, // Optional
          builder: (BuildContext context, double stuckAmount) {
            stuckAmount = 1.0 - stuckAmount.clamp(0.0, 1.0);
            return Container(
              height: 60.0,
              color: Color.lerp(Theme.of(context).colorScheme.background, Theme.of(context).colorScheme.background, stuckAmount),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              alignment: Alignment.centerLeft,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      historyList[index]['date'],
                        style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
            );
          },
          content: Container(
            padding: const EdgeInsets.only(left: 12, top: 8, right: 12),
            child: Column(
                children: [
                  for(var i in historyList[index]['topicList'])
                    ListItem(topic: i['content']),
                ]
            ),
          )
          ,
        );
      })
    );
  }

  Widget noData() {
    return const Center(
      child: Text('没有数据'),
    );
  }
}
