import 'package:flutter/material.dart';
import 'package:flutter_v2ex/utils/utils.dart';
import 'package:get/get.dart';
import 'controller.dart';

class ChangeLogPage extends StatefulWidget {
  const ChangeLogPage({Key? key}) : super(key: key);

  @override
  State<ChangeLogPage> createState() => _ChangeLogPageState();
}

class _ChangeLogPageState extends State<ChangeLogPage> {
  final ChangeLogController _changeLogController =
      Get.put(ChangeLogController());

  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('更新日志'),
            actions: [
              IconButton(
                  onPressed: () => Utils.openURL(
                      'https://github.com/guozhigq/flutter_v2ex/releases'),
                  icon: const Icon(Icons.open_in_browser))
            ],
          ),
          body: FutureBuilder(
            future: _changeLogController.queryChangeLog(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data.isNotEmpty) {
                  return _buildView(context, snapshot.data);
                } else {
                  return const Center(
                    child: Text('没有数据')
                  );
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ));
  }

  Widget _buildView(context, data) {
    List<Widget> versionList = [];
    for (var i in data) {
      versionList.add(
        Column(
          children: [
            ListTile(
              title: Text(i['tag_name']),
              trailing: IconButton(
                icon: Icon(
                  Icons.download,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () => Utils.openURL(i['html_url']),
              ),
            ),
            Divider(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
              height: 1,
              indent: 15,
              endIndent: 15,
            ),
            // if(i['body'] != '')
            Container(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 20),
              alignment: Alignment.centerLeft,
              child: Text(i['body'] != '' ? i['body'] : '无说明'),
            ),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      child: Column(
        children: versionList,
      ),
    );
  }
}
