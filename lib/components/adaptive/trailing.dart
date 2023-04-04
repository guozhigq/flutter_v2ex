import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';

class TrailingNavRail extends StatelessWidget {
  const TrailingNavRail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:  Breakpoints.large.isActive(context) ? [
              Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.brightness_medium_rounded),
                    iconSize: 19,
                  ),
                  const SizedBox(width: 11),
                  Text('选择主题', style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
              Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.tune_outlined),
                    iconSize: 19,
                  ),
                  const SizedBox(width: 11),
                  Text('设置', style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
              // const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.help_outline_outlined),
                    iconSize: 19,
                  ),
                  const SizedBox(width: 11),
                  Text('帮助', style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ] : [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.brightness_medium_rounded),
                iconSize: 19,
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.tune_outlined),
                iconSize: 19,
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.help_outline_outlined),
                iconSize: 19,
              ),
            ],
          )
      ),
    );
  }
}
