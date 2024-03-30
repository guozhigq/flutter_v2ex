import 'package:flutter/material.dart';
import 'package:flutter_v2ex/components/search/history.dart';
import 'package:flutter_v2ex/pages/search/index.dart';
import 'package:get/get.dart';
import 'package:flutter_v2ex/components/common/pull_refresh.dart';
import 'package:flutter_v2ex/components/common/skeleton_topic.dart';
import 'widgets/appbar.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final SSearchController _searchController = Get.put(SSearchController());
  final ScrollController _controller = ScrollController();
  late double _screenHeight;

  @override
  void initState() {
    super.initState();
    _searchController.searchHistory();
    _controller.addListener(_handleScroll);
  }

  void _handleScroll() {
    var shouldShowBackTopBtn = _controller.offset >= _screenHeight;
    if (_searchController.showBackTopBtn.value != shouldShowBackTopBtn) {
      _searchController.showBackTopBtn.value = shouldShowBackTopBtn;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _screenHeight = MediaQuery.of(context).size.height;
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
        _searchController.resetSearch();
      },
      child: Scaffold(
        appBar: SAppBar(),
        body: Stack(
          children: [
            // 显示滚动条
            Scrollbar(
              controller: _controller,
              radius: const Radius.circular(10),
              child: Obx(
                () => _searchController.isLoading.value &&
                        _searchController.currentPage.value == 0
                    ? const TopicSkeleton()
                    : Container(
                        child: _searchController.resultsList.isNotEmpty
                            ? PullRefresh(
                                totalPage: _searchController.totalPage.value,
                                currentPage:
                                    _searchController.currentPage.value,
                                onChildLoad: _searchController.totalPage > 1 &&
                                        _searchController.currentPage <=
                                            _searchController.totalPage.value
                                    ? _searchController.search
                                    : null,
                                child: wrap(),
                              )
                            : _searchController
                                        .searchKeyWord.value.isNotEmpty &&
                                    _searchController.hasRequest.value
                                ? Center(
                                    child: Text(
                                      '未找到内容',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  )
                                : SearchHistory(
                                    searchHisList:
                                        _searchController.searchHistoryList,
                                    onSelect: (text) =>
                                        _searchController.onSelect(text),
                                    onClear: () => _searchController.onClear(),
                                  ),
                      ),
              ),
            ),
            // 返回顶部
            Positioned(
              right: 20,
              bottom: 20,
              child: Obx(
                () => AnimatedScale(
                  scale: _searchController.showBackTopBtn.value ? 1 : 0,
                  curve: Curves.easeOut,
                  duration: const Duration(milliseconds: 300),
                  child: FloatingActionButton(
                    heroTag: null,
                    child: const Icon(Icons.vertical_align_top_rounded),
                    onPressed: () {
                      _controller.animateTo(0,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.ease);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget wrap() {
    return CustomScrollView(
      controller: _controller,
      slivers: [
        const SliverToBoxAdapter(
          child: SizedBox(height: 8),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            return Container(
              margin:
                  const EdgeInsets.only(top: 0, right: 12, bottom: 7, left: 12),
              child: Material(
                color: Theme.of(context).colorScheme.onInverseSurface,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () {
                    // var arguments = <String, TabTopicItem>{"topic": widget.topic};
                    Get.toNamed(
                        "/t/${_searchController.resultsList[index].id}");
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Ink(
                    padding: const EdgeInsets.fromLTRB(12, 15, 12, 12),
                    child: content(_searchController.resultsList[index]),
                  ),
                ),
              ),
            );
          }, childCount: _searchController.resultsList.length),
        )
      ],
    );
  }

  Widget content(hitItem) {
    var source = hitItem.source;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // title
        Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.only(top: 0, bottom: 3),
          child: Text(
            Characters(source.title).join('\u{200B}'),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(height: 1.6, fontWeight: FontWeight.w500),
          ),
        ),
        if (source.content != null && source.content.isNotEmpty)
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(top: 0, bottom: 12),
            height: 20,
            // child: HtmlRender(
            //     htmlContent: source.content
            // ),
            child: Text(source.content),
          ),
        // 头像、昵称
        Row(
          // 两端对齐
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 15,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 150,
                          child: Text(
                            source.member,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1.5),
                    Row(
                      children: [
                        Text(
                          source.created,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall!
                              .copyWith(
                                  color: Theme.of(context).colorScheme.outline),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
            if (source.replies > 0)
              Material(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: InkWell(
                  borderRadius: BorderRadius.circular(50),
                  child: Ink(
                    padding: const EdgeInsets.symmetric(
                        vertical: 3.5, horizontal: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          source.replies.toString(),
                          style: const TextStyle(
                            fontSize: 11.0,
                            textBaseline: TextBaseline.ideographic,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
          ],
        ),
      ],
    );
  }
}
