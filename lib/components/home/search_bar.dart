import 'package:flutter/material.dart';
import 'package:flutter_v2ex/pages/list_detail.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 65,
      padding: const EdgeInsets.only(top: 10, right: 13, left: 13, bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: double.infinity,
          height: 45,
          color: Theme.of(context).colorScheme.onInverseSurface,
          padding: const EdgeInsets.only(right: 8, left: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: (() => {Scaffold.of(context).openDrawer()}),
                  // onPressed: () => {
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (context) =>
                  //               const ListDetail(topicId: '907145'),
                  //         ),
                  //       )
                  //     },
                  icon: const Icon(
                    Icons.menu_outlined,
                    size: 22,
                  )),
              Row(
                children: [
                  const Icon(
                    Icons.search_outlined,
                    color: Colors.grey,
                    size: 19,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '在vvex搜索内容',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(50),
                ),
                clipBehavior: Clip.antiAlias,
                width: 37,
                height: 37,
                child: const Center(
                  child: Icon(
                    Icons.notifications_none,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
