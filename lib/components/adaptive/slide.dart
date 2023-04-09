import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_v2ex/components/common/avatar.dart';
import 'package:flutter_v2ex/utils/global.dart';
import 'package:get/get.dart';
import 'package:sticky_headers/sticky_headers.dart';

class AdaptSlide extends StatelessWidget {
  const AdaptSlide({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: double.infinity,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: getBackground(context, 'listItem'),
              borderRadius: BorderRadius.circular(10),
            ),
            child: StickyHeader(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      CAvatar(url: '', size: 30),
                      SizedBox(width: 10),
                      Text('guozhigq')
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('已签到'),
                  )
                ],
              ),
              content: Container(
                width: double.infinity,
                padding: Breakpoints.medium.isActive(context)
                    ? const EdgeInsets.fromLTRB(15, 0, 15, 25)
                    : const EdgeInsets.fromLTRB(25, 0, 25, 25),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        ActionGrid(count: '16', title: '节点收藏'),
                        ActionGrid(count: '16', title: '主题收藏'),
                        ActionGrid(count: '16', title: '特别关注')
                      ],
                    ),
                    const SizedBox(height: 20),
                    const ElevatedButton(
                      onPressed: null,
                      child: Text('发布新主题'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: getBackground(context, 'listItem'),
              borderRadius: BorderRadius.circular(10),
            ),
            child: StickyHeader(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '🔥 今日热议主题',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      '更多',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.outline),
                    ),
                  )
                  // IconButton(
                  //   onPressed: () {},
                  //   icon: Icon(
                  //       Icons.refresh,
                  //       size: 20,
                  //       color: Theme.of(context).colorScheme.outline),
                  // ),
                ],
              ),
              content: const HotList(),
            ),
          ),
        ],
      ),
    );
  }
}

class HotList extends StatelessWidget {
  const HotList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 50,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return Material(
          color: getBackground(context, 'listItem'),
          child: InkWell(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Text(
                '$index」 求推荐一些高质量的系统地介绍 ChatGPT 及相关技术的视频、文章或者书',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(height: 1.6),
              ),
            ),
          ),
        );
      },
    );
  }
}

class StickyHeader extends StatelessWidget {
  final Widget title;
  final Widget content;

  const StickyHeader({Key? key, required this.title, required this.content})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StickyHeaderBuilder(
        builder: (BuildContext context, double stuckAmount) {
          stuckAmount = 0.4 - stuckAmount.clamp(0.0, 1.0);
          return Container(
            width: double.infinity,
            height: 60,
            color: getBackground(context, 'listItem'),
            padding: const EdgeInsets.only(left: 20, right: 0),
            child: Stack(
              children: [
                SizedBox(height: 60, child: title),
                Positioned(
                    bottom: 1,
                    left: 0,
                    right: 18,
                    child: Divider(
                      height: 1,
                      color: Theme.of(context).dividerColor.withOpacity(0.1),
                    )),
              ],
            ),
          );
        },
        content: Column(
          children: [const SizedBox(height: 12), content],
        ));
  }
}

class ActionGrid extends StatelessWidget {
  final String? count;
  final String? title;

  const ActionGrid({Key? key, required this.count, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: getBackground(context, 'listItem'),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: Breakpoints.medium.isActive(context)
              ? const EdgeInsets.symmetric(vertical: 10, horizontal: 4)
              : const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                count!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 18,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(title!),
            ],
          ),
        ),
      ),
    );
  }
}
