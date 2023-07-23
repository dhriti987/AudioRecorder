import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

var apiOptions = BaseOptions(
  baseUrl: 'https://t4sqopo2i5.execute-api.eu-north-1.amazonaws.com/',
  connectTimeout: const Duration(seconds: 5),
);
Dio api = Dio(apiOptions);

Future<Widget> transcribe(File file) async {
  String fileName = file.path.split('/').last;
  FormData data = FormData.fromMap(
      {'music': await MultipartFile.fromFile(file.path, filename: fileName)});

  try {
    var response = await api.post('/default/audioToTextService', data: data);
    return Text(
      response.data,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
    );
  } on DioException catch (e) {
    return Text(
      e.response!.data,
      style: TextStyle(fontSize: 20, color: Colors.red),
    );
  }
}
