import 'package:get/get.dart';

class TabStateController extends GetxController {
  RxInt tabIndex = 999.obs;

  void setTabIndex(index) {
    tabIndex.value = index;
  }
}