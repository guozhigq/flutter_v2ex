import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_v2ex/http/soV2ex.dart';
import 'package:flutter_v2ex/models/web/item_tab_topic.dart';
import 'package:flutter_v2ex/components/home/list_item.dart';
import 'package:flutter_v2ex/models/web/model_topic_follow.dart';
import 'package:flutter_v2ex/components/common/pull_refresh.dart';
import 'package:flutter_v2ex/components/common/skeleton_topic.dart';
import 'package:flutter_v2ex/components/common/node_tag.dart';
import 'package:flutter_v2ex/components/topic/html_render.dart';


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
    if(searchKeyWord.isEmpty || searchKeyWord == ''){
      setState(() {
        _isLoading = false;
        _isBlock = true;
      });
      return res;
    }
    res = await SoV2ex.onSearch(searchKeyWord, _currentPage * pageCount, pageCount);
    setState(() {
      if (res.total > 0) {
        if(_currentPage == 0) {
          hitsList = res.hits;
          _totalPage = (res.total / pageCount).ceil();
        }else{
          hitsList!.addAll(res.hits);
        }
      }else{
        // 无结果
        _isBlock = true;
      }
      _currentPage += 1;
      _isLoading = false;

      print(_totalPage);
    });
    return res;
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
        title:  TextField(
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration.collapsed(
            hintText: '搜索功能由soV2ex提供',
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
      ),
      body: Stack(
        children: [
          Scrollbar(
            controller: _controller,
            radius: const Radius.circular(10),
            child: _isLoading
                ? const TopicSkeleton()
                : Container(
                    margin: const EdgeInsets.only(right: 12, left: 12),
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
                        : null
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
                  const EdgeInsets.only(top: 0, right: 0, bottom: 7, left: 0),
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
          // child: HtmlRender(
          //     htmlContent: source.title
          // ),
        ),
        if(source.content != null && source.content.isNotEmpty)
        Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.only(top: 0, bottom: 12),
          height: 20,
          child: HtmlRender(
              htmlContent: source.content
          ),
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
                        Icon(Icons.person, size: 15, color: Theme.of(context).colorScheme.outline,),
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
                                    color:
                                        Theme.of(context).colorScheme.outline),
                          ),
                        if (source.replies > 0) ...[
                          const SizedBox(width: 10),
                          Text(
                            '${source.replies} 回复',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.outline),
                          ),
                        ]
                      ],
                    )
                  ],
                )
              ],
            ),

              NodeTag(
                  nodeId: source.node.toString(),
                  nodeName: source.node.toString(),
                  route: 'home')

          ],
        ),
      ],
    );
  }
}
