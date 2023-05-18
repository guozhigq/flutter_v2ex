import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_v2ex/http/user.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:flutter_v2ex/utils/storage.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_v2ex/models/web/model_member_profile.dart';

class MemberController extends GetxController {
  ModelMemberProfile memberProfile = ModelMemberProfile();
  Map signDetail = {};
  String memberId = '';
  String memberAvatar = '';
  String heroTag = '';
  bool isOwner = false;
  Function()? onRefreshSign;
  Function()? onRefreshFollow;
  Function()? onRefreshBlock;

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();

    var mapKey = Get.parameters.keys;
    memberId = mapKey.contains('memberId') ? Get.parameters['memberId']! : '';
    memberAvatar =
        mapKey.contains('memberAvatar') ? Get.parameters['memberAvatar']! : '';
    heroTag = mapKey.contains('heroTag') ? Get.parameters['heroTag']! : '';

    if (GStorage().getUserInfo().isNotEmpty) {
      if (memberId == GStorage().getUserInfo()['userName']) {
        isOwner = true;
      }
      // 查询签到状态、余额、消息提醒
      await queryDaily();
    }
  }

  Future<Map<dynamic, dynamic>> queryDaily() async {
    var res = await DioRequestWeb.queryDaily();
    signDetail = res;
    if (onRefreshSign != null) {
      onRefreshSign!.call();
    }
    return res;
  }

  Future<ModelMemberProfile> queryMemberProfile() async {
    var res = await UserWebApi.queryMemberProfile(memberId);
    memberProfile = res;
    return res;
  }

  //  签到领取奖励
  void dailyMission() async {
    SmartDialog.showLoading(msg: '领取中...');
    var res = await DioRequestWeb.dailyMission();
    SmartDialog.dismiss();
    SmartDialog.showToast(res);
    queryDaily();
  }

  // 关注用户
  void onFollowMemeber(context) {
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
    bool res = await UserWebApi.onFollowMember(followId, followStatus);
    if (res) {
      SmartDialog.showToast(followStatus ? '已取消关注' : '关注成功');
      memberProfile.isFollow = !followStatus;
      onRefreshFollow!.call();
    } else {
      SmartDialog.showToast('操作失败');
    }
    return res;
  }

  // 屏蔽用户
  void onBlockMember(context) {
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
            child: Text(memberProfile.isBlock ? '取消屏蔽' : '确认屏蔽'),
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
    bool res = await UserWebApi.onBlockMember(blockId, blockStatus);
    if (res) {
      SmartDialog.showToast(blockStatus ? '已取消屏蔽' : '屏蔽成功');
      memberProfile.isBlock = !blockStatus;
      onRefreshBlock!.call();
      // if(!blockStatus && followStatus){
      //   memberProfile.isFollow = false;
      // }
    } else {
      SmartDialog.showToast('操作失败');
    }
    return res;
  }
}
