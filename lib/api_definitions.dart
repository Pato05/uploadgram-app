import 'package:uploadgram/app_logic.dart';

class RenameApiResponse {
  final bool ok;
  final String? newName;

  final int statusCode;
  final String? errorMessage;

  RenameApiResponse({
    required this.ok,
    required this.statusCode,
    this.newName,
    this.errorMessage,
  });

  factory RenameApiResponse.fromJson(Map json) => RenameApiResponse(
      ok: json['ok'],
      newName: json['ok'] ? json['new_filename'] : null,
      statusCode: 200);

  @override
  String toString() {
    return '${this.runtimeType.toString()}(ok: $ok, statusCode: $statusCode)';
  }
}

class DeleteApiResponse {
  final bool ok;
  final int statusCode;

  DeleteApiResponse({
    required this.ok,
    required this.statusCode,
  });

  factory DeleteApiResponse.fromJson(Map json) =>
      DeleteApiResponse(ok: json['ok'], statusCode: 200);
}

class UploadApiResponse {
  final bool ok;
  final String? url;
  final String? delete;

  final int statusCode;
  final String? errorMessage;

  UploadApiResponse(
      {required this.ok,
      this.url,
      this.delete,
      this.statusCode = 200,
      this.errorMessage});

  factory UploadApiResponse.fromJson(Map json) {
    if (json['ok'])
      return UploadApiResponse(
          ok: json['ok'], url: json['url'], delete: json['delete']);
    return UploadApiResponse(
        ok: false,
        statusCode: json['statusCode'],
        errorMessage: json['message']);
  }
}

enum UploadgramFileError { none, permissionNotGranted, abortedByUser }

class UploadgramFile {
  final int size;
  final String name;
  final realFile; // this should either be a web file or a io file

  final UploadgramFileError error;

  UploadgramFile({
    this.size = 0,
    this.name = '',
    this.realFile,
    this.error = UploadgramFileError.none,
  }) : assert(error != UploadgramFileError.none ||
            (name != '' && realFile != null));

  bool hasError() => error != UploadgramFileError.none;
}

class UploadingFile {
  bool locked;
  Stream<UploadingEvent>? stream;
  dynamic fileKey;
  UploadgramFile uploadgramFile;

  UploadingFile({
    required this.uploadgramFile,
    required this.fileKey,
    this.stream,
    this.locked = false,
  });
}

class UploadingEvent {}

class UploadingEventProgress extends UploadingEvent {
  double progress;
  int bytesPerSec;

  UploadingEventProgress({
    required this.progress,
    required this.bytesPerSec,
  });
}

class UploadingEventEnd extends UploadingEvent {
  String delete;
  UploadedFile file;

  UploadingEventEnd({
    required this.delete,
    required this.file,
  });
}
