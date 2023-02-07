import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_v2ex/models/web/model_node_fav.dart';

class NodeListItem extends StatelessWidget {
  final NodeFavModel? nodeItem;

  const NodeListItem({this.nodeItem, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 0, right: 0, bottom: 7, left: 0),
      child: Material(
        color: Theme.of(context).colorScheme.onInverseSurface,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () => Get.toNamed('/go/${nodeItem!.nodeId}'),
          borderRadius: BorderRadius.circular(10),
          child: Ink(
            padding:
                const EdgeInsets.only(top: 10, left: 10, right: 15, bottom: 10),
            child: content(),
          ),
        ),
      ),
    );
  }

  Widget content() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              // child: Image.network(
              //   widget.nodeItem!.nodeCover,
              //   width: 50,
              //   height: 50,
              // ),
              child: Image.asset(
                'assets/images/avatar.png',
                width: 60,
                height: 60,
              ),
            ),
            const SizedBox(width: 10),
            Text(nodeItem!.nodeName)
          ],
        ),
        Text(nodeItem!.topicCount)
      ],
    );
  }
}
