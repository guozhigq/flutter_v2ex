import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_v2ex/http/init.dart';
import 'package:flutter_v2ex/models/version.dart';
import 'package:flutter_v2ex/utils/string.dart';
import 'package:flutter_v2ex/utils/utils.dart';
import 'package:flutter_v2ex/utils/logger.dart';

class GithubApi {
  static Future<Map> checkUpdate() async {
    Map update = {
      'lastVersion': '',
      'downloadHref': '',
      'needUpdate': false,
    };
    Response response = await Request().get(
        'https://api.github.com/repos/guozhigq/flutter_v2ex/releases/latest');
    var versionDetail = VersionModel.fromJson(response.data);
    logDebug(versionDetail.tagName);
    // 版本号
    var version = versionDetail.tagName;
    var updateLog = versionDetail.body;
    List<String> updateLogList = updateLog.split('\r\n');
    var localVersion = await Strings.getCurrentVersion();
    var needUpdate = Utils.needUpdate(localVersion, version);
    if (needUpdate) {
      SmartDialog.show(
        useSystem: true,
        animationType: SmartAnimationType.centerFade_otherSlide,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('🎉 发现新版本 '),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  version,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 8),
                for (var i in updateLogList) ...[Text(i)]
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => SmartDialog.dismiss(),
                  child: const Text('取消')),
              TextButton(
                  // TODO
                  onPressed: () {
                    SmartDialog.dismiss();
                    Utils.openURL('${Strings.remoteUrl}/releases');
                  },
                  child: const Text('去更新'))
            ],
          );
        },
      );
    } else {
      update[needUpdate] = true;
    }
    return update;
  }

  // 版本记录
  //https://api.github.com/repos/' + full_name + '/releases
  static Future changeLog() async {
    var res = await Request()
        .get('https://api.github.com/repos/guozhigq/flutter_v2ex/releases');
    return res.data;
  }
}
