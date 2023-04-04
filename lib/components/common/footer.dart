import 'package:flutter/material.dart';

class FooterTips extends StatelessWidget {
  const FooterTips({Key? key}) : super(key: key);

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
            const Icon(Icons.auto_awesome),
            const SizedBox(width: 16),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('加载完成'),
                const SizedBox(
                  height: 4,
                ),
                Text('更新于刚刚', style: Theme.of(context).textTheme.bodySmall)
              ],
            )
          ],
        ),
      ),
    );
  }
}
