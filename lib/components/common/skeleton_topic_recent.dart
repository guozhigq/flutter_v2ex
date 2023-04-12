import 'package:flutter/material.dart';
import 'package:flutter_v2ex/utils/global.dart';

class TopicItemSkeleton extends StatelessWidget {
  const TopicItemSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var commonColor = Theme.of(context).colorScheme.surfaceVariant;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: getBackground(context, 'listItem'),
        // color: Theme.of(context).colorScheme.onInverseSurface,
      ),
      margin: const EdgeInsets.only(top: 8, right: 12, bottom: 0, left: 12),
      padding: const EdgeInsets.fromLTRB(15, 18, 15, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 300,
            height: 16,
            margin: const EdgeInsets.only(top: 0, bottom: 12),
            color: commonColor,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
               Row(
                        children: [
                          Container(
                            width: 135,
                            height: 14,
                            color: commonColor,
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 30,
                            height: 14,
                            color: commonColor,
                          ),
                        ],
                      ),
              Container(
                width: 55,
                height: 21,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: commonColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

