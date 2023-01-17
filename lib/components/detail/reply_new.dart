import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReplyNew extends StatefulWidget {
  var statusHeight;
  ReplyNew({this.statusHeight, super.key});

  @override
  State<ReplyNew> createState() => _ReplyNewState();
}

class _ReplyNewState extends State<ReplyNew> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - widget.statusHeight,
      padding: const EdgeInsets.only(top: 25, left: 12, right: 12),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                tooltip: '关闭弹框',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(9),
                    backgroundColor: Theme.of(context).colorScheme.background),
              ),
              Text(
                '回复楼主',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                tooltip: '清空内容',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.clear_all_rounded),
                style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(9),
                    backgroundColor: Theme.of(context).colorScheme.background),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: -1,
                  children: [
                    const Text(' 回复：'),
                    TextButton(
                      onPressed: () => {},
                      child: const Text('guozhigq'),
                    ),
                    TextButton(
                      onPressed: () => {},
                      child: const Text('guozhigq'),
                    ),
                    TextButton(
                      onPressed: () => {},
                      child: const Text('guozhigq'),
                    )
                  ],
                ),
              ),
              // SizedBox(
              //   width: 100,
              //   height: 50,
              //   child: ElevatedButton(
              //       onPressed: () => {}, child: const Icon(Icons.send)),
              // ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.only(
                  top: 12,
                  right: 20,
                  left: 20,
                  bottom: MediaQuery.of(context).padding.bottom + 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: TextField(
                minLines: 1,
                maxLines: null,
                decoration: const InputDecoration(
                    hintText: "输入回复内容", border: InputBorder.none),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
          // Container(
          //   width: double.infinity,
          //   height: 60,
          //   clipBehavior: Clip.hardEdge,
          //   margin: const EdgeInsets.only(top: 10, bottom: 30),
          //   decoration: BoxDecoration(
          //       color: Theme.of(context).colorScheme.background,
          //       borderRadius: BorderRadius.circular(30)),
          //   child: ElevatedButton(
          //     onPressed: () => {},
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: const [
          //         Icon(Icons.send),
          //         SizedBox(width: 10),
          //         Text('发送')
          //       ],
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }
}
