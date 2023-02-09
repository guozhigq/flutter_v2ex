import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';

class ImagePreview extends StatefulWidget {
  List imgList = [];
  int? initialPage;

  ImagePreview({required this.imgList, this.initialPage, Key? key})
      : super(key: key);

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  int initialPage = 0;
  List imgList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      initialPage = widget.initialPage!;
      imgList = widget.imgList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Text.rich(TextSpan(children: [
              TextSpan(text: (initialPage + 1).toString()),
              const TextSpan(text: ' / '),
              TextSpan(text: imgList.length.toString()),
            ])),
            actions: const [
              // IconButton(
              //     onPressed: () => {},
              //     icon: const Icon(Icons.file_download_outlined),
              //     tooltip: '下载所有图片'),
            ],
          ),
          body: ExtendedImageGesturePageView.builder(
            controller: ExtendedPageController(
              initialPage: initialPage,
              pageSpacing: 50,
            ),
            onPageChanged: (int index) => {
              setState(() {
                initialPage = index;
              })
            },
            preloadPagesCount: 2,
            itemCount: imgList.length,
            itemBuilder: (BuildContext context, int index) {
              return ExtendedImage.network(
                imgList[index],
                fit: BoxFit.contain,
                mode: ExtendedImageMode.gesture,
                loadStateChanged: (ExtendedImageState state) {
                  if (state.extendedImageLoadState == LoadState.loading) {
                    final ImageChunkEvent? loadingProgress =
                        state.loadingProgress;
                    final double? progress =
                        loadingProgress?.expectedTotalBytes != null
                            ? loadingProgress!.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null;
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 150.0,
                            child: LinearProgressIndicator(value: progress),
                          ),
                          const SizedBox(height: 10.0),
                          Text('${((progress ?? 0.0) * 100).toInt()}%'),
                        ],
                      ),
                    );
                  }
                },
                initGestureConfigHandler: (ExtendedImageState state) {
                  return GestureConfig(
                    //you must set inPageView true if you want to use ExtendedImageGesturePageView
                    inPageView: true,
                    initialScale: 1.0,
                    maxScale: 5.0,
                    animationMaxScale: 6.0,
                    initialAlignment: InitialAlignment.center,
                  );
                },
              );
            },
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 30,
          child: Center(
            child: IconButton(
              color: Theme.of(context).colorScheme.primary,
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_outlined, size: 35),
            ),
          ),
        )
      ],
    );
  }
}
