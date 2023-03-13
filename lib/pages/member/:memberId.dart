import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_v2ex/utils/utils.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:flutter_v2ex/utils/storage.dart';
import 'package:flutter_v2ex/components/common/avatar.dart';
import 'package:flutter_v2ex/components/common/skeleton.dart';
import 'package:flutter_v2ex/components/member/topic_item.dart';
import 'package:flutter_v2ex/components/member/reply_item.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_v2ex/components/topic/html_render.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_v2ex/models/web/model_member_profile.dart';
import 'package:flutter_v2ex/components/common/skeleton_topic_recent.dart';

class MemberPage extends StatefulWidget {
  const MemberPage({Key? key}) : super(key: key);

  @override
  State<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  ModelMemberProfile memberProfile = ModelMemberProfile();
  bool _loading = true;
  Map signDetail = {};
  String memberId = '';
  String memberAvatar = '';
  String heroTag = '';
  bool isOwner = false;

  @override
  void initState() {
    super.initState();
    var mapKey = Get.parameters.keys;
    setState(() {
      memberId = mapKey.contains('memberId') ? Get.parameters['memberId']! : '';
      memberAvatar = mapKey.contains('memberAvatar')
          ? Get.parameters['memberAvatar']!
          : '';
      heroTag = mapKey.contains('heroTag') ? Get.parameters['heroTag']! : '';
    });

    if (GStorage().getUserInfo().isNotEmpty) {
      if (memberId == GStorage().getUserInfo()['userName']) {
        setState(() {
          isOwner = true;
        });
      }
      // 查询签到状态、余额、消息提醒
      queryDaily();
    }

    // 查询用户信息
    queryMemberProfile();
  }

  Future<ModelMemberProfile> queryMemberProfile() async {
    var res = await DioRequestWeb.queryMemberProfile(memberId);
    setState(() {
      memberProfile = res;
      _loading = false;
    });

    return res;
  }

  Future<Map<dynamic, dynamic>> queryDaily() async {
    var res = await DioRequestWeb.queryDaily();
    setState(() {
      signDetail = res;
    });
    // print('70: ${signDetail}');
    return res;
  }

  // 关注用户
  void onFollowMemeber() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('提示'),
        // content: Text('确认屏蔽${memberId}吗？'),
        content: Text.rich(TextSpan(children: [
          TextSpan(text: memberProfile.isFollow ? '确认不再关注用户 ' : '确认要开始关注用户 '),
          TextSpan(
            text: '@$memberId',
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          const TextSpan(text: ' 吗')
        ])),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'OK');
              onFollowReq();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Future<bool> onFollowReq() async {
    var followId = '';
    RegExp regExp = RegExp(r'\d{3,}');
    Iterable<Match> matches = regExp.allMatches(memberProfile.mbSort);
    for (Match m in matches) {
      followId = m.group(0)!;
    }
    bool followStatus = memberProfile.isFollow;
    bool res = await DioRequestWeb.onFollowMember(followId, followStatus);
    if (res) {
      SmartDialog.showToast(followStatus ? '已取消关注' : '关注成功');
      setState(() {
        memberProfile.isFollow = !followStatus;
      });
    } else {
      SmartDialog.showToast('操作失败');
    }
    return res;
  }

