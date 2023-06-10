import 'package:flutter/material.dart';
import 'package:flutter_v2ex/service/search.dart';

class SearchHistory extends StatefulWidget {
  List? searchHisList;
  Function? onSelect;
  Function? onClear;
  SearchHistory({super.key, this.searchHisList, this.onSelect, this.onClear});

  @override
  State<SearchHistory> createState() => _SearchHistoryState();
}

class _SearchHistoryState extends State<SearchHistory> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 6, left: 14, bottom: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            widget.searchHisList != null && widget.searchHisList!.isNotEmpty
                ? [
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('搜索历史'),
                        const Spacer(),
                        TextButton(
                            // onPressed: () {
                            //   Search().clear();
                            //   onClear!();
                            // },
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
                                          widget.onClear!();
                                          setState(() {
                                            widget.searchHisList = [];
                                          });
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
                        for (int i = 0; i < widget.searchHisList!.length; i++)
                          SearchText(
                            searchText: widget.searchHisList![i],
                            searchTextIdx: i,
                            onSelect: widget.onSelect,
                          )
                      ],
                    )
                  ]
                : [],
      ),
    );
  }
}

class SearchText extends StatelessWidget {
  String? searchText;
  Function? onSelect;
  int? searchTextIdx;
  SearchText({super.key, this.searchText, this.onSelect, this.searchTextIdx});

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
              onSelect!(searchText);
            },
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 5, bottom: 5, left: 11, right: 11),
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
