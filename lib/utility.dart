import 'dart:io';
import 'dart:math';

class Style {
  final String _bold = '\x1B[1m';
  final String _green = '\x1B[32m';
  final String _red = '\x1B[31m';
  final String _reset = '\x1B[0m';

  String bold(String text) => '$_bold$text$_reset';
  String green(String text) => '$_green$text$_reset';
  String red(String text) => '$_red$text$_reset';
}

void WriteFile(String fileName, String content) {
  File('$fileName.tp.db').writeAsStringSync(content, mode: FileMode.append);
}

void CreateDir(String dirName) {
  Directory(dirName).createSync();
}

bool CheckDir(String dirName) {
  return Directory(dirName).existsSync();
}

bool CheckFile(String fileName) {
  return File('$fileName.tp.db').existsSync();
}

String ReadFile(String fileName) {
  return File('$fileName.tp.db').readAsStringSync();
}

List<String> WrapLines(String content) {
  return content.split('\n');
}

String SpawnID(int length) {
  List<String> ID = [];
  final List<String> alphaChars = [
    ...List.generate(26, (i) => String.fromCharCode(97 + i)),
    ...List.generate(10, (i) => i.toString()),
  ];

  for (int i = 0; i < length; i++) {
    ID.add(alphaChars[Random().nextInt(alphaChars.length)]);
  }

  return ID.join("");
}