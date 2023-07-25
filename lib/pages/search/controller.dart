import 'package:flutter/material.dart';
import 'package:flutter_v2ex/http/soV2ex.dart';
import 'package:flutter_v2ex/service/search.dart';
import 'package:get/get.dart';

class SSearchController extends GetxController {
  SoV2exRes searchRes = SoV2exRes();
  List<HitsList>? hitsList = [];
  int pageCount = 20;
  RxInt currentPage = 0.obs;
  RxInt totalPage = 1.obs;
  bool showBackTopBtn = false;
  RxBool isLoading = false.obs;
  RxString searchKeyWord = ''.obs;
  Rx<TextEditingController> controller = TextEditingController().obs;

  String sortType = 'created';
  int orderType = 0;
  int startTime = 0;
  int endTime = 0;
  Rx<FocusNode> replyContentFocusNode = FocusNode().obs;

  Future<SoV2exRes> search() async {
    isLoading.value = true;
    SoV2exRes res = SoV2exRes();
    if (searchKeyWord.isEmpty || searchKeyWord == '') {
      isLoading.value = false;
      return res;
    }
    Search().add(searchKeyWord.value);
    if (currentPage.value == 0) {
      isLoading.value = true;
    }
    res = await SoV2ex.onSearch(
        searchKeyWord.value, currentPage.toInt() * pageCount, pageCount,
        sort: sortType, order: orderType, gte: startTime, lte: endTime);
    if (res.total > 0) {
      if (currentPage.value == 0) {
        hitsList = res.hits;
        totalPage.value = (res.total / pageCount).ceil();
      } else {
        hitsList!.addAll(res.hits);
      }
    } else if (res.total == 0) {
      // 无结果
      hitsList = [];
    }
    currentPage.value += 1;
    isLoading.value = false;
    return res;
  }

  // 排序方式
  void setSort(String sortTypeVal) {
    sortType = sortTypeVal;
    currentPage.value = 0;
    search();
  }

  // 升降序
  void setOrder(int orderTypeVal) {
    orderType = orderTypeVal;
    currentPage.value = 0;
    search();
  }

  // 起始时间
  void setStartTime(int startTimeVal) {
    startTime = startTimeVal;
    currentPage.value = 0;
    search();
  }

  // 结束时间
  void setEndTime(int endTimeVal) {
    endTime = endTimeVal;
    currentPage.value = 0;
    search();
  }

  void onSelect(text) async {
    searchKeyWord.value = text;
    controller.value.text = text;
    // 移动光标
    controller.value.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.value.text.length),
    );
    replyContentFocusNode.value.unfocus();
    search();
  }

  void onClear() {
    controller.value.clear();
    searchKeyWord.value = '';
    currentPage.value = 0;
    hitsList = [];
  }

  void submit(value) {
    currentPage.value = 0;
    searchKeyWord.value = value;
    isLoading.value = true;
    search();
  }

  void onChange(value) {
    searchKeyWord.value = value;
  }
}
