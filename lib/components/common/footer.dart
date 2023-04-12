import 'package:flutter/material.dart';

class FooterTips extends StatelessWidget {
  final String? type;
  const FooterTips({Key? key, this.type = 'noMore'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100 + MediaQuery.of(context).padding.bottom,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if(type == 'noMore')
              const Icon(Icons.auto_awesome),
            if(type == 'loading')
              SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground,
                      strokeWidth: 2.0)),
            const SizedBox(width: 16),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type == 'noMore' ? '加载完成' : '加载中...'),
                const SizedBox(
                  height: 4,
                ),
                Text('最后更新于刚刚', style: Theme.of(context).textTheme.bodySmall)
              ],
            )
          ],
        ),
      ),
    );
  }
}
