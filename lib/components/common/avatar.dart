import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CAvatar extends StatelessWidget {
  final String url;
  final double size;
  final int radius = 50;

  const CAvatar({
    Key? key,
    required this.url,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl:
            'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fc-ssl.duitang.com%2Fuploads%2Fblog%2F202106%2F05%2F20210605015054_1afb0.thumb.1000_0.jpeg&refer=http%3A%2F%2Fc-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1676034634&t=a66f33b968f7f967882d40e0a3bc3055',
        // imageUrl: url,
        height: size,
        width: size,
        fit: BoxFit.cover,
        fadeOutDuration: const Duration(milliseconds: 800),
        fadeInDuration: const Duration(milliseconds: 300),
        // progressIndicatorBuilder: (context, url, downloadProgress) =>
        //     CircularProgressIndicator(
        //   value: downloadProgress.progress,
        //   strokeWidth: 3,
        // ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
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
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
