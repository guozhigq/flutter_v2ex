import 'package:flutter/material.dart';
import 'package:flutter_v2ex/utils/storage.dart';
import 'package:flutter_v2ex/components/common/skeleton.dart';

class TopicDetailSkeleton extends StatelessWidget {
  const TopicDetailSkeleton({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Skeleton(
      child: const Column(
        children: [
          TopicItemSkeleton(),
          TopicItemSkeleton(),
          TopicItemSkeleton()
        ],
      ),
    );
  }

}

class TopicItemSkeleton extends StatelessWidget {
  const TopicItemSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var commonColor = Theme.of(context).colorScheme.onInverseSurface;
    double height = GStorage().getHtmlFs() + 2;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            height: height,
            margin: const EdgeInsets.only(top: 0, bottom: 8),
            color: commonColor,
          ),
          Container(
            width: double.infinity,
            height: height,
            margin: const EdgeInsets.only(top: 0, bottom: 8, right: 40),
            color: commonColor,
          ),
          Container(
            width: double.infinity,
            height: height,
            margin: const EdgeInsets.only(top: 0, bottom: 8, right: 80),
            color: commonColor,
          ),
          Container(
            width: double.infinity,
            height: height,
            margin: const EdgeInsets.only(top: 0, bottom: 12, right: 200),
            color: commonColor,
          ),
        ],
      ),
    );
  }
}
