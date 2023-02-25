import 'package:flutter/material.dart';
import 'package:flutter_v2ex/utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_v2ex/components/common/image_loading.dart';

class CAvatar extends StatelessWidget {
  final String url;
  final double size;
  final int radius = 50;
  final Duration? fadeOutDuration;
  final Duration? fadeInDuration;
  final String? quality;

  const CAvatar({
    Key? key,
    required this.url,
    required this.size,
    this.fadeOutDuration,
    this.fadeInDuration,
    this.quality,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: quality == 'origin' ? Utils().avatarLarge(url) : url,
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
        errorWidget: (context, url, error) => placeholder(context),
        placeholder: (context, url) => placeholder(context),
      ),
      // child: ImageLoading(
      //   imgUrl: Utils().avatarLarge(url),
      //   width: size,
      //   height: size,
      //   type: 'avatar',
      // ),
    );
  }

  Widget placeholder(context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onInverseSurface,
      ),
      clipBehavior: Clip.antiAlias,
      child: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
          backgroundImage: const AssetImage('assets/images/avatar.png')),
    );
  }
}
