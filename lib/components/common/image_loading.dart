import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_v2ex/utils/utils.dart';

class ImageLoading extends StatefulWidget {
  const ImageLoading({
    required this.imgUrl,
    this.width,
    this.height,
    this.type,
    this.quality,
    Key? key,
  }) : super(key: key);

  final String imgUrl;
  final double? width;
  final double? height;
  final String? type;
  final String? quality;

  @override
  State<ImageLoading> createState() => _ImageLoadingState();
}

class _ImageLoadingState extends State<ImageLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    // TODO: implement initState
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1000),
        lowerBound: 0.0,
        upperBound: 1.0);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return ExtendedImage.network(
        widget.imgUrl,
        width: widget.type == 'avatar' ? widget.width! : null,
        height: widget.type == 'avatar' ? widget.height! : null,
        fit: BoxFit.cover,
        cacheWidth: widget.quality != '' && widget.quality == 'preview'
            ? constraints.maxWidth.toInt() * 3
            : null,
        cache: true,
        headers: const {'sec-fetch-dest': 'image'},
        loadStateChanged: (ExtendedImageState state) {
          switch (state.extendedImageLoadState) {
            case LoadState.loading:
              _controller.reset();
              return widget.type == 'avatar'
                  ? placeholder(context)
                  : Container(
                      width: double.infinity,
                      height: 60,
                      color: Theme.of(context).colorScheme.onInverseSurface,
                      child: const Center(
                        child: Text('图片加载中...'),
                      ),
                    );

            ///if you don't want override completed widget
            ///please return null or state.completedWidget
            //return null;
            //return state.completedWidget;
            case LoadState.completed:
              _controller.forward();
              return FadeTransition(
                opacity: _controller,
                child: ExtendedRawImage(
                  image: state.extendedImageInfo?.image,
                  width: widget.type == 'avatar' ? widget.width! : null,
                  height: widget.type == 'avatar' ? widget.height! : null,
                ),
              );
            case LoadState.failed:
              _controller.reset();
              return widget.type == 'avatar'
                  ? placeholder(context)
                  : InkWell(
                      onTap: () {
                        Utils.openURL(widget.imgUrl);
                      },
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        color: Theme.of(context).colorScheme.onInverseSurface,
                        child: Center(
                          child: Text(
                            '加载失败 | 点击浏览器打开',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error),
                          ),
                        ),
                      ),
                    );
          }
        },
      );
    });
  }

  Widget placeholder(context) {
    return Container(
      width: widget.width,
      height: widget.height,
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
