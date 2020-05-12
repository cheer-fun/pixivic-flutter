import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:requests/requests.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class DownloadImage {
  final String url;
  final ValueChanged<int> onProgressUpdate;
  final String platform;

  int progress;
  String imageId;
  String fileName;
  String path;
  int size;
  String mimeType;
  int androidProgress;

  DownloadImage(this.url, this.platform, {this.onProgressUpdate}) {
    print('start download');
    BotToast.showSimpleNotification(title: '开始下载');

    ImageDownloader.callback(
        onProgressUpdate: (String imageId, int progressNow) {
      progress = progressNow;
      if (onProgressUpdate != null) onProgressUpdate(progress);
    });

    if (platform == 'ios')
      _iOSDownload();
    else if (platform == 'android') _androidDownload();
  }

  void dispose() {
    print('download disposed');
  }

  _iOSDownload() async {
    try {
      var response = await Requests.get(
        url,
        headers: {'Referer': 'https://app-api.pixiv.net'},
      );
      final result = await ImageGallerySaver.saveImage(Uint8List.fromList(response.bytes()));
      print(result);
      BotToast.showSimpleNotification(title: '下载完成');
    } catch (e) {
      BotToast.showSimpleNotification(title: '下载失败,请检查网络');
      print(e);
    }
  }

  _iOSDownloadWithImageDownloader() async {
    imageId = await ImageDownloader.downloadImage(
      url,
      headers: {'Referer': 'https://app-api.pixiv.net'},
      // destination: AndroidDestinationType.custom(directory: 'pixivic_images')
      //   ..inExternalFilesDir(),
    ).catchError((onError) {
      print(onError);
      BotToast.showSimpleNotification(title: '下载失败,请检查网络');
      // ImageDownloader.cancel();
      return false;
    });
    if (imageId == null) {
      print('image dwonload error');
      return false;
    }

    fileName = await ImageDownloader.findName(imageId);
    path = await ImageDownloader.findPath(imageId);
    size = await ImageDownloader.findByteSize(imageId);
    mimeType = await ImageDownloader.findMimeType(imageId);
    print(fileName);
    print(path);
    print(size);
    print(mimeType);
    BotToast.showSimpleNotification(title: '下载完成');
    return true;
  }

  _androidDownload() async {
    final Directory directory = await getExternalStorageDirectory();

    final Directory picDirFolder =
        Directory('${directory.path}${Platform.pathSeparator}pixivic_images');
    // print(picDirFolder.path);
    if (!await picDirFolder.exists()) {
      print('creating folder');
      await picDirFolder.create(recursive: true);
    }
    await FlutterDownloader.enqueue(
      url: url,
      savedDir: '${picDirFolder.path}',
      showNotification: true,
      openFileFromNotification: true,
      headers: {'Referer': 'https://app-api.pixiv.net'},
    ).catchError((onError) {
      print(onError);
      BotToast.showSimpleNotification(title: '下载失败,请检查网络');

      return false;
    });
  }
}
