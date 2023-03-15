import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NodeTag extends StatelessWidget {
  final String? nodeId;
  final String? nodeName;
  final String? route;

  const NodeTag({
    this.nodeId,
    this.nodeName,
    this.route,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var bgColor = route == 'detail'
        ? Theme.of(context).colorScheme.onInverseSurface
        : Theme.of(context).colorScheme.surfaceVariant;
    return Material(
      borderRadius: BorderRadius.circular(50),
      color: bgColor,
      child: InkWell(
        onTap: () => Get.toNamed('/go/$nodeId'),
        borderRadius: BorderRadius.circular(50),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 3.5, horizontal: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                nodeName!.contains('WATCH')? 'iWatch' : nodeName!,
                style: const TextStyle(
                  fontSize: 11.0,
                  textBaseline: TextBaseline.ideographic,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
