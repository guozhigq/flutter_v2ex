import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_v2ex/http/init.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:device_info_plus/device_info_plus.dart';

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

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  bool storage = true;
  bool videos = true;
  bool photos = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _requestPermission();
    android();
    setState(() {
      initialPage = widget.initialPage!;
      imgList = widget.imgList;
    });
  }

  android () async{
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    if (androidInfo.version.sdkInt >= 33) {
      videos = await Permission.videos.status.isGranted;
      photos = await Permission.photos.status.isGranted;
    } else {
      storage = await Permission.storage.status.isGranted;
    }

    if (storage && videos && photos) {
      // Good to go!
    } else {
      // crap.
    }
  }

  _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      // Permission.photos
    ].request();

    final info = statuses[Permission.storage].toString();
    // final photosInfo = statuses[Permission.photos].toString();

    print('授权状态：$info');
    // print('相册授权状态：$photosInfo');

  }

  void onSaveImg() async{
    SmartDialog.showLoading(msg: '保存中');
    var response = await Dio().get(imgList[initialPage],
        options: Options(responseType: ResponseType.bytes));
    final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
        quality: 100,
        name: "pic_vvex${DateTime.now().toString().split('-').join()}");
    SmartDialog.dismiss();
    if(result != null){
      if(result['isSuccess']){
        SmartDialog.showToast('已保存到相册');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          // appBar: AppBar(
          //   automaticallyImplyLeading: false,
          //   centerTitle: true,
          //   title: Text.rich(TextSpan(children: [
          //     TextSpan(text: (initialPage + 1).toString()),
          //     const TextSpan(text: ' / '),
          //     TextSpan(text: imgList.length.toString()),
          //   ])),
          //   actions: const [
          //     // IconButton(
          //     //     onPressed: () => {},
          //     //     icon: const Icon(Icons.file_download_outlined),
          //     //     tooltip: '下载所有图片'),
          //   ],
          // ),
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
          left: 20,
          right: 20,
          bottom: 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            IconButton(
                color: Theme.of(context).colorScheme.primary,
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, size: 35),
              ),
              if(imgList.length > 1)
              Text.rich(TextSpan(
                style: Theme.of(context).textTheme.titleSmall,
                  children: [
                  TextSpan(text: (initialPage + 1).toString()),
                  const TextSpan(text: ' / '),
                  TextSpan(text: imgList.length.toString()),
                ],),),
              IconButton(
                color: Theme.of(context).colorScheme.primary,
                onPressed: () => onSaveImg(),
                icon: const Icon(Icons.download_rounded, size: 35),
              ),
            ],
          )
        )
      ],
    );
  }
}
