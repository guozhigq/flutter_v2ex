import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ListItem extends StatefulWidget {
  ListItem({required this.index, required this.item, super.key});
  int index = 0;
  Map<dynamic, dynamic> item;

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.only(top: 8, right: 12, bottom: 0, left: 12),
        child: Material(
          color: Theme.of(context).colorScheme.onInverseSurface,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(15),
              child: content(),
            ),
          ),
        ),
      ),
    );
  }

  Widget content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // 头像、昵称
        Row(
          // 两端对齐
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  clipBehavior: Clip.antiAlias,
                  margin: const EdgeInsets.only(right: 10),
                  child: Image.asset(
                    'assets/images/avatar.png',
                    fit: BoxFit.cover,
                    width: 33,
                    height: 33,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // ignore: sized_box_for_whitespace
                    Container(
                      width: 100,
                      child: Text(
                        widget.item['name'],
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 13.0,
                          height: 1.5,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          widget.item['time'],
                          style: const TextStyle(
                            fontSize: 10.0,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(width: 7),
                        const Text(
                          '评论 200',
                          style: TextStyle(
                            fontSize: 10.0,
                            height: 1.3,
                          ),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
            Material(
              borderRadius: BorderRadius.circular(50),
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 3.5, horizontal: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // const Icon(Icons.workspaces_outlined, size: 14),
                      // const SizedBox(width: 2.5),
                      Text(
                        widget.item['node'],
                        style: const TextStyle(
                          fontSize: 11.0,
                          textBaseline: TextBaseline.ideographic,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        // title
        Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.only(top: 10, bottom: 3),
          child: Text(
            Characters(widget.item['title']).join('\u{200B}'),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 14.0,
            ),
          ),
        ),
      ],
    );
  }
}
