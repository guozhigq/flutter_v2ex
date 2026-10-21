import 'package:flutter/material.dart';

/// Floating shortcuts keep the reading viewport stable.
class DetailReadingActions extends StatelessWidget {
  final bool showBackToTop;
  final VoidCallback onBackToTop;
  final VoidCallback? onReply;

  const DetailReadingActions({
    required this.showBackToTop,
    required this.onBackToTop,
    required this.onReply,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (showBackToTop) ...[
            SizedBox(
              width: 56,
              height: 48,
              child: Center(
                child: IconButton.filledTonal(
                  tooltip: '返回顶部',
                  onPressed: onBackToTop,
                  style: IconButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainer,
                    foregroundColor:
                        Theme.of(context).colorScheme.onSurfaceVariant,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 1,
                    shadowColor: Colors.black26,
                  ),
                  icon: const Icon(Icons.expand_less_rounded, size: 24),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          FloatingActionButton(
            heroTag: null,
            elevation: 4,
            onPressed: onReply,
            tooltip: '回复',
            child: const Icon(Icons.edit),
          ),
        ],
      );
}
