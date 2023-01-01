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
        margin: const EdgeInsets.only(top: 0, right: 12, bottom: 8, left: 12),
        child: Material(
          color: Theme.of(context).colorScheme.onInverseSurface,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            // splashColor: Theme.of(context).colorScheme.primaryContainer,
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

  void _showSnackBar() {
    final snackBar = SnackBar(
      content: const Text('已添加到收藏'),
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
        label: '取消',
        onPressed: () {
          // ignore: avoid_print
          print('_showSnackBar');
          // Some code to undo the change.
        },
      ),
    );

    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
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
                    width: 38,
                    height: 38,
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
                          fontSize: 14.0,
                          height: 1.5,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Text(
                      widget.item['time'],
                      style: const TextStyle(
                        fontSize: 10.0,
                        height: 1.3,
                      ),
                    ),
                  ],
                )
              ],
            ),
            Ink(
              padding: const EdgeInsets.all(0),
              decoration: const ShapeDecoration(
                shape: CircleBorder(),
              ),
              child: GestureDetector(
                child: IconButton(
                  onPressed: () => setState(_showSnackBar),
                  padding: const EdgeInsets.all(10),
                  icon: const Icon(
                    Icons.star_border_rounded,
                    size: 25,
                  ),
                  selectedIcon: const Icon(Icons.star),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.only(bottom: 6),
          child: Text(
            widget.item['title'],
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 14.0,
            ),
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.item['content'],
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 12.0,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 10),
          child: Material(
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
                    const Icon(Icons.workspaces_outlined, size: 14),
                    const SizedBox(width: 2.5),
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
        ),
      ],
    );
  }
}
