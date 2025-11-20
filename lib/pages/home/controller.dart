import 'package:get/get.dart';
import 'package:flutter_v2ex/utils/logger.dart';

class TabStateController extends GetxController {
  RxInt tabIndex = 999.obs;
  RxList actionCounts = [].obs;
  RxString balance = ''.obs;
  void setTabIndex(index) {
    tabIndex.value = index;
  }

  void setActionCounts(list) {
    actionCounts.value = list;
  }

  void setBalance(str) {
    logDebug('金币： $balance');
    balance.value = str;
  }
}
