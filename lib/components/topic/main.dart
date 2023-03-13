import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_v2ex/components/common/avatar.dart';
import 'package:flutter_v2ex/components/common/node_tag.dart';
import 'package:flutter_v2ex/components/topic/html_render.dart';
import 'package:flutter_v2ex/utils/storage.dart';
import 'package:get/get.dart';
import 'package:flutter_v2ex/components/topic/skeleton_main.dart';

class TopicMain extends StatelessWidget {
  var detailModel;
  var topicDetail;
  String? heroTag;
  TopicMain({this.detailModel, this.topicDetail, this.heroTag, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    heroTag = heroTag ?? Random().nextInt(999).toString();
    TextStyle titleStyle = Theme.of(context)
        .textTheme
        .titleLarge!
        .copyWith(fontWeight: FontWeight.w500);
    TextStyle timeStyle = Theme.of(context)
        .textTheme
        .labelSmall!
        .copyWith(color: Theme.of(context).colorScheme.outline);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        /// 主题标题
        SelectionArea(
          child: Container(
            width: double.infinity,
            padding:
                const EdgeInsets.only(top: 0, right: 18, bottom: 0, left: 18),
            child: detailModel != null
                ? Text(detailModel!.topicTitle, style: titleStyle)
                : topicDetail != null
                    ? Text(topicDetail!.topicTitle, style: titleStyle)
                    : Text(
                        'me',
                        style: titleStyle,
                      ),
          ),
        ),

        Container(
          padding:
              const EdgeInsets.only(top: 20, right: 20, bottom: 20, left: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => detailModel != null
                          ? Get.toNamed('/member/${detailModel!.createdId}',
                              parameters: {
                                  'memberAvatar': detailModel!.avatar,
                                  'heroTag': heroTag!,
                                })
                          : null,
                      child: Hero(
                        tag: heroTag!,
                        child: CAvatar(
                          url: topicDetail != null
                              ? topicDetail!.avatar
                              : detailModel != null
                                  ? detailModel.avatar
                                  : '',
                          size: 35,
                          quality: 'origin',
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      detailModel != null
                          ? Text(
                              detailModel!.createdId,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: Theme.of(context).textTheme.titleMedium,
                            )
                          : topicDetail != null
                              ? Text(
                                  topicDetail!.memberId,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                )
                              : const Text('加载中'),
                      detailModel != null
                          ? Text(detailModel!.createdTime, style: timeStyle)
                          : topicDetail != null
                              ? Text(topicDetail!.lastReplyTime,
                                  style: timeStyle)
                              : const SizedBox()
                    ],
                  ),
                ],
              ),
              detailModel != null
                  ? NodeTag(
                      nodeId: detailModel!.nodeId,
                      nodeName: detailModel!.nodeName,
                      route: 'detail',
                    )
                  : topicDetail != null
                      ? NodeTag(
                          nodeId: topicDetail!.nodeId,
                          nodeName: topicDetail!.nodeName,
                          route: 'detail',
                        )
                      : const SizedBox()
            ],
          ),
        ),

        /// action操作
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.end,
        //   children: [
        //     if (detailModel!.favoriteCount > 0) ...[
        //       Text(
        //         '${detailModel!.favoriteCount}收藏',
        //         style: Theme.of(context).textTheme.labelMedium!.copyWith(
        //             color: Theme.of(context).colorScheme.outline),
        //       ),
        //       const SizedBox(width: 16),
        //     ],
        //     Text(
        //       '${detailModel!.visitorCount}查看',
        //       style: Theme.of(context)
        //           .textTheme
        //           .labelMedium!
        //           .copyWith(color: Theme.of(context).colorScheme.outline),
        //     ),
        //     const SizedBox(width: 16),
        //     Text(
        //       '${detailModel!.replyCount}回复',
        //       style: Theme.of(context)
        //           .textTheme
        //           .labelMedium!
        //           .copyWith(color: Theme.of(context).colorScheme.outline),
        //     ),
        //     const SizedBox(width: 20)
        //   ],
        // ),
        // const SizedBox(height: 5),
        Divider(
          endIndent: 15,
          indent: 15,
          color: Theme.of(context).dividerColor.withOpacity(0.15),
        ),
        // 内容
        if (detailModel != null) ...[
          if (detailModel!.content != '')
            Container(
              padding: const EdgeInsets.only(
                  top: 5, right: 18, bottom: 10, left: 18),
              child: SelectionArea(
                child: HtmlRender(
                  htmlContent: detailModel!.contentRendered,
                  imgCount: detailModel!.imgCount,
                  imgList: detailModel!.imgList,
                  fs: GStorage().getHtmlFs(),
                ),
              ),
            ),
          // 附言
          if (detailModel!.subtleList.isNotEmpty) ...[
            ...subList(detailModel!.subtleList, context)
          ],
          if (detailModel!.content.isNotEmpty)
            Divider(
              color: Theme.of(context).dividerColor.withOpacity(0.15),
            ),
        ] else ...[
          const TopicDetailSkeleton(),
          Divider(
            color: Theme.of(context).dividerColor.withOpacity(0.15),
          ),
        ]
      ],
    );
  }

  // 附言
  List<Widget> subList(data, context) {
    List<Widget>? list = [];
    for (var i in data) {
      list.add(
        SelectionArea(
          child: Container(
            padding:
                const EdgeInsets.only(top: 4, left: 18, right: 18, bottom: 10),
            // color: Theme.of(context).colorScheme.onInverseSurface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(
                  height: 1,
                  color: Theme.of(context).dividerColor.withOpacity(0.15),
                ),
                const SizedBox(
                  height: 12,
                ),
                Text(
                  i.fade,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).colorScheme.onSecondary,
                      backgroundColor: Theme.of(context).colorScheme.secondary),
                ),
                const SizedBox(
                  height: 10,
                ),
                HtmlRender(
                  htmlContent: i.content,
                  imgCount: detailModel!.imgCount,
                  imgList: detailModel!.imgList,
                )
              ],
            ),
          ),
        ),
      );
    }
    return list;
  }
}
