import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_v2ex/components/detail/reply_new.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  HelpPageState createState() => HelpPageState();
}

class HelpPageState extends State<HelpPage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      floatingActionButton: const _ReplyFab(),
    );
  }
}

class _ReplyFab extends StatefulWidget {
  const _ReplyFab();

  @override
  _ReplyFabState createState() => _ReplyFabState();
}

class _ReplyFabState extends State<_ReplyFab>
    with SingleTickerProviderStateMixin {
  // static final fabKey = UniqueKey();
  static const double _mobileFabDimension = 56;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const circleFabBorder = CircleBorder();

    return OpenContainer(
      openBuilder: (context, closedContainer) {
        return const Text('123');
      },
      transitionDuration: const Duration(milliseconds: 350),
      // openColor: theme.cardColor,
      // openColor: Theme.of(context).colorScheme.background,
      closedShape: circleFabBorder,
      closedColor: theme.colorScheme.secondary,
      closedElevation: 6,
      openElevation: 4,
      closedBuilder: (context, openContainer) {
        return Tooltip(
          message: 'tooltip',
          child: InkWell(
            key: const ValueKey('ReplyFab'),
            customBorder: circleFabBorder,
            onTap: openContainer,
            child: const SizedBox(
              height: _mobileFabDimension,
              width: _mobileFabDimension,
              child: Center(
                // child: fabSwitcher,
                child: Icon(Icons.percent),
              ),
            ),
          ),
        );
      },
    );
  }
}
