import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_v2ex/http/dio_web.dart';

class NodesPage extends StatefulWidget {
  const NodesPage({super.key});

  @override
  State<NodesPage> createState() => _NodesPageState();
}

class _NodesPageState extends State<NodesPage> {
  List<Map<dynamic, dynamic>> nodesList = [];

  @override
  void initState() {
    super.initState();
    getNodes();
  }

  Future getNodes() async {
    var res = await DioRequestWeb.getNodes();
    setState(() {
      nodesList = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            actions: [
              IconButton(onPressed: () => {}, icon: const Icon(Icons.search)),
              const SizedBox(width: 12)
            ],
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  '全部节点',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                centerTitle: false,
                titlePadding:
                    const EdgeInsetsDirectional.only(start: 42, bottom: 16),
                expandedTitleScale: 1.5),
          ),
          SliverList(
            delegate: SliverChildListDelegate(nodesRow()),
          )
        ],
      ),
    );
  }

  List<Widget> nodesRow() {
    List<Widget>? list = [];
    for (Map i in nodesList) {
      list.add(
        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.only(top: 20, left: 36, right: 26, bottom: 10),
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                i['name'],
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Wrap(
                  runSpacing: -6,
                  direction: Axis.horizontal,
                  children: nodesChildList(i['childs']))
            ],
          ),
        ),
      );
    }
    list.add(SizedBox(height: MediaQuery.of(context).padding.bottom + 60));
    return list;
  }

  List<Widget> nodesChildList(child) {
    List<Widget>? list = [];
    for (Map i in child) {
      list.add(
        Container(
          // decoration: BoxDecoration(border: Border.all()),
          padding: EdgeInsets.zero,
          child: TextButton(
            onPressed: () => Get.toNamed('/go/${i['id']}'),
            child: Text(i['name']),
          ),
        ),
      );
    }
    return list;
  }
}
