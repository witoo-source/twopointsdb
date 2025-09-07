import 'dart:io';
import 'dart:typed_data';
import 'package:twopointsdb/db.dart';
import 'package:twopointsdb/utility.dart';

class FIND<T> implements DBAction<Dataset<T>> {
  List<String> keys;

  FIND(this.keys);

  @override
  Dataset<T> run(DBController db) {
    Dataset<T> foundValues = [];

    for (String key in keys) {
      if (File('${db.actualDBPath}/indexed/$key.idx.db').existsSync()) {
        RandomAccessFile raf = File(
          '${db.actualDBStackPath!}.tp.db',
        ).openSync(mode: FileMode.read);
        raf.setPositionSync(
          int.parse(
            File('${db.actualDBPath}/indexed/$key.idx.db').readAsStringSync(),
          ) - 1,
        );

        int type = raf.readSync(1)[0];

        dynamic value;
        switch (type) {
          case 1:
            value = String.fromCharCodes(raf.readSync(raf.readSync(1)[0]));
            break;
          case 2:
            value = ByteData.sublistView(
              raf.readSync(8),
            ).getInt64(0, Endian.little);
            break;
          case 3:
            value = raf.readSync(1)[0] == 1;
            break;
          default:
            throw Exception(Style().red("UNKNOW TYPE: $type"));
        }

        foundValues.add({key: value});
      } else {
        Parse parsed = Parse(db);
        for (var parsedKey in parsed.result.keys) {
          if (parsedKey == key) {
            foundValues.add({parsedKey: parsed.result[parsedKey] as T});
            print(
              '${Style().green(key)} ${Style().bold(Style().green('was found ✅'.toUpperCase()))}',
            );
          }
        }
      }
    }

    return foundValues;
  }
}