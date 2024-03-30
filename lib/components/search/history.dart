import 'package:flutter/material.dart';
import 'package:flutter_v2ex/service/search.dart';
import 'package:get/get.dart';

class SearchHistory extends StatelessWidget {
  final RxList searchHisList;
  final Function? onSelect;
  final Function? onClear;
  const SearchHistory({
    super.key,
    required this.searchHisList,
    this.onSelect,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 6, left: 14, bottom: 12),
      child: Obx(() => Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: searchHisList.isNotEmpty
                ? [
                    Row(
                      children: [
                        Text(
                          '搜索历史',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        TextButton(
                            onPressed: () => showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text("提示"),
                                    content: const Text("您确定要删除搜索历史吗?"),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text(
                                          "取消",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .outline),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text("确定"),
                                        onPressed: () {
                                          Search().clear();
                                          onClear?.call();
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                }),
                            child: Text(
                              '清空',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.outline),
                            )),
                        const SizedBox(width: 10)
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      direction: Axis.horizontal,
                      textDirection: TextDirection.ltr,
                      children: [
                        for (int i = 0; i < searchHisList.length; i++)
                          SearchText(
                            searchText: searchHisList[i],
                            searchTextIdx: i,
                            onSelect: onSelect,
                          )
                      ],
                    )
                  ]
                : [],
          )),
    );
  }
}

class SearchText extends StatelessWidget {
  final String? searchText;
  final Function? onSelect;
  final int? searchTextIdx;
  const SearchText({
    super.key,
    this.searchText,
    this.onSelect,
    this.searchTextIdx,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceVariant,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: EdgeInsets.zero,
        child: InkWell(
            onTap: () {
              Search().move(searchText!);
              onSelect?.call(searchText);
            },
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              child: Text(
                searchText!,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            )),
      ),
    );
  }
}
