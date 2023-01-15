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
        httpHeaders: const {
          'authority': 'cdn.v2ex.com',
          'method': 'GET',
          'path': '/avatar/9e4b/c61b/561400_xlarge.png?m=1667209262',
          'scheme': 'https',
          'accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
          'accept-encoding': 'gzip, deflate, br',
          'accept-language': 'zh-CN,zh;q=0.9',
          'cache-control': 'no-cache',
          'pragma': 'no-cache',
          'sec-ch-ua':
              '"Not?A_Brand";v="8", "Chromium";v="108", "Google Chrome";v="108"',
          'sec-ch-ua-mobile': '?0',
          'sec-ch-ua-platform': "macOS",
          'sec-fetch-dest': 'document',
          'sec-fetch-mode': 'navigate',
          'sec-fetch-site': 'none',
          'sec-fetch-user': '?1',
          'upgrade-insecure-requests': '1',
          'user-agent':
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36'
        },
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
          child: Center(
            child: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          // color: Colors.grey,
        ),
      ),
    );
  }
}
