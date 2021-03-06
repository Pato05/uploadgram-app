import 'package:flutter/material.dart';
import 'package:uploadgram/api_definitions.dart';
import 'package:uploadgram/app_definitions.dart';
import 'package:uploadgram/app_logic.dart';
import 'package:uploadgram/file_icons.dart';
import 'package:uploadgram/routes/file_info.dart';
import 'package:uploadgram/routes/uploadgram_route.dart';
import 'package:uploadgram/selected_files_notifier.dart';
import 'package:uploadgram/utils.dart';

class FilesList extends FilesViewerTheme {
  final SelectedFilesNotifier selectedFiles;
  FilesList({required this.selectedFiles});

  Widget _filesWidgets(BuildContext context, int index) {
    var queueLength = AppLogic.uploadingQueue.length;
    if (index < queueLength) {
      UploadingFile uploadingFile =
          AppLogic.uploadingQueue[queueLength - 1 - index];
      IconData fileIcon =
          getFileIconFromName(uploadingFile.uploadgramFile.name);
      return buildUploadingWidget(
          (uploading, progress, error, bytesPerSec, delete, file) {
        return FileListTile(
          bytesPerSec: bytesPerSec,
          icon: fileIcon,
          filename: file['filename'],
          size: file['size'],
          selectedFilesNotifier: selectedFiles,
          delete: delete,
          url: file['url'],
          handleDelete: uploading
              ? null
              : (String delete, {Function? onYes}) =>
                  UploadgramRoute.of(context)
                      ?.handleFileDelete([delete], onYes: onYes),
          handleRename:
              uploading ? null : UploadgramRoute.of(context)!.handleFileRename,
          uploading: uploading,
          progress: progress,
        );
      }, uploadingFile);
    }
    if (index >= queueLength) index = index - queueLength;
    MapEntry file =
        AppLogic.files!.entries.elementAt(AppLogic.files!.length - index - 1);
    IconData fileIcon = getFileIconFromName(file.value['filename']);
    return FileListTile(
      icon: fileIcon,
      delete: file.key,
      url: file.value['url'],
      filename: file.value['filename'],
      size: file.value['size'],
      selectedFilesNotifier: selectedFiles,
      handleDelete: (String delete, {Function? onYes}) =>
          UploadgramRoute.of(context)!.handleFileDelete([delete], onYes: onYes),
      handleRename: UploadgramRoute.of(context)!.handleFileRename,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      child: ListView.builder(
          itemBuilder: _filesWidgets,
          itemCount: AppLogic.files!.length + AppLogic.uploadingQueue.length,
          padding: EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 78)),
      selectedTileColor: Colors
          .grey[Theme.of(context).brightness == Brightness.dark ? 900 : 200],
    );
  }
}

class FileListTile extends StatelessWidget {
  final IconData icon;
  final String delete;
  final String filename;
  final String? error;
  final bool uploading;
  final double? progress;
  final int size;
  final bool selected;
  final SelectedFilesNotifier selectedFilesNotifier;
  final Function(String, {Function? onYes})? handleDelete;
  final Function(String, {Function(String)? onDone, String? oldName})?
      handleRename;
  final String url;
  final int? bytesPerSec;

  FileListTile({
    Key? key,
    required this.icon,
    required this.delete,
    required this.url,
    required this.filename,
    required this.size,
    required this.selectedFilesNotifier,
    this.uploading = false,
    this.selected = false,
    this.error,
    this.progress,
    this.handleDelete,
    this.handleRename,
    this.bytesPerSec,
  })  : assert(uploading || (handleDelete != null && handleRename != null)),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<String> _filenameNotifier =
        ValueNotifier<String>(filename);
    final subtitle = error != null
        ? Text(error!, style: TextStyle(color: Colors.red))
        : uploading
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (progress != null)
                      Padding(
                          child:
                              Text('${(progress! * 100).round().toString()}%'),
                          padding: EdgeInsets.only(right: 15)),
                    Expanded(child: LinearProgressIndicator(value: progress)),
                    Padding(
                        child: Text('${Utils.humanSize(bytesPerSec!)}/s'),
                        padding: EdgeInsets.only(left: 15)),
                  ],
                )
              ])
            : Text(Utils.humanSize(size));
    final Function() openFileInfo = () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => FileInfoRoute(
                filename: _filenameNotifier,
                fileSize: size,
                fileIcon: icon,
                delete: delete,
                handleDelete: handleDelete!,
                handleRename: handleRename!,
                url: url)));
    final Function() selectWidget =
        () => UploadgramRoute.of(context)!.selectWidget(delete);
    return FileRightClickListener(
        delete: delete,
        filenameNotifier: _filenameNotifier,
        handleDelete: handleDelete,
        handleRename: handleRename,
        size: size,
        url: url,
        child: ValueListenableBuilder(
            builder: (BuildContext context, List<String> value, _) => ListTile(
                  leading: GestureDetector(
                      child: AnimatedCrossFade(
                          firstChild:
                              Icon(icon, size: 24, color: Colors.grey.shade700),
                          secondChild: Icon(Icons.check_circle,
                              size: 24, color: Colors.blue.shade600),
                          firstCurve: Curves.easeInOut,
                          secondCurve: Curves.easeInOut,
                          crossFadeState: value.contains(delete)
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: Duration(milliseconds: 200)),
                      onTap: selectWidget,
                      onLongPress: selectWidget),
                  title: ValueListenableBuilder<String>(
                      valueListenable: _filenameNotifier,
                      builder: (BuildContext context, String value, _) => Text(
                          value,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis)),
                  subtitle: subtitle,
                  onTap: uploading
                      ? null
                      : value.length > 0
                          ? selectWidget
                          : openFileInfo,
                  onLongPress: uploading ? null : selectWidget,
                  selected: value.contains(delete),
                ),
            valueListenable: selectedFilesNotifier));
  }
}
