import 'dart:math';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_v2ex/http/init.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class Upload {
  static const clientId = ["0db8b3c3e10d89b", "6b91ec71f6af441"];
  static const String uploadBaseUrl = 'https://api.imgur.com/3/image';
  static Future uploadImage(String key, AssetEntity file) async {
    dio.FormData formData = dio.FormData.fromMap(
      {
        'image': await Upload().multipartFileFromAssetEntity(file),
        // 'type': 'file'
      },
    );
    dio.Options options = dio.Options();
    options.headers = {
      'Authorization': "Client-ID ${clientId[Random().nextInt(2)]}"
    };
    options.contentType = 'multipart/form-data';
    var result =
        await Request().post(uploadBaseUrl, data: formData, options: options);
    return result.data['data'];
  }

  Future<dio.MultipartFile> multipartFileFromAssetEntity(
      AssetEntity entity) async {
    dio.MultipartFile mf;
    // Using the file path.
    final file = await entity.file;
    if (file == null) {
      throw StateError('Unable to obtain file of the entity ${entity.id}.');
    }
    mf = await dio.MultipartFile.fromFile(file.path, filename: 'image');
    // Using the bytes.
    final bytes = await entity.originBytes;
    if (bytes == null) {
      throw StateError('Unable to obtain bytes of the entity ${entity.id}.');
    }
    mf = dio.MultipartFile.fromBytes(bytes);
    return mf;
  }
}
