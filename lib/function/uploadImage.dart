import 'dart:io';
import 'package:flutter/material.dart';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';

import '../page/pic_detail_page.dart';
import '../data/texts.dart';
import '../data/common.dart';

uploadImageToSaucenao(File file, BuildContext context) async {
  TextZhUploadImage texts = TextZhUploadImage();
  Response response;
  Response illustExsitResponse;
  Response illustResponse;

  String fileName = file.path.split('/').last;
  FormData data = FormData.fromMap({
    "file": await MultipartFile.fromFile(
      file.path,
      filename: fileName,
    ),
  });
  Map<String, dynamic> queryParameters = {'output_type': '2'};

  CancelFunc loading = BotToast.showLoading();
  Dio dio = Dio();
  response = await dio.post("https://saucenao.com/search.php",
      data: data, queryParameters: queryParameters);
  loading();

  try {
    if (response.data['results'] == null) {
      print('no result found');
      BotToast.showSimpleNotification(title: texts.similarityLow);
      return false;
    } else {
      double similarity =
          double.parse(response.data['results'][0]['header']['similarity']);
      String id = response.data['results'][0]['data']['pixiv_id'].toString();
      if (response.statusCode == 200) {
        if (similarity < 50) {
          BotToast.showSimpleNotification(title: texts.similarityLow);
          return false;
        } else {
          Dio getIllust = Dio();
          print(response.data['results'][0]['header']['similarity']);
          print(response.data['results'][0]['data']['pixiv_id']);
          illustExsitResponse =
              await getIllust.get('https://api.pixivic.com/exists/illust/$id');
          illustResponse = await getIllust.get(
              'https://api.pixivic.com/illusts/$id',
              options: Options(
                  headers: prefs.getString('auth') == ''
                      ? {}
                      : {'authorization': prefs.getString('auth')}));
          if (illustResponse.statusCode == 200) {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return PicDetailPage(illustResponse.data['data']);
            }));
            return true;
          } else {
            print(illustResponse.statusCode);
            print('on low error');
            BotToast.showSimpleNotification(
                title: illustResponse.data['meesage']);
            return false;
          }
        }
      } else if (response.statusCode == 403) {
        BotToast.showSimpleNotification(title: texts.invalidKey);
        return false;
      } else if (response.statusCode == 413) {
        BotToast.showSimpleNotification(title: texts.fileTooLarge);
        return false;
      } else if (response.statusCode == 429) {
        if (response.data['header']['message'].contains('Daily'))
          BotToast.showSimpleNotification(title: texts.dailyLimit);
        else
          BotToast.showSimpleNotification(title: texts.shortLimit);
        return false;
      }
    }
  } catch (e) {
    print(e);
    if(e is DioError)
      BotToast.showSimpleNotification(title: e.response.data['message']);
    else 
      BotToast.showSimpleNotification(title: e.toString());
    return false;
  }
}
