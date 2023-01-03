import 'package:flutter/material.dart';

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        scrollDirection: Axis.vertical, // 默认 Axis.vertical 还有 Axis.horizontal
        slivers: <Widget>[
          // 给 CustomScrollView 增加 SliverAppBar
          SliverAppBar(
            // leading 接收一个widget
            leading: const IconButton(
                icon: Icon(
                  Icons.list,
                  color: Colors.white,
                ),
                onPressed: null),
            title: Text("九点下班"),
            elevation: 0,
            actions: const [
              IconButton(icon: Icon(Icons.add), onPressed: null),
              IconButton(icon: Icon(Icons.map), onPressed: null),
              IconButton(icon: Icon(Icons.more_vert), onPressed: null),
            ],
            bottom: TabBar(
              controller: _controller,
              tabs: const [
                Tab(
                  child: Text(
                    "最新",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    "推荐",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    "关注",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            //是否钉住
            pinned: true,
            // 是否马上可见
            floating: true,
            //用的比较少只有floating时生效
//          snap: true,
            // SliverAppBar 完全可见的高度
            expandedHeight: 250,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                "http://hiphotos.baidu.com/1066811738/pic/item/d90a475f1aad6ed1800a1896.jpg",
                fit: BoxFit.cover,
              ),
//            title: Text("title"),
            ),
          ),

          SliverFillRemaining(
            child: TabBarView(
              controller: _controller,
              children: [
                Container(
                  color: Colors.greenAccent,
                ),
                Container(
                  color: Colors.yellow,
                ),
                Container(
                  color: Colors.red,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
