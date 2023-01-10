import 'package:flutter/material.dart';
// import 'package:flutter_v2ex/components/home/list_item.dart';

class HomeLeftDrawer extends StatefulWidget {
  const HomeLeftDrawer({super.key});

  @override
  State<HomeLeftDrawer> createState() => _HomeLeftDrawerState();
}

class _HomeLeftDrawerState extends State<HomeLeftDrawer> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Drawer(
        backgroundColor: Colors.white,
        width: 300,
        child: ListView(
          padding: const EdgeInsets.only(left: 20, right: 20),
          children: const [
            DrawerHeader(child: Text('123')),
            ListTile(
              leading: Icon(Icons.star),
              title: Text('我的收藏'),
            ),
            ListTile(
              leading: Icon(Icons.message),
              title: Text('124'),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('设置'),
            )
          ],
        ),
      ),
    );
  }
}
