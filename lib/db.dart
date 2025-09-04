import 'dart:io';
import 'dart:typed_data';

import 'package:twopointsdb/utility.dart';

abstract class DBAction<T> {
  T run(DBController db);
}

typedef Dataset<T> = List<Map<String, T>>;
typedef Stack<T> = Map<String, T>;

class INSERT<T> implements DBAction<void> {
  List<Map<String, T>> insertData;

  INSERT(this.insertData);

  @override
  void run(DBController db) {
    BytesBuilder bytes = BytesBuilder();
    final File file = File('${db.actualDBStackPath!}.tp.db');

    RandomAccessFile initialBuffer = file.openSync(mode: FileMode.read);
    int currentCount = initialBuffer.readByteSync();
    print(currentCount);
    initialBuffer.closeSync();

    for (var doc in insertData) {
      String ID = SpawnID(32);

      doc.forEach((key, value) {
        bytes.add([key.length]);
        bytes.add(key.codeUnits);

        if (value is String) {
          bytes.add([1]);
          bytes.add([value.length]);
          bytes.add(value.codeUnits);
        } else if (value is int) {
          bytes.add([2]);
          var buffer = ByteData(8);
          buffer.setInt64(0, value, Endian.little);
          bytes.add(buffer.buffer.asUint8List());
        } else if (value is bool) {
          bytes.add([3]);
          bytes.add([value ? 1 : 0]);
        } else {
          throw Exception("Tipo no soportado: ${value.runtimeType}");
        }

        print(
          '${Style().green(key)} ${Style().bold(Style().green('has been inserted ✅'.toUpperCase()))} (ID: $ID)',
        );
      });
    }

    file.writeAsBytesSync(bytes.toBytes(), mode: FileMode.append);
    RandomAccessFile buffer = file.openSync(mode: FileMode.append);
    buffer.setPositionSync(0);
    buffer.writeByteSync(currentCount + insertData.length & 0xFF);
    buffer.closeSync();
  }
}

class FIND<T> implements DBAction<List<Map<String, T>>> {
  String key;

  FIND(this.key);

  @override
  List<Map<String, T>> run(DBController db) {
    List<Map<String, T>> wrappedValues = [];
    Uint8List bytes = File('${db.actualDBStackPath!}.tp.db').readAsBytesSync();
    int offset = 0;

    int getByte() => bytes[offset++];

    int numRecords = getByte();

    for (int i = 0; i < numRecords; i++) {
      int keyLen = getByte();
      print(keyLen);
      final keyBytes = bytes.sublist(offset, offset + keyLen);
      offset += keyLen;
      final currentKey = String.fromCharCodes(keyBytes);

      int type = getByte();

      int valueLen;
      T value;
      switch (type) {
        case 1:
          valueLen = getByte();
          value =
              String.fromCharCodes(bytes.sublist(offset, offset + valueLen))
                  as T;
          offset += valueLen;
          break;
        case 2:
          value =
              ByteData.sublistView(
                    bytes.sublist(offset, offset + 8),
                  ).getInt64(0, Endian.little)
                  as T;
          offset += 8;
          break;
        case 3:
          value = (bytes.sublist(offset, offset + 1)[0] == 1) as T;
          offset += 1;
          break;
        default:
          throw Exception(Style().red("UNKNOW TYPE: $type"));
      }

      if (currentKey == key) {
        wrappedValues.add({currentKey: value});
      }

      if (offset >= bytes.length) break;
    }

    return wrappedValues;
  }
}

class GET implements DBAction<Map<String, dynamic>> {
  @override
  Map<String, dynamic> run(DBController db) {
    Map<String, dynamic> stackDatasets = {};

    for (var line in WrapLines(ReadFile(db.actualDBStackPath!))) {
      final List<String> secs = line.split(' :: ');
      if (secs.length < 3) continue;
      stackDatasets[secs[0].trim()] = secs[2].split('||')[0].trim();
    }

    return stackDatasets;
  }
}

class DBController {
  String? actualDBPath;
  String? actualDBStackPath;

  DBController DB(String name) {
    actualDBPath = 'Databases/$name';

    if (!CheckDir('Databases/$name')) {
      CreateDir('Databases');
      CreateDir('Databases/$name');
      print(
        '${Style().green(name)} ${Style().bold(Style().green('has been initializated ✅.'.toUpperCase()))}',
      );
    } else {
      print(
        '${Style().red(name)} ${Style().bold(Style().red('has already been initializated ❌.'.toUpperCase()))}',
      );
    }

    return this;
  }

  DBController Stack(String name) {
    actualDBStackPath = '$actualDBPath/$name';

    if (!CheckFile(actualDBStackPath!)) {
      WriteFile(actualDBStackPath!, Uint8List.fromList([0]));
      print(
        '${Style().green(name)} ${Style().bold(Style().green('has been stacked ✅.'.toUpperCase()))}',
      );
    } else {
      print(
        '${Style().red(name)} ${Style().bold(Style().red('has already been stacked ❌.'.toUpperCase()))}',
      );
    }

    return this;
  }

  List<F> Query<F>(List<DBAction> actions) {
    List<F> returnQueue = [];
    try {
      for (var action in actions) {
        final result = action.run(this);

        if (result is F) {
          returnQueue.add(result);
        } else if (result != null) {
          throw Exception(
            "Types don't match with the required value in the query.",
          );
        }
      }
    } catch (e) {
      print(e);
    }

    return returnQueue;
  }
}
