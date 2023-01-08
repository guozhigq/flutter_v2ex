import 'package:flutter/material.dart';

class HomeLeftDrawer extends StatefulWidget {
  const HomeLeftDrawer({super.key});

  @override
  State<HomeLeftDrawer> createState() => _HomeLeftDrawerState();
}

class _HomeLeftDrawerState extends State<HomeLeftDrawer> {
  @override
  Widget build(BuildContext context) {
    return const Material(
      child: Drawer(
        backgroundColor: Colors.white,
        width: 200,
      ),
    );
  }
}
