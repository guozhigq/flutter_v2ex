import 'package:flutter/material.dart';
import 'package:flutter_v2ex/http/dio_web.dart';
import 'package:flutter_v2ex/models/web/model_topic_detail.dart';

class DetailBottomBar extends StatefulWidget {
  final VoidCallback? onRefresh;
  final VoidCallback? onLoad;
  final bool? isVisible;
  final TopicDetailModel? detailModel;

  const DetailBottomBar({
    this.onRefresh,
    this.onLoad,
    this.isVisible,
    this.detailModel,
    super.key,
  });
  @override
  State<DetailBottomBar> createState() => _DetailBottomBarState();
}

class _DetailBottomBarState extends State<DetailBottomBar> {
  @override
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      height: widget.isVisible! ? 96.0 : 0,
      child: BottomAppBar(
        elevation: 1,
        child: Row(
          children: <Widget>[
            IconButton(
              tooltip: '返回顶部',
              icon: const Icon(Icons.vertical_align_top_rounded),
              onPressed: widget.onRefresh,
            ),
            // IconButton(
            //   tooltip: '赞',
            //   icon: const Icon(Icons.thumb_up_outlined),
            //   onPressed: () {},
            // ),
            IconButton(
              tooltip: '感谢',
              icon: const Icon(Icons.mood),
              onPressed: () => showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('提示'),
                  content: const Text('确认向本主题创建者表示感谢吗？'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: const Text('手误了'),
                    ),
                    TextButton(
                      // onPressed: () => Navigator.pop(context, 'OK'),
                      onPressed: (() async {
                        var res = await DioRequestWeb.thankTopic(
                            widget.detailModel!.topicId);
                        if (res) {
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context, 'OK');
                          setState(() {
                            widget.detailModel!.isThank = true;
                          });
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('感谢支持'),
                              duration: Duration(milliseconds: 500),
                              showCloseIcon: true,
                            ),
                          );
                        }
                      }),
                      child: const Text('确定'),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              tooltip: '在浏览器中打开',
              icon: const Icon(Icons.language_rounded),
              onPressed: () {},
            ),
            IconButton(
              tooltip: '分享',
              icon: const Icon(Icons.share_outlined),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
