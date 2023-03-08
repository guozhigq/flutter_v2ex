import 'package:flutter/material.dart';
import 'package:flutter_v2ex/models/tabs.dart';
import 'package:flutter_v2ex/utils/string.dart';
import 'package:flutter_v2ex/utils/storage.dart';
import 'package:flutter_v2ex/utils/event_bus.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class NodesSortPage extends StatefulWidget {
  const NodesSortPage({Key? key}) : super(key: key);

  @override
  State<NodesSortPage> createState() => _NodesSortPageState();
}

class _NodesSortPageState extends State<NodesSortPage>
    with SingleTickerProviderStateMixin {
  List<TabModel> tabs = GStorage().getTabs();
  TabModel firstTab = GStorage().getTabs()[0];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    tabs = tabs.sublist(1);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = tabs.removeAt(oldIndex);
      tabs.insert(newIndex, item);
    });
  }

  void saveEdit() {
    tabs.insert(0, firstTab);
    GStorage().setTabs(tabs);
    eventBus.emit('editTabs', 'success');
    SmartDialog.showToast('保存成功',
            displayTime: const Duration(milliseconds: 500))
        .then((res) => {Navigator.pop(context)});
  }

  void reset() {
    setState(() {
      tabs = Strings.tabs.sublist(1);
    });
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: const Text('操作成功'),
        content: const Text('已恢复默认排序，是否应用并保存'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          TextButton(onPressed: () {
            Navigator.pop(context);
            saveEdit();
          }, child: const Text('应用并保存'))
        ],
      );
    });
    // eventBus.emit('editTabs', 'success');
    // SmartDialog.showToast('恢复默认',
    //     displayTime: const Duration(milliseconds: 500))
    //     .then((res) => {Navigator.pop(context)});
  }

  @override
  Widget build(BuildContext context) {
    final listTiles = tabs
        .map((item) => CheckboxListTile(
              key: Key(item.name),
              value: item.checked ?? false,
              onChanged: (bool? newValue) {
                setState(() => item.checked = newValue!);
                print('item.checked: ${item.checked}');
              },
              title: Text(item.name),
              secondary: const Icon(Icons.drag_indicator_rounded),
            ))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('节点排序'),
        actions: [
          TextButton(onPressed: () => reset(), child: const Text('还原')),
          TextButton(onPressed: () => saveEdit(), child: const Text('保存')),
          const SizedBox(width: 12)
        ],
      ),
      body: ReorderableListView(
        header: const CheckboxListTile(
          value: true,
          onChanged: null,
          title: Text('最近'),
          secondary: Icon(Icons.lock_outline),
        ),
        onReorder: _onReorder,
        footer: SizedBox(
          height: MediaQuery.of(context).padding.bottom + 30,
        ),
        children: listTiles,
      ),
    );
  }
}
