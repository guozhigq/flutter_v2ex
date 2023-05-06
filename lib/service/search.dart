import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Search {
  final Box box = Hive.box('recentSearchBox');

  Future<List> queryList() async {
    return box.get('history') ?? [];
  }

  void add(String searchText) {
    List historyList = box.get('history') ?? [];
    if (historyList.contains(searchText.trim())) {
      historyList.remove(searchText.trim());
    }
    historyList.insert(0, searchText);
    box.put('history', historyList);
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
