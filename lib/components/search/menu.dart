import 'package:flutter/material.dart';
import 'package:flutter_v2ex/service/i18n_keyword.dart';
import 'package:get/get.dart';

class SearchMenu extends StatefulWidget {
  final Function(String)? setSort;
  final Function(int)? setOrder;
  final Function(int)? setStartTime;
  final Function(int)? setEndTime;

  const SearchMenu(
      {this.setSort,
      this.setOrder,
      this.setStartTime,
      this.setEndTime,
      Key? key})
      : super(key: key);

  @override
  State<SearchMenu> createState() => _SearchMenuState();
}

class _SearchMenuState extends State<SearchMenu> {
  DateTime? _selectedDate;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  String? _startTime;
  String? _endTime;

  // 排序方式 （默认 sumup) ｜ sumup（权重）created（发帖时间）
  String sortType = 'created';

  // 升降序，sort 为 created 时有效（默认 降序）｜ 0（降序）, 1（升序）
  int orderType = 0;

  Future<void> _selectDate(BuildContext context, String type) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: type == 'start' ? _startDate : _endDate,
      firstDate: type == 'end' ? _startDate : DateTime(2015, 8),
      lastDate: type == 'start' ? _endDate : DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      if (type == 'start') {
        setState(() {
          _startTime = picked.toString().split(' ')[0];
          _startDate = picked;
        });
        widget.setStartTime!(picked.millisecondsSinceEpoch~/1000);
      }

      if (type == 'end') {
        setState(() {
          _endTime = picked.toString().split(' ')[0];
          _endDate = picked;
        });
        widget.setEndTime!(picked.millisecondsSinceEpoch~/1000);
      }
    }
  }

  void onChooseSort() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('选择排序方式'),
          contentPadding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile(
                value: 'sumup',
                title:
                    Text('权重', style: Theme.of(context).textTheme.titleMedium),
                groupValue: sortType,
                onChanged: (value) {
                  setState(() {
                    sortType = value!;
                  });
                  widget.setSort!(value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile(
                value: 'created',
                title: Text('发帖时间',
                    style: Theme.of(context).textTheme.titleMedium),
                groupValue: sortType,
                onChanged: (value) {
                  setState(() {
                    sortType = value!;
                  });
                  widget.setSort;
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void onChooseOrder() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(I18nKeyword.selectOrder.tr),
          contentPadding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile(
                value: 0,
                title: Text(I18nKeyword.recentPriority.tr,
                    style: Theme.of(context).textTheme.titleMedium),
                groupValue: orderType,
                onChanged: (value) {
                  setState(() {
                    orderType = value!;
                  });
                  widget.setOrder!(value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile(
                value: 1,
                title: Text(I18nKeyword.historicalPriority.tr,
                    style: Theme.of(context).textTheme.titleMedium),
                groupValue: orderType,
                onChanged: (value) {
                  setState(() {
                    orderType = value!;
                  });
                  widget.setOrder!(value!);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50.0,
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // const Text(
          //   '高级搜索: ',
          // ),
          const SizedBox(width: 6),
          Expanded(
              child: SingleChildScrollView(
            scrollDirection: Axis.horizontal, // 设置为横向滚动效果
            child: Row(
              children: <Widget>[
                // 包裹原有的组件
                Row(
                  children: [
                    TextButton(
                      onPressed: onChooseSort,
                      child: Row(
                        children: [
                          const Icon(Icons.timeline, size: 17),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            sortType == 'sumup' ? '权重' : '发帖时间',
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onBackground),
                          )
                        ],
                      ),
                    ),
                    AnimatedSize(
                      curve: Curves.easeInOut,
                      duration: const Duration(milliseconds: 450),
                      child: SizedBox(
                        width: sortType == 'sumup' ? 0 : null,
                        child: TextButton(
                          onPressed: onChooseOrder,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.swap_vert,
                                size: 17,
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Text(orderType == 0 ? '降序' : '升序')
                            ],
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _selectDate(context, 'start'),
                      onLongPress: () {
                        widget.setStartTime!(0);
                        setState(() {
                          _startTime = '起始时间';
                          _startDate = DateTime.now();
                        });
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 17,
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(_startTime ?? '起止时间',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground))
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _selectDate(context, 'end'),
                      onLongPress: () {
                        widget.setEndTime!(0);
                        setState(() {
                          _endTime = '结束时间';
                          _endDate = DateTime.now();
                        });
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.schedule, size: 17),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(_endTime ?? '结束时间',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground))
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
