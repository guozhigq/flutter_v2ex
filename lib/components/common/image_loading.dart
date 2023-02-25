import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';

class ImageLoading extends StatefulWidget {
  ImageLoading({required this.imgUrl, this.width, this.height, this.type,Key? key}) : super(key: key);

  String imgUrl = '';
  double? width;
  double? height;
  String? type;

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
    return ExtendedImage.network(
      widget.imgUrl,
      width: widget.type == 'avatar' ? widget.width! : null,
      height: widget.type == 'avatar' ? widget.height! : null,
      fit: BoxFit.cover,
      cache: true,
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            _controller.reset();
            return widget.type == 'avatar' ? placeholder(context) :Container(
              width: double.infinity,
              height: 60,
              color: Theme.of(context).colorScheme.onInverseSurface,
              child: const Center(
                child: Text('图片加载中...'),
              ),
            );
            break;

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
            break;
          case LoadState.failed:
            _controller.reset();
            return widget.type == 'avatar' ? placeholder(context) : GestureDetector(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    width: double.infinity,
                    height: 60,
                    color: Theme.of(context).colorScheme.onInverseSurface,
                    child: const Center(
                      child: Text('图片加载中...'),
                    ),
                  ),
                  const Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: Text(
                      "load image failed, click to reload",
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
              onTap: () {
                state.reLoadImage();
              },
            );
            break;
        }
      },
    );
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
