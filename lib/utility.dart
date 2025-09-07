import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'db.dart';

class Style {
  final String _bold = '\x1B[1m';
  final String _green = '\x1B[32m';
  final String _red = '\x1B[31m';
  final String _reset = '\x1B[0m';

  String bold(String text) => '$_bold$text$_reset';
  String green(String text) => '$_green$text$_reset';
  String red(String text) => '$_red$text$_reset';
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

class Parse {
  Stack<dynamic> result = {};
  Map<String, int> indexedOffset = {};

  Parse(DBController db) {
    Uint8List bytes = File('${db.actualDBStackPath!}.tp.db').readAsBytesSync();
    int offset = 0;

    int getByte() => bytes[offset++];

    int numRecords = getByte();

    for (int i = 0; i < numRecords; i++) {
      int keyLen = getByte();
      final keyBytes = bytes.sublist(offset, offset + keyLen);
      offset += keyLen;
      final currentKey = String.fromCharCodes(keyBytes);

      int type = getByte();
      indexedOffset[currentKey] = offset;

      int valueLen;
      dynamic value;
      switch (type) {
        case 1:
          valueLen = getByte();
          value = String.fromCharCodes(
            bytes.sublist(offset, offset + valueLen),
          );
          offset += valueLen;
          result[currentKey] = value;
          break;
        case 2:
          value = ByteData.sublistView(
            bytes.sublist(offset, offset + 8),
          ).getInt64(0, Endian.little);
          offset += 8;
          result[currentKey] = value;
          break;
        case 3:
          value = (bytes.sublist(offset, offset + 1)[0] == 1);
          offset += 1;
          result[currentKey] = value;
          break;
        default:
          throw Exception(Style().red("UNKNOW TYPE: $type"));
      }

      if (offset >= bytes.length) break;
    }
  }
}
