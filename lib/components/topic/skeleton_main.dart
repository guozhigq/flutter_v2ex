import 'package:flutter/material.dart';
import 'package:flutter_v2ex/utils/storage.dart';
import 'package:flutter_v2ex/components/common/skeleton.dart';
import 'package:get_storage/get_storage.dart';

class TopicDetailSkeleton extends StatelessWidget {
  const TopicDetailSkeleton({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Skeleton(
      child: Column(
        children: const [
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
    double height = GStorage().getHtmlFs();
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 0, ),
      padding: const EdgeInsets.fromLTRB(0, 0, 12, 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 350,
            height: height,
            margin: const EdgeInsets.only(top: 0, bottom: 8),
            color: commonColor,
          ),
          Container(
            width: 320,
            height: height,
            margin: const EdgeInsets.only(top: 0, bottom: 8),
            color: commonColor,
          ),
          Container(
            width: 280,
            height: height,
            margin: const EdgeInsets.only(top: 0, bottom: 8),
            color: commonColor,
          ),
          Container(
            width: 200,
            height: height,
            margin: const EdgeInsets.only(top: 0, bottom: 12),
            color: commonColor,
          ),
        ],
      ),
    );
  }
}

