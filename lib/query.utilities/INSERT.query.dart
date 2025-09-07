import 'package:twopointsdb/db.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:twopointsdb/utility.dart';

class INSERT<T> implements DBAction<void> {
  List<Map<String, T>> insertData;

  INSERT(this.insertData);

  @override
  void run(DBController db) {
    BytesBuilder bytes = BytesBuilder();
    final File file = File('${db.actualDBStackPath!}.tp.db');

    RandomAccessFile initialBuffer = file.openSync(mode: FileMode.read);
    int currentCount = initialBuffer.readByteSync();
    initialBuffer.closeSync();

    for (var doc in insertData) {
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
          '${Style().green(key)} ${Style().bold(Style().green('has been inserted ✅'.toUpperCase()))}',
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