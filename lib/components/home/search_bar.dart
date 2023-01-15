import 'package:flutter/material.dart';
import 'package:flutter_v2ex/pages/list_detail.dart';
import 'package:flutter_v2ex/components/common/avatar.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 65,
      padding: const EdgeInsets.only(top: 10, right: 0, left: 8, bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: double.infinity,
          height: 45,
          // color: Theme.of(context).colorScheme.onInverseSurface,
          padding: const EdgeInsets.only(right: 8, left: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: (() => {Scaffold.of(context).openDrawer()}),
                icon: const Icon(
                  Icons.menu,
                ),
              ),
              // Row(
              //   children: [
              //     const Icon(
              //       Icons.search_outlined,
              //       color: Colors.grey,
              //       size: 19,
              //     ),
              //     const SizedBox(width: 4),
              //     Text(
              //       '在vvex搜索内容',
              //       style: Theme.of(context).textTheme.bodyMedium,
              //     ),
              //   ],
              // ),
              // GestureDetector(
              //   onTap: () => {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) =>
              //             // pre代码解析为邮箱 bug fixed
              //             // const ListDetail(topicId: '907966'),
              //             // 分页
              //             const ListDetail(topicId: '908405'),
              //         // const ListDetail(topicId: '907145'),
              //       ),
              //     )
              //   },
              //   child: Container(
              //     decoration: BoxDecoration(
              //       color: Theme.of(context).colorScheme.surfaceVariant,
              //       borderRadius: BorderRadius.circular(50),
              //     ),
              //     clipBehavior: Clip.antiAlias,
              //     width: 37,
              //     height: 37,
              //     child: const Center(
              //       child: Icon(
              //         Icons.notifications_none,
              //         size: 18,
              //       ),
              //     ),
              //   ),
              // ),
              Text(
                'VVex',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(fontWeight: FontWeight.w500, color: Colors.black),
              ),
              // const CAvatar(
              //     url:
              //         'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fc-ssl.duitang.com%2Fuploads%2Fblog%2F202106%2F05%2F20210605015054_1afb0.thumb.1000_0.jpeg&refer=http%3A%2F%2Fc-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1676034634&t=a66f33b968f7f967882d40e0a3bc3055',
              //     size: 34)
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => {},
              )
            ],
          ),
        ),
      ),
    );
  }
}
