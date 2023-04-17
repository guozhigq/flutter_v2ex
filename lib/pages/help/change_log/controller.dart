import 'package:flutter_v2ex/http/github.dart';
import 'package:get/get.dart';

class ChangeLogController extends GetxController {

  @override
  void onInit() {
    super.onInit();
    queryChangeLog();
  }

  Future queryChangeLog() async{
    var res = await GithubApi.changeLog();
    return res;
  }
}