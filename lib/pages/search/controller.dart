import 'package:flutter/material.dart';
import 'package:flutter_v2ex/http/soV2ex.dart';
import 'package:flutter_v2ex/service/search.dart';
import 'package:get/get.dart';

class SSearchController extends GetxController {
  SoV2exRes searchRes = SoV2exRes();
  late RxList<HitsList> resultsList = <HitsList>[].obs;
  late RxList searchHistoryList = [].obs;
  int pageCount = 20; // 每页数量
  RxInt currentPage = 0.obs; // 当前页
  RxInt totalPage = 1.obs; // 总页数
  RxBool showBackTopBtn = false.obs; // 返回顶部按钮
  RxBool isLoading = false.obs; // 是否加载中
  RxString searchKeyWord = ''.obs; // 搜索关键词
  Rx<TextEditingController> controller = TextEditingController().obs;
  String sortType = 'created';
  int orderType = 0;
  int startTime = 0;
  int endTime = 0;
  Rx<FocusNode> replyContentFocusNode = FocusNode().obs;
  RxBool hasRequest = false.obs;
  bool canPop = false;

  // 搜索
  Future<SoV2exRes> search() async {
    SoV2exRes res = SoV2exRes();
    if (searchKeyWord.isEmpty || searchKeyWord.value == '') {
      isLoading.value = false;
      return res;
    }
    hasRequest.value = true;
    List historyList = await Search().add(searchKeyWord.value);
    searchHistoryList.value = historyList;
    if (currentPage.value == 0) {
      isLoading.value = true;
    }
    res = await SoV2ex.onSearch(
      searchKeyWord.value,
      currentPage.toInt() * pageCount,
      pageCount,
      sort: sortType,
      order: orderType,
      gte: startTime,
      lte: endTime,
    );
    if (res.total > 0) {
      if (currentPage.value == 0) {
        resultsList.value = res.hits;
        totalPage.value = (res.total / pageCount).ceil();
      } else {
        resultsList.addAll(res.hits);
      }
    } else if (res.total == 0) {
      // 无结果
      resultsList.value = [];
    }
    currentPage.value += 1;
    isLoading.value = false;
    return res;
  }

  void searchHistory() async {
    searchHistoryList.value = await Search().queryList();
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
    resultsList.value = [];
    searchHistoryList.value = [];
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

  void resetSearch() {
    if (!canPop) {
      resultsList.value = [];
      isLoading.value = false;
      searchKeyWord.value = '';
      currentPage.value == 0;
      hasRequest.value = false;
      canPop = true;
    } else {
      Get.back();
    }
  }
}
