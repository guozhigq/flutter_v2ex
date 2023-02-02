import 'package:flutter/material.dart';
import 'package:flutter_v2ex/components/detail/html_render.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:flutter_v2ex/models/web/model_member_profile.dart';
import 'package:flutter_v2ex/components/mine/topic_item.dart';
import 'package:flutter_v2ex/components/mine/reply_item.dart';
import 'package:flutter_v2ex/pages/tabs/mine_page.dart';
import 'package:flutter_v2ex/components/common/avatar.dart';

class ProfilePage extends StatefulWidget {
  String memberId = '';
  String? memberAvatar = '';
  String? heroTag = '';

  ProfilePage(
      {required this.memberId, this.memberAvatar, this.heroTag, Key? key})
      : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ModelMemberProfile memberProfile = ModelMemberProfile();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    queryMemberProfile();
  }

  Future<ModelMemberProfile> queryMemberProfile() async {
    var res = await DioRequestWeb.queryMemberProfile(widget.memberId);
    setState(() {
      memberProfile = res;
      _loading = false;
    });
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
                  actions: memberProfile.isOwner
                      ? [
                          IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.grid_view_rounded)),
                          const SizedBox(width: 12)
                        ]
                      : [
                          IconButton(
                              tooltip: '关注',
                              onPressed: () {},
                              icon: Icon(
                                Icons.favorite_border,
                                color: Theme.of(context).colorScheme.primary,
                              )),
                          IconButton(
                              tooltip: 'Block',
                              onPressed: () {},
                              icon: Icon(
                                Icons.not_interested,
                                color: Theme.of(context).colorScheme.error,
                              )),
                          const SizedBox(width: 12)
                        ],
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        '@${memberProfile.memberId} \' 个人信息',
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
                        Hero(
                          tag: widget.heroTag!,
                          child: CAvatar(url: widget.memberAvatar!, size: 80),
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
                if (memberProfile.socialList.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Container(
                      margin:
                          const EdgeInsetsDirectional.only(top: 30, bottom: 15),
                      padding: const EdgeInsets.only(left: 15, right: 2),
                      child: Text('社交',
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
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
                  SliverToBoxAdapter(
                    child: Container(
                      margin:
                          const EdgeInsetsDirectional.only(top: 30, bottom: 15),
                      padding: const EdgeInsets.only(left: 15, right: 2),
                      child: Text('说明',
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: HtmlRender(
                        htmlContent: memberProfile.mbSign,
                      ),
                    ),
                  ),
                ],
                titleLine('最近发布'),
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
                        '根据 ${widget.memberId} 的设置，主题列表被隐藏',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  )
                ],
                titleLine('最近回复'),
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
                        '根据 ${widget.memberId} 的设置，回复列表被隐藏',
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
            onPressed: () => {},
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/social/${i.type}.png',
                    width: 25, height: 25),
                const SizedBox(width: 2),
                Text(
                  i.name,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return list;
  }

  Widget titleLine(title) {
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MinePage(memberId: widget.memberId),
                ),
              );
            },
            child: Container(
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
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 120,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
              title: Text(
                '@${widget.memberId} \' 个人信息',
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
                  tag: widget.heroTag!,
                  child: CAvatar(url: widget.memberAvatar!, size: 80),
                ),
                const SizedBox(width: 20),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 20,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onInverseSurface,
                          borderRadius: BorderRadius.all(Radius.circular(2))),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 170,
                      height: 20,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onInverseSurface,
                          borderRadius: BorderRadius.all(Radius.circular(2))),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      width: 120,
                      height: 20,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onInverseSurface,
                          borderRadius: BorderRadius.all(Radius.circular(2))),
                    ),
                  ],
                )),
              ],
            ),
          ),
        ),
        titleLine('最近发布'),
        titleLine('最近回复')
      ],
    );
  }
}
