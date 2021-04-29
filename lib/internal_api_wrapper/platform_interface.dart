import 'package:flutter/material.dart';
import 'package:uploadgram/api_definitions.dart';

class InternalAPIWrapper {
  static String? lastUri; // Exclusive to web
  //Future<bool> copy(String? text, {Function? onSuccess, Function? onError}) =>
  //    throw UnsupportedError('copy() has not been implemented.');

  bool isWebAndroid() =>
      throw UnsupportedError('isWebAndroid() has not been implemented.');
  Future<Map?> importFiles() =>
      throw UnsupportedError('importFiles() has not been implemented.');
  Future<void> clearFilesCache() =>
      throw UnsupportedError('clearFilesCache() has not been implemented.');
  Future<void> deleteCachedFile(String name) async =>
      throw UnsupportedError('deleteCachedFile() has not been implemented.');

  Future<UploadgramFile> askForFile() =>
      throw UnsupportedError('askForFile() has not been implemented.');
  Future<bool?> saveFile(String? filename, String content) =>
      throw UnsupportedError('saveFile() has not been implemented.');
  Future<Map> getFiles() =>
      throw UnsupportedError('getFiles() has not been implemented.');
  Future<String?> getString(String name, String defaultValue) =>
      throw UnsupportedError('getString() has not been implemented.');

  static void listenDropzone(
          BuildContext context, Function(UploadgramFile) uploadFile) =>
      throw UnsupportedError('listenDropzone() has not been implemented.');

  Future<void> deletePreferences() =>
      throw UnsupportedError('deletePreferences() has not been implemented.');

  Future<void> shareUploadgramLink(String url) async =>
      throw UnsupportedError('shareUploadgramLink() has not been implemented.');
}
