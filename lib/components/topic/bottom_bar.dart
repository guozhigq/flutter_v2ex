import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
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
  void onThankAction() {
    if (widget.detailModel!.isThank) {
      SmartDialog.showToast('这个主题已经被感谢过了');
    } else {
      showDialog<String>(
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
              onPressed: (() async {
                Navigator.pop(context, 'OK');
                var res =
                    await DioRequestWeb.thankTopic(widget.detailModel!.topicId);
                print('54: $res');
                if (res) {
                  setState(() {
                    widget.detailModel!.isThank = true;
                  });
                  SmartDialog.showToast('感谢成功');
                }
              }),
              child: const Text('确定'),
            ),
          ],
        ),
      );
    }
  }

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
            IconButton(
              tooltip: widget.detailModel != null && widget.detailModel!.isThank ? '已感谢' : '感谢',
              icon: widget.detailModel != null && widget.detailModel!.isThank
                  ? Icon(
                      Icons.favorite_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : const Icon(Icons.favorite_border_rounded),
              onPressed: () => onThankAction(),
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