  // 屏蔽用户
  void onBlockMember() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('提示'),
        content: Text.rich(TextSpan(children: [
          TextSpan(text: memberProfile.isBlock ? '取消屏蔽用户 ' : '确认屏蔽用户 '),
          TextSpan(
            text: '@$memberId',
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          const TextSpan(text: ' 吗')
        ])),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'OK');
              onBlockReq();
            },
            child: const Text('确认屏蔽'),
          ),
        ],
      ),
    );
  }

  Future<bool> onBlockReq() async {
    var blockId = '';
    RegExp regExp = RegExp(r'\d{3,}');
    Iterable<Match> matches = regExp.allMatches(memberProfile.mbSort);
    for (Match m in matches) {
      blockId = m.group(0)!;
    }
    bool blockStatus = memberProfile.isBlock;
    // bool followStatus = memberProfile.isFollow;
    bool res = await DioRequestWeb.onBlockMember(blockId, blockStatus);
    if (res) {
      SmartDialog.showToast(blockStatus ? '已取消屏蔽' : '屏蔽成功');
      setState(() {
        memberProfile.isBlock = !blockStatus;
        // if(!blockStatus && followStatus){
        //   memberProfile.isFollow = false;
        // }
      });
    } else {
      SmartDialog.showToast('操作失败');
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !_loading
          ? CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 120,
                  actions: isOwner
                      ? [
                          TextButton(
                            onPressed: ()  {
                              if (!signDetail['signStatus']) {
                                  DioRequestWeb.dailyMission();
                                }
                              },
                            child: Text(signDetail.isNotEmpty &&
                                    signDetail['signStatus']
                                ? '已领取奖励'
                                : '领取奖励'),
                          ),
                          const SizedBox(width: 12)
                        ]
                      : [
                          TextButton(
                            onPressed: () => onFollowMemeber(),
                            child: Row(
                              children: [
                                Icon(memberProfile.isFollow
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border),
                                const SizedBox(width: 4),
                                Text(memberProfile.isFollow ? '取关' : '关注')
                              ],
                            ),
                          ),
                          TextButton(
                              onPressed: () => onBlockMember(),
                              child: Text(
                                memberProfile.isBlock ? '取消屏蔽' : '屏蔽',
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.error),
                              )),
                          const SizedBox(width: 12)
                        ],
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        '个人信息',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      centerTitle: false,
                      titlePadding: const EdgeInsetsDirectional.only(
                          start: 42, bottom: 16),
                      expandedTitleScale: 1.1),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    margin:
                        const EdgeInsetsDirectional.only(top: 20, bottom: 0),
                    padding: const EdgeInsets.only(left: 15, right: 2),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            Hero(
                              tag: heroTag,
                              child: CAvatar(
                                url: memberProfile.mbAvatar,
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
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                  border: Border.all(
                                      strokeAlign: BorderSide.strokeAlignCenter,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .background,
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
                              Text(
                                memberProfile.memberId,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(memberProfile.mbSort),
                              Text(memberProfile.mbCreatedTime),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (signDetail.isNotEmpty && isOwner && signDetail['balanceRender'] != null) ...[
                  SliverToBoxAdapter(
                    child: Container(
                      margin:
                          const EdgeInsetsDirectional.only(top: 30, bottom: 8),
                      padding: const EdgeInsets.only(left: 20, right: 2),
                      child: Text('Balance',
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.only(left: 15, right: 10),
                      child: Html(
                        data: signDetail['balanceRender'],
                        customRenders: {
                          tagMatcher("img"): CustomRender.widget(
                            widget: (htmlContext, buildChildren) {
                              String? imgUrl =
                                  htmlContext.tree.element!.attributes['src'];
                              imgUrl = Utils().imageUrl(imgUrl!);
                              return
                                CachedNetworkImage(
                                  imageUrl: imgUrl,
                                  height: 20,
                                  fadeOutDuration:  const Duration(milliseconds: 100),
                                  placeholder: (context, url) => Image.asset('assets/images/avatar.png', width: 20, height: 20,),
                              );
                            },
                          ),
                        },
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
                if (memberProfile.socialList.isNotEmpty) ...[
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
                            children:
                                nodesChildList(memberProfile.socialList))),
                  ),
                ],
                if (memberProfile.mbSign.isNotEmpty) ...[
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 20),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: HtmlRender(
                        htmlContent: memberProfile.mbSign,
                      ),
                    ),
                  ),
                ],
                titleLine('最近发布', 'topic'),
                if (memberProfile.isEmptyTopic) ...[
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
                ] else if (memberProfile.isShowTopic) ...[
                  SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                    return TopicItem(topicItem: memberProfile.topicList[index]);
                  }, childCount: memberProfile.topicList.length)),
                ] else ...[
                  SliverToBoxAdapter(
                    child: Container(
                      height: 80,
                      // padding: const EdgeInsets.only(top: 20),
                      alignment: Alignment.center,
                      child: Text(
                        '根据 ${memberId} 的设置，主题列表被隐藏',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  )
                ],
                titleLine('最近回复', 'reply'),
                if (memberProfile.isEmptyReply) ...[
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
                ] else if (memberProfile.isShowReply) ...[
                  SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                    return ReplyItem(replyItem: memberProfile.replyList[index]);
                  }, childCount: memberProfile.replyList.length)),
                ] else ...[
                  SliverToBoxAdapter(
                    child: Container(
                      height: 80,
                      // padding: const EdgeInsets.only(top: 20),
                      alignment: Alignment.center,
                      child: Text(
                        '根据 ${memberId} 的设置，回复列表被隐藏',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  )
                ],
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                )
              ],
            )
          : loading(),
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
                Flexible(child: Text(
                  i.name,
                  maxLines: 1,
                  style:
                  TextStyle(color: Theme.of(context).colorScheme.primary),
                ),)
                ,
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
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => MinePage(memberId: memberId),
              //   ),
              // );
              if (type == 'reply') {
                Get.toNamed('/member/$memberId/replies');
              }
              if (type == 'topic') {
                Get.toNamed('/member/$memberId/topics');
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
    return
        // Skeleton(
        // child:
        CustomScrollView(
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
                  tag: heroTag,
                  child: CAvatar(
                    url: memberAvatar,
                    size: 80,
                    quality: 'origin',
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                    child: Skeleton(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        memberId,
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
                const SizedBox(
                  height: 4,
                ),
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
          child: Skeleton(child: Column(
            children: const[
              TopicItemSkeleton(),
              TopicItemSkeleton(),
              TopicItemSkeleton(),
            ],
          )),
        ),
        titleLine('最近回复', '')
      ],
      // ),
    );
  }
}
