import 'dart:io';

void CreateFile(String fileName, String content) {
  File(fileName).writeAsString(content);
}
