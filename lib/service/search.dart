import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Search {
  final Box box = Hive.box('recentSearchBox');

  Future<List> queryList() async {
    return box.get('history') ?? [];
  }

  Future<List> add(String searchText) async {
    List historyList = box.get('history') ?? [];
    if (historyList.contains(searchText.trim())) {
      historyList.remove(searchText.trim());
    }
    historyList.insert(0, searchText);
    await box.put('history', historyList);
    return historyList;
  }

  void move(String searchText) {
    List historyList = box.get('history') ?? [];
    historyList.removeAt(historyList.indexOf(searchText));
    box.put('history', historyList);
  }

  void clear() {
    box.clear();
  }
}
