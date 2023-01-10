import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CAvatar extends StatelessWidget {
  final String url;
  final double size;
  final int radius = 50;

  const CAvatar({Key? key, required this.url, required this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        height: size,
        width: size,
        fit: BoxFit.cover,
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
