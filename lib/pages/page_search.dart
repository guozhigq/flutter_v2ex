import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_v2ex/http/soV2ex.dart';
import 'package:flutter_v2ex/components/common/pull_refresh.dart';
import 'package:flutter_v2ex/components/common/skeleton_topic.dart';
import 'package:flutter_v2ex/components/common/node_tag.dart';
import 'package:flutter_v2ex/components/topic/html_render.dart';
import 'package:flutter_v2ex/components/search/menu.dart';


class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final ScrollController _controller = ScrollController();
  SoV2exRes searchRes = SoV2exRes();
  List<HitsList>? hitsList = [];
  int pageCount = 20;
  int _currentPage = 0;
  int _totalPage = 1;
  bool showBackTopBtn = false;
  bool _isLoading = true;
  bool _isBlock = false;
  String searchKeyWord = '';
  TextEditingController controller = TextEditingController();

  String sortType = 'created';
  int orderType = 0;
  int startTime = 0;
  int endTime = 0;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controller.addListener(
      () {
        var screenHeight = MediaQuery.of(context).size.height;
        if (_controller.offset >= screenHeight && showBackTopBtn == false) {
          setState(() {
            showBackTopBtn = true;
          });
        } else if (_controller.offset < screenHeight && showBackTopBtn) {
          setState(() {
            showBackTopBtn = false;
          });
        }
      },
    );

    search();
  }

  Future<SoV2exRes> search() async {
    SoV2exRes res = SoV2exRes();
    if (searchKeyWord.isEmpty || searchKeyWord == '') {
      setState(() {
        _isLoading = false;
        _isBlock = true;
      });
      return res;
    }
    if(_currentPage == 0) {
      setState(() {
        _isLoading = true;
        _isBlock = false;
      });
    }
    res = await SoV2ex.onSearch(
        searchKeyWord,
        _currentPage * pageCount,
        pageCount,
        sort: sortType,
        order: orderType,
        gte: startTime,
        lte: endTime
    );
    setState(() {
      if (res.total > 0) {
        if (_currentPage == 0) {
          hitsList = res.hits;
          _totalPage = (res.total / pageCount).ceil();
        } else {
          hitsList!.addAll(res.hits);
        }
      } else if(res.total == 0) {
        // 无结果
        hitsList = [];
        _isBlock = true;
      }
      _currentPage += 1;
      _isLoading = false;
    });
    return res;
  }

  // 排序方式
  void setSort(String sortTypeVal) {
    setState(() {
      sortType = sortTypeVal;
      _currentPage = 0;
    });
    search();
  }

  // 升降序
  void setOrder(int orderTypeVal) {
    setState(() {
      orderType = orderTypeVal;
      _currentPage = 0;
    });
    search();
  }

  // 起始时间
  void setStartTime(int startTimeVal) {
    setState(() {
      startTime = startTimeVal;
      _currentPage = 0;
    });
    search();
  }

  // 结束时间
  void setEndTime(int endTimeVal) {
    setState(() {
      endTime = endTimeVal;
      _currentPage = 0;
    });
    search();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title:TextField(
                controller: controller,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: '搜索功能由soV2ex提供',
                  border: InputBorder.none,
                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      onPressed: () {
                        controller.clear();
                        setState(() {
                          hitsList = [];
                        });
                      })
                      : null,
                ),
                onSubmitted: (String value) {
                  setState(() {
                    _currentPage = 0;
                    searchKeyWord = value;
                    _isLoading = true;
                  });
                  search();
                },
              ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: SearchMenu(
              setSort: setSort,
              setOrder: setOrder,
              setStartTime: setStartTime,
              setEndTime: setEndTime
          ),
        ),
      ),
      body: Stack(
        children: [
          Scrollbar(
            controller: _controller,
            radius: const Radius.circular(10),
            child: _isLoading
                ? const TopicSkeleton()
                : Container(
                    // margin: const EdgeInsets.only(right: 12, left: 12),
                    child: hitsList!.isNotEmpty
                        ? PullRefresh(
                            totalPage: _totalPage,
                            currentPage: _currentPage,
                            onChildLoad:
                                _totalPage > 1 && _currentPage <= _totalPage
                                    ? search
                                    : null,
                            child: wrap(),
                          )
                        : Center(
                      child: Text('未找到内容', style: Theme.of(context).textTheme.titleMedium,),
                    )
            ),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: AnimatedScale(
              scale: showBackTopBtn ? 1 : 0,
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
        ],
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
                    Get.toNamed("/t/${hitsList![index].id}");
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Ink(
                    padding: const EdgeInsets.fromLTRB(12, 15, 12, 12),
                    child: content(hitsList![index]),
                  ),
                ),
              ),
            );
          }, childCount: hitsList!.length),
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
