// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

class InternalAPIWrapper {
  // importing files is handled by the javascript part.

  Future<bool> saveFiles(Map files) async {
    setString('uploaded_files', json.encode(files));
    return true;
  }

  Future<bool> setString(String name, String content) async {
    try {
      html.window.localStorage[name] = content;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map> getFiles() async {
    try {
      String files = await getString('uploaded_files', '{}');
      if (files != 'e') return json.decode(files);
      return {'error': true};
    } catch (e) {
      return {};
    }
  }

  Future<String> getString(String name, String defaultValue) async {
    try {
      return html.window.localStorage[name] ?? defaultValue;
    } catch (e) {
      return 'e';
    }
  }

  Future<bool> getBool(String name) async {
    if (html.window.localStorage[name] == null) return false;
    return json.decode(html.window.localStorage[name]!) ?? false;
  }

  Future<bool> setBool(String name, bool value) async {
    try {
      html.window.localStorage[name] = json.encode(value);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> copy(String text) async {
    print('called APIWrapper.copy($text)');
    html.TextInputElement input = html.TextInputElement();
    var range = html.Range();
    input.value = text;
    input.contentEditable = 'true';
    range.selectNodeContents(input);
    var sel = html.window.getSelection()!;
    sel.removeAllRanges();
    sel.addRange(range);
    input.setSelectionRange(0, 100);
    html.document.body!.append(input);
    input.select();
    bool copyStatus = html.document.execCommand('copy');
    input.remove();
    return copyStatus;
  }

  Future<Map?> askForFile([String? type]) {
    var completer = Completer<Map>();
    html.FileUploadInputElement inputFile = html.FileUploadInputElement();
    if (type != null) inputFile.accept = type;
    html.document.body!.append(inputFile);
    inputFile.click();
    inputFile.onChange.listen((_) {
      if (inputFile.files!.length == 0) return null;
      html.File? file = inputFile.files![0];
      inputFile.remove();
      completer
          .complete({'realFile': file, 'size': file.size, 'name': file.name});
    });
    inputFile.onAbort.listen((_) => completer.complete(null));
    return completer.future;
  }

  bool isWebAndroid() => html.window.navigator.userAgent.contains('Android');

  Future<Map?> importFiles() async {
    Map? fileMap = await askForFile();
    if (fileMap == null) return null;
    html.File file = fileMap['realFile'];
    html.FileReader reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;
    Uint8List bytes = Uint8List.view(reader.result as ByteBuffer);
    if (String.fromCharCode(bytes.first) != '{' ||
        String.fromCharCode(bytes.last) != '}') return null;
    Map? files = json.decode(String.fromCharCodes(bytes));
    return files;
  }

  Future<void> clearFilesCache() async => null;

  Future<bool?> saveFile(String filename, String content) async {
    html.Blob blob = new html.Blob([content]);
    html.LinkElement a = html.LinkElement();
    String url = a.href = html.Url.createObjectUrlFromBlob(blob);
    a.setAttribute('download', filename);
    html.document.body!.append(a);
    a.click();
    a.remove();
    html.Url.revokeObjectUrl(url);
    return true;
  }
}
