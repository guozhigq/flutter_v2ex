import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_v2ex/utils/storage.dart';

class SetFontPage extends StatefulWidget {
  const SetFontPage({Key? key}) : super(key: key);

  @override
  State<SetFontPage> createState() => _SetFontPageState();
}

class _SetFontPageState extends State<SetFontPage> {
  // 获取当前字体大小
  double _currentGlobalSize = GStorage().getGlobalFs();
  double _currentHtmlSize = GStorage().getHtmlFs();
  double _currentReplySize = GStorage().getReplyFs();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () {
              GStorage().setHtmlFs(_currentHtmlSize);
              GStorage().setReplyFs(_currentReplySize);
              if (_currentGlobalSize != GStorage().getGlobalFs()) {
                GStorage().setGlobalFs(_currentGlobalSize);
                Get.forceAppUpdate();
              }
              SmartDialog.showToast('设置成功');
              Get.back();
            },
            child: const Text('保存'),
          ),
          const SizedBox(width: 12)
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('全局字体', style: Theme.of(context).textTheme.titleMedium),
                  Text(_currentGlobalSize.toString(),
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),
            Slider(
              value: _currentGlobalSize,
              max: 22,
              divisions: 9,
              min: 13,
              label: _currentGlobalSize.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _currentGlobalSize = value;
                });
              },
            ),
            // const Divider(),
            // Container(
            //   width: double.infinity,
            //   padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Text('正文字体', style: Theme.of(context).textTheme.titleMedium),
            //       Text(_currentHtmlSize.toString(),
            //           style: Theme.of(context).textTheme.titleMedium),
            //     ],
            //   ),
            // ),
            // Slider(
            //   value: _currentHtmlSize,
            //   max: 20,
            //   divisions: 7,
            //   min: 13,
            //   label: _currentHtmlSize.round().toString(),
            //   onChanged: (double value) {
            //     setState(() {
            //       _currentHtmlSize = value;
            //     });
            //   },
            // ),
            // const Divider(),
            // Container(
            //   width: double.infinity,
            //   padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Text('评论字体', style: Theme.of(context).textTheme.titleMedium),
            //       Text(_currentReplySize.toString(),
            //           style: Theme.of(context).textTheme.titleMedium),
            //     ],
            //   ),
            // ),
            // Slider(
            //   value: _currentReplySize,
            //   max: 18,
            //   divisions: 5,
            //   min: 13,
            //   label: _currentReplySize.round().toString(),
            //   onChanged: (double value) {
            //     setState(() {
            //       _currentReplySize = value;
            //     });
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
