import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_v2ex/utils/utils.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:flutter_v2ex/components/common/avatar.dart';
import 'package:flutter_v2ex/components/common/skeleton.dart';
import 'package:flutter_v2ex/components/member/topic_item.dart';
import 'package:flutter_v2ex/components/member/reply_item.dart';
import 'package:flutter_v2ex/components/topic/html_render.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_v2ex/models/web/model_member_profile.dart';
import 'package:flutter_v2ex/components/common/skeleton_topic_recent.dart';
import 'controller.dart';

class MemberPage extends StatefulWidget {
  const MemberPage({Key? key}) : super(key: key);

  @override
  State<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  final MemberController _memberController =
      Get.put(MemberController(), tag: Get.parameters['memberId']);
  final GlobalKey signStatusKey = GlobalKey();
  final GlobalKey followBtnKey = GlobalKey();
  final GlobalKey blockBtnKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<ModelMemberProfile>(
        future: _memberController.queryMemberProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data != null) {
              return _buildView();
            } else {
              return Text('请求异常');
            }
          } else {
            return loading();
          }
        },
      ),
    );
  }

  Widget _buildView() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 120,
          actions: _memberController.isOwner
              ? [
                  StatefulBuilder(
                      key: signStatusKey,
                      builder: (context, StateSetter setState) {
                        _memberController.onRefreshSign = () {
                          signStatusKey.currentState?.setState(() {});
                        };
                        return TextButton(
                          onPressed: () {
                            if (!_memberController.signDetail['signStatus']) {
                              _memberController.dailyMission();
                            }
                          },
                          child: Text(_memberController.signDetail.isNotEmpty &&
                                  _memberController.signDetail['signStatus']
                              ? '已领取奖励'
                              : '领取奖励'),
                        );
                      }),
                  const SizedBox(width: 12)
                ]
              : [
                  StatefulBuilder(
                    key: followBtnKey,
                    builder: (context, StateSetter setState) {
                      _memberController.onRefreshFollow = () {
                        followBtnKey.currentState?.setState(() {});
                      };
                      return TextButton(
                        onPressed: () =>
                            _memberController.onFollowMemeber(context),
                        child: Text(_memberController.memberProfile.isFollow
                            ? '取消关注'
                            : '关注'),
                      );
                    },
                  ),
                  StatefulBuilder(
                    key: blockBtnKey,
                    builder: (context, StateSetter setState) {
                      _memberController.onRefreshBlock = () {
                        blockBtnKey.currentState?.setState(() {});
                      };
                      return TextButton(
                          onPressed: () =>
                              _memberController.onBlockMember(context),
                          child: Text(
                            _memberController.memberProfile.isBlock
                                ? '取消屏蔽'
                                : '屏蔽',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error),
                          ));
                    },
                  ),
                  const SizedBox(width: 12)
                ],
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
              title: Text(
                '个人信息',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              centerTitle: false,
              titlePadding:
                  const EdgeInsetsDirectional.only(start: 42, bottom: 16),
              expandedTitleScale: 1.1),
        ),
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsetsDirectional.only(top: 20, bottom: 0),
            padding: const EdgeInsets.only(left: 15, right: 2),
            child: Row(
              children: [
                Stack(
                  children: [
                    Hero(
                      tag: _memberController.heroTag,
                      child: CAvatar(
                        url: _memberController.memberAvatar,
                        size: 80,
                        quality: 'origin',
                      ),
                    ),
                    Positioned(
                      bottom: 1,
                      right: 1,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          border: Border.all(
                              strokeAlign: BorderSide.strokeAlignCenter,
                              color: Theme.of(context).colorScheme.background,
                              width: 2.5),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        _memberController.memberProfile.memberId,
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(_memberController.memberProfile.mbSort),
                      Text(_memberController.memberProfile.mbCreatedTime),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_memberController.signDetail.isNotEmpty &&
            _memberController.isOwner &&
            _memberController.signDetail['balanceRender'] != null) ...[
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsetsDirectional.only(top: 30, bottom: 8),
              padding: const EdgeInsets.only(left: 20, right: 2),
              child: Text('Balance',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(left: 15, right: 10),
              child: Html(
                data: _memberController.signDetail['balanceRender'],
                extensions: [
                  TagExtension(
                    tagsToExtend: {"img"},
                    builder: (extensionContext) {
                      String? imgUrl = extensionContext.attributes['src'];
                      imgUrl = Utils().imageUrl(imgUrl!);
                      return CachedNetworkImage(
                        imageUrl: imgUrl,
                        height: 20,
                        fadeOutDuration: const Duration(milliseconds: 100),
                        placeholder: (context, url) => Image.asset(
                          'assets/images/avatar.png',
                          width: 20,
                          height: 20,
                        ),
                      );
                    },
                  )
                ],
                // customRenders: {
                //   tagMatcher("img"): CustomRender.widget(
                //     widget: (htmlContext, buildChildren) {
                //       String? imgUrl =
                //           htmlContext.tree.element!.attributes['src'];
                //       imgUrl = Utils().imageUrl(imgUrl!);
                //       return CachedNetworkImage(
                //         imageUrl: imgUrl,
                //         height: 20,
                //         fadeOutDuration: const Duration(milliseconds: 100),
                //         placeholder: (context, url) => Image.asset(
                //           'assets/images/avatar.png',
                //           width: 20,
                //           height: 20,
                //         ),
                //       );
                //     },
                //   ),
                // },
                style: {
                  'a': Style(
                    color: Theme.of(context).colorScheme.onBackground,
                    textDecoration: TextDecoration.none,
                    margin: Margins.only(right: 2),
                  ),
                },
              ),
            ),
          ),
        ],
        if (_memberController.memberProfile.socialList.isNotEmpty) ...[
          const SliverToBoxAdapter(
            child: SizedBox(height: 30),
          ),
          SliverToBoxAdapter(
            child: Container(
                padding: const EdgeInsets.only(left: 12, right: 10),
                child: Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    direction: Axis.horizontal,
                    children: nodesChildList(
                        _memberController.memberProfile.socialList))),
          ),
        ],
        if (_memberController.memberProfile.mbSign.isNotEmpty) ...[
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: HtmlRender(
                htmlContent: _memberController.memberProfile.mbSign,
              ),
            ),
          ),
        ],
        titleLine('最近发布', 'topic'),
        if (_memberController.memberProfile.isEmptyTopic) ...[
          SliverToBoxAdapter(
            child: Container(
              height: 80,
              alignment: Alignment.center,
              child: Text(
                '没内容',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          )
        ] else if (_memberController.memberProfile.isShowTopic) ...[
          SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
            return TopicItem(
                topicItem: _memberController.memberProfile.topicList[index]);
          }, childCount: _memberController.memberProfile.topicList.length)),
        ] else ...[
          SliverToBoxAdapter(
            child: Container(
              height: 80,
              // padding: const EdgeInsets.only(top: 20),
              alignment: Alignment.center,
              child: Text(
                '根据 ${_memberController.memberId} 的设置，主题列表被隐藏',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          )
        ],
        titleLine('最近回复', 'reply'),
        if (_memberController.memberProfile.isEmptyReply) ...[
          SliverToBoxAdapter(
            child: Container(
              height: 80,
              alignment: Alignment.center,
              child: Text(
                '没内容',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          )
        ] else if (_memberController.memberProfile.isShowReply) ...[
          SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
            return ReplyItem(
                replyItem: _memberController.memberProfile.replyList[index]);
          }, childCount: _memberController.memberProfile.replyList.length)),
        ] else ...[
          SliverToBoxAdapter(
            child: Container(
              height: 80,
              // padding: const EdgeInsets.only(top: 20),
              alignment: Alignment.center,
              child: Text(
                '根据 ${_memberController.memberId} 的设置，回复列表被隐藏',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          )
        ],
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        )
      ],
    );
  }

  List<Widget> nodesChildList(child) {
    List<Widget>? list = [];
    for (var i in child) {
      list.add(
        Container(
          padding: EdgeInsets.zero,
          child: FilledButton.tonal(
            style: ButtonStyle(
                padding: MaterialStateProperty.all(const EdgeInsets.only(
                    top: 7, right: 12, bottom: 7, left: 8))),
            onPressed: () async {
              await Utils.openURL(i.href);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/social/${i.type}.png',
                    width: 25, height: 25),
                const SizedBox(width: 2),
                Flexible(
                  child: Text(
                    i.name,
                    maxLines: 1,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return list;
  }

  Widget titleLine(title, type) {
    return SliverToBoxAdapter(
      child: Container(
        height: 50,
        margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
        child: Material(
          borderRadius: BorderRadius.circular(30),
          child: InkWell(
            splashColor: Theme.of(context).colorScheme.surfaceVariant,
            onTap: () {
              if (type == 'reply') {
                Get.toNamed('/member/${_memberController.memberId}/replies');
              }
              if (type == 'topic') {
                Get.toNamed('/member/${_memberController.memberId}/topics');
              }
            },
            child: Ink(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  Icon(
                    Icons.arrow_forward_ios_outlined,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget loading() {
    // Skeleton 会影响Hero效果
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 120,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
              title: Text(
                '个人信息',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              centerTitle: false,
              titlePadding:
                  const EdgeInsetsDirectional.only(start: 42, bottom: 16),
              expandedTitleScale: 1.1),
        ),
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsetsDirectional.only(top: 20, bottom: 0),
            padding: const EdgeInsets.only(left: 15, right: 2),
            child: Row(
              children: [
                Hero(
                  tag: _memberController.heroTag,
                  child: CAvatar(
                    url: _memberController.memberAvatar,
                    size: 80,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                    child: Skeleton(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        _memberController.memberId,
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: 170,
                        height: 18,
                        decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.onInverseSurface,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(2))),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        width: 120,
                        height: 18,
                        decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.onInverseSurface,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(2))),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 20),
        ),
        SliverToBoxAdapter(
          child: Skeleton(
            child: Column(
              children: [
                Container(
                  height: 18,
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                    borderRadius: const BorderRadius.all(Radius.circular(2)),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 18,
                  margin: const EdgeInsets.only(left: 20, right: 170),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                    borderRadius: const BorderRadius.all(Radius.circular(2)),
                  ),
                ),
              ],
            ),
          ),
        ),
        titleLine('最近发布', ''),
        SliverToBoxAdapter(
          child: Skeleton(
            child: Column(
              children: const [
                TopicItemSkeleton(),
                TopicItemSkeleton(),
                TopicItemSkeleton(),
              ],
            ),
          ),
        ),
        titleLine('最近回复', '')
      ],
    );
  }
}
