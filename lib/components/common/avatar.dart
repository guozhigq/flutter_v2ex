import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CAvatar extends StatelessWidget {
  final String url;
  final double size;
  final int radius = 50;
  final fadeOutDuration;
  final fadeInDuration;

  const CAvatar({
    Key? key,
    required this.url,
    required this.size,
    this.fadeOutDuration,
    this.fadeInDuration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        height: size,
        width: size,
        fit: BoxFit.cover,
        fadeOutDuration: fadeOutDuration ?? const Duration(milliseconds: 800),
        fadeInDuration: fadeInDuration ?? const Duration(milliseconds: 300),
        // progressIndicatorBuilder: (context, url, downloadProgress) =>
        //     CircularProgressIndicator(
        //   value: downloadProgress.progress,
        //   strokeWidth: 3,
        // ),
        errorWidget: (context, url, error) => SizedBox(
          width: size,
          height: size,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
            ),
            clipBehavior: Clip.antiAlias,
            // margin: const EdgeInsets.only(right: 10),
            child: Center(
              child: Icon(
                Icons.person,
                size: size - 10,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        placeholder: (context, url) => SizedBox(
          width: size,
          height: size,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
            ),
            clipBehavior: Clip.antiAlias,
            // margin: const EdgeInsets.only(right: 10),
            child: Center(
              child: Icon(
                Icons.person,
                size: size - 10,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
