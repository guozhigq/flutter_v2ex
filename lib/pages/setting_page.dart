import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  '设置',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                centerTitle: false,
                titlePadding:
                    const EdgeInsetsDirectional.only(start: 42, bottom: 16),
                expandedTitleScale: 1.5),
          ),
        ],
      ),
    );
  }
}
